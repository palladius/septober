# Implementation Plan: Docker Revamp, Secrets Cleanup, and Cloud Run / GCE Deployment 2026

## Phase 1: Configuration & Secret Sanitization [checkpoint: db0e38b]
- [x] Task: Create `.septober.yml.example` with placeholders and documentation db0e38b
- [x] Task: Ensure `.gitignore` ignores all variants of `.septober.yml` and local secrets db0e38b
- [x] Task: Audit repository for any tracked sensitive credentials db0e38b
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) db0e38b

## Phase 2: CLI 2026 Resiliency & Testing [checkpoint: 98bf448]
- [x] Task: Add test suite `test/test_septober_cli_26.py` covering arguments, auth, and error handling 98bf448
- [x] Task: Update `bin/septober-cli-26` with environment variable overrides and improved timeout diagnostics 98bf448
- [x] Task: Verify test suite passes with `pytest` / `python3 -m unittest` 98bf448
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) 98bf448

## Phase 3: Containerization & Cloud SQL Socket Support [checkpoint: 1a11e58]
- [x] Task: Update `config/database.yml` to support `DATABASE_SOCKET` for Cloud SQL Unix socket 1a11e58
- [x] Task: Ensure `cloudbuild.yaml` or build script produces deployable image 1a11e58
- [x] Task: Verify container entrypoint configuration 1a11e58
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) 1a11e58

## Phase 4: Remote Deployment & Live Verification [checkpoint: 754ab8d]
- [x] Task: Configure Cloud Run service (or GCE `septober26-mini` VM) 754ab8d
- [x] Task: Verify Cloud SQL connectivity (either via `--add-cloudsql-instances` or authorized IP) 754ab8d
- [x] Task: Test live endpoint using `bin/septober-cli-26 list` 754ab8d
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) 754ab8d
