# Spec: LLM-Powered Idempotent Obsidian → Septober Sync

## Overview

Build a daily-use, idempotent sync pipeline that extracts actionable TODOs from the user's Obsidian vault (via the existing `obpbt todos` CLI tool), uses **Gemini Flash** to intelligently triage borderline items, and ingests the results into the **Septober API** running on Cloud Run.

The pipeline runs from the user's local Mac (where Obsidian lives) and communicates with the remote Septober backend over HTTPS. It does NOT access the database directly — all operations go through the REST API.

### Architecture

```
┌───────────────────────────────────────────────────────────┐
│  LOCAL MAC (where Obsidian vault + obpbt live)            │
│                                                           │
│  obpbt todos ──┐                                          │
│                │ stdout                                   │
│                ▼                                          │
│  ┌──────────────────────────────┐                         │
│  │  septober obsidian_scan.py   │                         │
│  │                              │                         │
│  │  1. Parse obpbt output       │                         │
│  │  2. Regex first-pass filter  │                         │
│  │  3. LLM triage (borderlines) │──── Gemini API ───►     │
│  │  4. Dedup check via API      │                         │
│  │  5. POST new items           │──── HTTPS ──────►       │
│  └──────────────────────────────┘                         │
└───────────────────────────────────────────────────────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │  CLOUD RUN             │
                              │  Septober FastAPI      │
                              │  /api/todos/           │
                              │  SQLite / PostgreSQL   │
                              └───────────────────────┘
```

## Functional Requirements

### FR1: Input — `obpbt todos` as Data Source

- The sync tool consumes **stdout** from the `obpbt todos` command (piped or captured via subprocess).
- It does NOT directly scan Obsidian vault files — `obpbt` handles the heavy lifting of markdown parsing, checkbox extraction, and date resolution.
- The tool strips ANSI color codes from `obpbt` output before parsing.
- Default mode: `obpbt todos` (recent active items). Configurable to use `obpbt todos --all` for a full sweep.

### FR2: Three-Stage Classification Pipeline

**Stage 1: Regex First-Pass Filter** (existing logic in `obsidian.py`)
- Instantly classify items into: `DONE`, `NOISE`, `STALE`, `EXPENSE`, `REFERENCE`, `BORDERLINE`, `ACTIONABLE`.
- Items classified as `ACTIONABLE` or `BORDERLINE` proceed to Stage 2.
- Items classified as `DONE`, `NOISE`, `STALE`, `EXPENSE` are dropped with a summary count.
- Items classified as `REFERENCE` are imported as wishes (`is_wish: true`).

**Stage 2: LLM Triage (Borderline Items Only)**
- Only `BORDERLINE` items are sent to Gemini for classification.
- Expected volume: ~5-20 items per run (cheap, fast).
- The LLM receives each borderline item with context (source file, tags, date, original text) and returns:
  - `verdict`: `actionable` | `noise` | `stale` | `reference`
  - `category`: one of `famiglia` / `personale` / `lavoro` / `finanze` / `shopping`
  - `priority`: 1-5
  - `clean_title`: normalized, cleaned-up title (remove emoji prefixes, fix grammar)
  - `reasoning`: one-line explanation of the classification
- The LLM is called via the `google-genai` Python SDK with model `gemini-2.0-flash`.
- **HARD REQUIREMENT**: If `SEPTOBER_GEMINI_API_KEY` is not set, the tool MUST refuse to run and print a clear error message with setup instructions.

**Stage 3: Dedup & Ingest**
- Before POSTing, check if the item already exists in Septober via two mechanisms:
  - `source_ref` match: compare `{filename}:{line}` against existing todos with `source=obsidian`
  - `obpbt_hash` match: store the 7-char obpbt hash in `sys_notes` and check for duplicates
- Only genuinely new items are POSTed to the Septober API.
- The API URL is configurable (default: `http://localhost:8000`, production: Cloud Run URL).

### FR3: Idempotency

- Running `just obsidian-sync` multiple times in a day produces the same result as running it once.
- If an item was already imported (matched by source_ref or obpbt hash), it is silently skipped.
- If an item's content changed in Obsidian but its source_ref is the same, it is NOT re-imported (we don't update — that's a V2 feature).

### FR4: Configuration

All configuration via environment variables with `SEPTOBER_` prefix (Pydantic Settings):

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SEPTOBER_GEMINI_API_KEY` | **Yes** | — | Gemini API key for LLM triage |
| `SEPTOBER_API_URL` | No | `http://localhost:8000` | Septober API base URL |
| `SEPTOBER_OBPBT_CMD` | No | `obpbt todos` | Command to run for todo extraction |
| `SEPTOBER_STALE_DAYS` | No | `14` | Days after which travel items are considered stale |
| `SEPTOBER_GEMINI_MODEL` | No | `gemini-2.0-flash` | Gemini model name |

### FR5: Just Commands

| Command | Behavior |
|---------|----------|
| `just obsidian-scan` | Dry run: parse, classify, show report. No API calls. |
| `just obsidian-sync` | Full pipeline: parse → LLM → dedup → ingest. Non-interactive. |
| `just obsidian-sync-all` | Same but with `obpbt todos --all` for full vault sweep. |

### FR6: Reporting

Every run prints a structured summary:
```
🧹 SEPTOBER OBSIDIAN SYNC — 2026-08-23
════════════════════════════════════════
Total scanned:  20
  ✅ Actionable:  8  (3 new, 5 already synced)
  🤖 LLM triaged: 4  (2→actionable, 1→noise, 1→stale)
  ⏰ Stale:        4
  🗑️  Noise:        3
  📎 Wishes:       1
  ☑️  Done:         0
────────────────────────────────────────
📊 Result: 3 new items synced to https://septober-xxx.run.app
```

## Non-Functional Requirements

- **Performance**: Full pipeline completes in <15 seconds (LLM calls dominate).
- **Cost**: <$0.01/day at typical usage (5-20 items triaged by LLM per run).
- **Dependency**: Only `google-genai` added to `pyproject.toml` (plus existing `httpx`).
- **Error Handling**: Network errors to Septober API or Gemini API are caught, reported, and don't crash the pipeline. But missing API key = hard fail.
- **Logging**: Verbose output to stdout. No separate log files (user pipes to `tee` if needed).

## Acceptance Criteria

1. `just obsidian-sync` runs end-to-end in <15 seconds with a Gemini API key set.
2. Running `just obsidian-sync` twice in a row produces 0 new items on the second run.
3. The LLM correctly classifies at least 80% of borderline items (validated by 5+ test cases with known expected outputs).
4. Missing `SEPTOBER_GEMINI_API_KEY` prints a clear error and exits with code 1.
5. Works with both `http://localhost:8000` (dev) and a remote Cloud Run URL (prod).
6. Existing 37 tests still pass. New tests cover the LLM integration (mocked).

## Out of Scope

- **Direct Obsidian vault scanning** — we only consume `obpbt` output.
- **Updating existing todos** — if content changes in Obsidian, we don't update the Septober copy (V2).
- **Two-way sync** — Septober → Obsidian is not supported.
- **Frontend changes** — no UI work in this track.
- **Cloud Run deployment** — that's a separate track.
