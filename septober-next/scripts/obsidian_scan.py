#!/usr/bin/env python3
"""Scan Obsidian vault via obpbt and sync todos into Septober.

This is NOT a one-off tool. It's meant to run daily via `just obsidian-sync`.
It's idempotent: running it twice won't create duplicates (dedup via source_ref + obpbt hash).

Pipeline: obpbt todos → Regex filter → LLM triage (borderlines) → Dedup → POST API

Usage:
    just obsidian-scan       # dry run preview
    just obsidian-sync       # full pipeline, sync to Septober
    just obsidian-sync-all   # full vault sweep
"""

import re
import sys
import json
import argparse
import subprocess
from pathlib import Path

# Add src to path so we can import septober
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from septober.obsidian import parse_and_classify, format_report, to_septober_payload, Verdict
from septober.llm_triage import triage_borderline_items


def fetch_existing_obsidian_refs(api_url: str) -> tuple[set[str], set[str]]:
    """Fetch existing source_refs AND obpbt hashes for dedup.

    Returns (source_refs, obpbt_hashes) — belt and suspenders.
    """
    try:
        import httpx
        client = httpx.Client(base_url=api_url, timeout=10)
        refs = set()
        hashes = set()
        for status in ["active", "done", "archived"]:
            resp = client.get("/api/todos/", params={
                "source": "obsidian",
                "status": status,
                "limit": 500,
                "include_hidden": True,
            })
            if resp.status_code == 200:
                for item in resp.json().get("items", []):
                    if item.get("source_ref"):
                        refs.add(item["source_ref"])
                    # Extract obpbt hash from sys_notes
                    notes = item.get("sys_notes", "") or ""
                    for line in notes.splitlines():
                        if line.startswith("obpbt_hash:"):
                            hashes.add(line.split(":", 1)[1].strip())
        return refs, hashes
    except Exception as e:
        print(f"⚠️  Could not fetch existing todos for dedup: {e}")
        return set(), set()


