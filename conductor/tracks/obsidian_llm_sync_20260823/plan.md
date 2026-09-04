# Plan: LLM-Powered Idempotent Obsidian → Septober Sync

## Phase 1: Configuration & Gemini Integration [checkpoint: cc52f9e]

- [x] Task: Add `google-genai` dependency to `pyproject.toml` and run `uv sync`
- [x] Task: Extend `config.py` with new settings
  - [x] `gemini_api_key: str` (required, no default)
  - [x] `api_url: str = "http://localhost:8000"`
  - [x] `obpbt_cmd: str = "obpbt todos"`
  - [x] `stale_days: int = 14`
  - [x] `gemini_model: str = "gemini-2.0-flash"`
- [x] Task: Update `.env.dist` with new variables (do NOT touch `.env`)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: BORDERLINE Classification in Regex Filter [checkpoint: cc52f9e]

- [x] Task: Write tests for BORDERLINE verdict
  - [x] Test items that should be BORDERLINE (ambiguous todos)
  - [x] Test items that should remain ACTIONABLE (clear action verbs)
  - [x] Test items that should remain NOISE (obvious junk)
- [x] Task: Add `BORDERLINE` verdict to `obsidian.py` Verdict enum
- [x] Task: Refactor `classify_todo()` to emit `BORDERLINE` for ambiguous items
  - [x] Items with weak action signals but not clearly noise
  - [x] Items starting with "TODO" followed by meaningful content
  - [x] Items that have no clear action verb but substantial text (>20 chars)
- [x] Task: Update `format_report()` to show BORDERLINE items with 🤔 emoji
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Gemini LLM Triage Module [checkpoint: cc52f9e]

- [x] Task: Write tests for LLM triage (with mocked Gemini responses)
  - [x] Test that BORDERLINE items are sent to LLM with correct prompt
  - [ ] Test that LLM verdicts override regex BORDERLINE classification
  - [ ] Test that non-BORDERLINE items are NOT sent to LLM
  - [ ] Test error handling: API timeout, invalid response, rate limit
  - [x] Test hard-fail when SEPTOBER_GEMINI_API_KEY is missing
- [x] Task: Create `src/septober/llm_triage.py` module
  - [x] `triage_borderline_items(items: list[ObsidianTodo]) -> list[ObsidianTodo]`
  - [x] Build structured prompt with item context (title, source file, tags, date)
  - [x] Parse LLM JSON response: verdict, category, priority, clean_title, reasoning
  - [x] Batch items into a single LLM call (not one-per-item) for efficiency
  - [x] Handle Gemini API errors gracefully (retry once, then fail)
- [x] Task: Validate API key presence at startup — hard fail with clear message
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Dedup via API (Belt & Suspenders) [checkpoint: cc52f9e]

- [ ] Task: Write tests for dedup logic
  - [ ] Test dedup by `source_ref` (file:line)
  - [ ] Test dedup by obpbt hash (stored in `sys_notes`)
  - [ ] Test that new items pass dedup checks
  - [ ] Test that already-imported items are skipped
- [x] Task: Modify `to_septober_payload()` to store obpbt hash in `sys_notes`
- [x] Task: Create `fetch_existing_obsidian_refs()` function
  - [x] GET /api/todos/?source=obsidian&limit=500 (all statuses)
  - [x] Extract set of `source_ref` values
  - [x] Extract set of obpbt hashes from `sys_notes` field
- [x] Task: Integrate dedup into the sync pipeline
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 5: Pipeline Assembly & Just Commands [checkpoint: cc52f9e]

- [ ] Task: Write integration test for full pipeline (mocked LLM + mocked API)
  - [ ] Test end-to-end: obpbt output → parse → regex → LLM → dedup → ingest
  - [ ] Test idempotency: second run produces 0 new items
  - [ ] Test dry-run mode (no API calls)
- [x] Task: Rewrite `scripts/obsidian_scan.py` as the unified pipeline script
  - [x] Subprocess capture of `obpbt todos` (configurable command)
  - [x] Three-stage pipeline: regex → LLM → dedup+ingest
  - [x] Structured summary report at the end
  - [x] `--dry-run` flag for scan-only mode
  - [x] `--all` flag to pass `--all` to obpbt
- [x] Task: Add justfile commands
  - [x] `obsidian-scan` → dry run preview
  - [x] `obsidian-sync` → full pipeline
  - [x] `obsidian-sync-all` → full vault sweep
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 6: Final Verification & Documentation

- [x] Task: Run full test suite — all tests must pass (existing 37 + new) → 60/60 ✅
- [~] Task: Run `just obsidian-sync` end-to-end against real obpbt data (dev server)
- [ ] Task: Run it twice — verify 0 new items on second run (idempotency proof)
- [ ] Task: Update README.md with Obsidian sync documentation
- [ ] Task: Update CHANGELOG.md
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
