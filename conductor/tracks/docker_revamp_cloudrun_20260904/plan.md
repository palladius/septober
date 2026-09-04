# Implementation Plan: Docker Revamp, Secrets Cleanup, and Cloud Run / GCE Deployment 2026

## Phase 1: Configuration & Secret Sanitization
- [ ] Task: Create `.septober.yml.example` with placeholders and documentation
- [ ] Task: Ensure `.gitignore` ignores all variants of `.septober.yml` and local secrets
- [ ] Task: Audit repository for any tracked sensitive credentials
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: CLI 2026 Resiliency & Testing
- [ ] Task: Add test suite `test/test_septober_cli_26.py` covering arguments, auth, and error handling
- [ ] Task: Update `bin/septober-cli-26` with environment variable overrides and improved timeout diagnostics
- [ ] Task: Verify test suite passes with `pytest` / `python3 -m unittest`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Containerization & Cloud SQL Socket Support
- [ ] Task: Update `config/database.yml` to support `DATABASE_SOCKET` for Cloud SQL Unix socket
- [ ] Task: Ensure `cloudbuild.yaml` or build script produces deployable image
- [ ] Task: Verify container entrypoint configuration
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Remote Deployment & Live Verification
- [ ] Task: Configure Cloud Run service (or GCE `septober26-mini` VM)
- [ ] Task: Verify Cloud SQL connectivity (either via `--add-cloudsql-instances` or authorized IP)
- [ ] Task: Test live endpoint using `bin/septober-cli-26 list`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