def run_obpbt(cmd: str) -> str:
    """Run obpbt and capture output, stripping ANSI codes."""
    try:
        result = subprocess.run(
            cmd.split(), capture_output=True, text=True, timeout=30
        )
        raw = result.stdout + result.stderr
        # Strip ANSI color codes
        return re.sub(r'\x1b\[[0-9;]*m', '', raw)
    except FileNotFoundError:
        print(f"❌ Command not found: {cmd.split()[0]}")
        print("   Is obpbt installed? Check: which obpbt")
        sys.exit(1)
    except subprocess.TimeoutExpired:
        print(f"❌ Command timed out: {cmd}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Obsidian → Septober sync (idempotent, LLM-powered)"
    )
    parser.add_argument(
        "--ingest", action="store_true",
        help="Actually POST new items to Septober API (default: dry run)"
    )
    parser.add_argument(
        "--api-url", default=None,
        help="Septober API base URL (overrides SEPTOBER_API_URL env var)"
    )
    parser.add_argument(
        "--json", action="store_true",
        help="Output actionable items as JSON"
    )
    parser.add_argument(
        "--include-wishes", action="store_true",
        help="Also sync reference/wish items"
    )
    parser.add_argument(
        "--all", action="store_true", dest="all_items",
        help="Pass --all to obpbt for full vault sweep"
    )
    parser.add_argument(
        "--input", type=str, default=None,
        help="Read from file instead of running obpbt (for testing)"
    )
    parser.add_argument(
        "--no-llm", action="store_true",
        help="Skip LLM triage (borderline items remain borderline)"
    )
    args = parser.parse_args()

    # Load config
    from septober.config import get_settings
    settings = get_settings()

    api_url = args.api_url or settings.api_url
    gemini_key = settings.gemini_api_key
    gemini_model = settings.gemini_model
    obpbt_cmd = settings.obpbt_cmd

    # === Step 1: Get input ===
    if args.input:
        raw = Path(args.input).read_text()
        raw = re.sub(r'\x1b\[[0-9;]*m', '', raw)
    elif not sys.stdin.isatty():
        raw = sys.stdin.read()
        raw = re.sub(r'\x1b\[[0-9;]*m', '', raw)
    else:
        # Run obpbt directly
        cmd = obpbt_cmd
        if args.all_items:
            cmd += " --all"
        print(f"🔍 Running: {cmd}")
        raw = run_obpbt(cmd)

    # === Step 2: Parse and regex-classify ===
    todos = parse_and_classify(raw)
    if not todos:
        print("❌ No items found in input.")
        sys.exit(1)

    # === Step 3: LLM triage for BORDERLINE items ===
    borderline = [t for t in todos if t.verdict == Verdict.BORDERLINE]
    if borderline and not args.no_llm:
        if not gemini_key:
            print("❌ SEPTOBER_GEMINI_API_KEY is not set!", file=sys.stderr)
            print("   Set it in your environment or .env file:", file=sys.stderr)
            print("   export SEPTOBER_GEMINI_API_KEY='your-key-here'", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Or add to .env:", file=sys.stderr)
            print("   SEPTOBER_GEMINI_API_KEY=your-key-here", file=sys.stderr)
            sys.exit(1)

        print(f"🤖 LLM triaging {len(borderline)} borderline items with {gemini_model}...")
        triage_borderline_items(borderline, api_key=gemini_key, model_name=gemini_model)

        # Count outcomes
        llm_actionable = sum(1 for t in borderline if t.verdict == Verdict.ACTIONABLE)
        llm_noise = sum(1 for t in borderline if t.verdict == Verdict.NOISE)
        llm_other = len(borderline) - llm_actionable - llm_noise
        print(f"   ✅ {llm_actionable} → actionable, 🗑️ {llm_noise} → noise, 📎 {llm_other} → other")

    # Collect items to ingest
    to_ingest = [t for t in todos if t.verdict == Verdict.ACTIONABLE]
    if args.include_wishes:
        to_ingest += [t for t in todos if t.verdict == Verdict.REFERENCE]

    if args.json:
        payloads = [to_septober_payload(t) for t in to_ingest]
        print(json.dumps(payloads, indent=2, default=str))
        return

    # Print report
    print(format_report(todos))

    if not args.ingest:
        print(f"\n{'=' * 70}")
        print(f"🔍 DRY RUN — {len(to_ingest)} items would be synced.")
        print(f"   Run with --ingest to actually sync (or: just obsidian-sync)")
        print(f"{'=' * 70}")
        return

    # === Step 4: Dedup ===
    if not to_ingest:
        print("\n🤷 Nothing to ingest!")
        return

    try:
        import httpx
    except ImportError:
        print("❌ Need httpx: uv pip install httpx")
        sys.exit(1)

    print(f"\n🔄 Checking for duplicates against {api_url}...")
    existing_refs, existing_hashes = fetch_existing_obsidian_refs(api_url)
    print(f"   Found {len(existing_refs)} source_refs + {len(existing_hashes)} obpbt hashes")

    new_items = []
    skipped = 0
    for todo in to_ingest:
        payload = to_septober_payload(todo)
        ref = payload.get("source_ref", "")
        hash_id = todo.hash_id

        if ref in existing_refs:
            skipped += 1
        elif hash_id and hash_id in existing_hashes:
            skipped += 1
        else:
            new_items.append((todo, payload))

    if skipped > 0:
        print(f"   ⏭️  Skipping {skipped} already-imported items")

    if not new_items:
        print(f"\n✅ Everything is already in sync! No new items to add.")
        return

    # === Step 5: Ingest ===
    print(f"\n{'=' * 70}")
    print(f"🚀 SYNCING {len(new_items)} NEW items into Septober at {api_url}...")
    print(f"{'=' * 70}")

    client = httpx.Client(base_url=api_url, timeout=10)
    ok, fail = 0, 0

    for todo, payload in new_items:
        try:
            resp = client.post("/api/todos/", json=payload)
            if resp.status_code == 201:
                created = resp.json()
                cat_icon = {"famiglia": "👨‍👩‍👧‍👦", "personale": "🧘", "lavoro": "💼",
                            "finanze": "🏦", "shopping": "🛒"}.get(created.get("category", ""), "?")
                wish = "💭" if created.get("is_wish") else "  "
                print(f"  ✅ {cat_icon}{wish} #{created['id']}: {created['title'][:55]}")
                ok += 1
            else:
                print(f"  ❌ {resp.status_code}: {payload['title'][:50]} — {resp.text[:80]}")
                fail += 1
        except Exception as e:
            print(f"  ❌ Error: {payload['title'][:50]} — {e}")
            fail += 1

    print(f"\n{'=' * 70}")
    print(f"📊 Sync complete: {ok} new, {skipped} already synced, {fail} failed")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()
