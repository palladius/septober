# Plan: LLM-Powered Idempotent Obsidian → Septober Sync

## Phase 1: Configuration & Gemini Integration

- [ ] Task: Add `google-genai` dependency to `pyproject.toml` and run `uv sync`
- [ ] Task: Extend `config.py` with new settings
  - [ ] `gemini_api_key: str` (required, no default)
  - [ ] `api_url: str = "http://localhost:8000"`
  - [ ] `obpbt_cmd: str = "obpbt todos"`
  - [ ] `stale_days: int = 14`
  - [ ] `gemini_model: str = "gemini-2.0-flash"`
- [ ] Task: Update `.env.dist` with new variables (do NOT touch `.env`)
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: BORDERLINE Classification in Regex Filter

- [ ] Task: Write tests for BORDERLINE verdict
  - [ ] Test items that should be BORDERLINE (ambiguous todos)
  - [ ] Test items that should remain ACTIONABLE (clear action verbs)
  - [ ] Test items that should remain NOISE (obvious junk)
- [ ] Task: Add `BORDERLINE` verdict to `obsidian.py` Verdict enum
- [ ] Task: Refactor `classify_todo()` to emit `BORDERLINE` for ambiguous items
  - [ ] Items with weak action signals but not clearly noise
  - [ ] Items starting with "TODO" followed by meaningful content
  - [ ] Items that have no clear action verb but substantial text (>20 chars)
- [ ] Task: Update `format_report()` to show BORDERLINE items with 🤔 emoji
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Gemini LLM Triage Module

- [ ] Task: Write tests for LLM triage (with mocked Gemini responses)
  - [ ] Test that BORDERLINE items are sent to LLM with correct prompt
  - [ ] Test that LLM verdicts override regex BORDERLINE classification
  - [ ] Test that non-BORDERLINE items are NOT sent to LLM
  - [ ] Test error handling: API timeout, invalid response, rate limit
  - [ ] Test hard-fail when SEPTOBER_GEMINI_API_KEY is missing
- [ ] Task: Create `src/septober/llm_triage.py` module
  - [ ] `triage_borderline_items(items: list[ObsidianTodo]) -> list[ObsidianTodo]`
  - [ ] Build structured prompt with item context (title, source file, tags, date)
  - [ ] Parse LLM JSON response: verdict, category, priority, clean_title, reasoning
  - [ ] Batch items into a single LLM call (not one-per-item) for efficiency
  - [ ] Handle Gemini API errors gracefully (retry once, then fail)
- [ ] Task: Validate API key presence at startup — hard fail with clear message
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Dedup via API (Belt & Suspenders)

- [ ] Task: Write tests for dedup logic
  - [ ] Test dedup by `source_ref` (file:line)
  - [ ] Test dedup by obpbt hash (stored in `sys_notes`)
  - [ ] Test that new items pass dedup checks
  - [ ] Test that already-imported items are skipped
- [ ] Task: Modify `to_septober_payload()` to store obpbt hash in `sys_notes`
- [ ] Task: Create `fetch_existing_obsidian_refs()` function
  - [ ] GET /api/todos/?source=obsidian&limit=500 (all statuses)
  - [ ] Extract set of `source_ref` values
  - [ ] Extract set of obpbt hashes from `sys_notes` field
- [ ] Task: Integrate dedup into the sync pipeline
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: Pipeline Assembly & Just Commands

- [ ] Task: Write integration test for full pipeline (mocked LLM + mocked API)
  - [ ] Test end-to-end: obpbt output → parse → regex → LLM → dedup → ingest
  - [ ] Test idempotency: second run produces 0 new items
  - [ ] Test dry-run mode (no API calls)
- [ ] Task: Rewrite `scripts/obsidian_scan.py` as the unified pipeline script
  - [ ] Subprocess capture of `obpbt todos` (configurable command)
  - [ ] Three-stage pipeline: regex → LLM → dedup+ingest
  - [ ] Structured summary report at the end
  - [ ] `--dry-run` flag for scan-only mode
  - [ ] `--all` flag to pass `--all` to obpbt
- [ ] Task: Add justfile commands
  - [ ] `obsidian-scan` → dry run preview
  - [ ] `obsidian-sync` → full pipeline
  - [ ] `obsidian-sync-all` → full vault sweep
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 6: Final Verification & Documentation

- [ ] Task: Run full test suite — all tests must pass (existing 37 + new)
- [ ] Task: Run `just obsidian-sync` end-to-end against real obpbt data (dev server)
- [ ] Task: Run it twice — verify 0 new items on second run (idempotency proof)
- [ ] Task: Update README.md with Obsidian sync documentation
- [ ] Task: Update CHANGELOG.md
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
