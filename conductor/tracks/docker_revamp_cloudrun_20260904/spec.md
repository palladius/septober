# Specification: Docker Revamp, Secrets Cleanup, and Cloud Run / GCE Deployment 2026

## Overview
Revamp Riccardo's Septober Rails application for 2026 deployment and operation:
1. Ensure credentials and passwords in YAML configuration files (`~/.septober.yml`, `bin/.septober.yml`) are not committed or exposed.
2. Fix `septober-cli-26` so that it reliably manages todos, supports fallback to environment variables (`SEPTOBER_SITE`, `SEPTOBER_USER`, `SEPTOBER_PASSWORD`), and handles timeout/connection errors gracefully.
3. Modernize the container build and deployment config to enable running either locally, on Cloud Run (with Cloud SQL Unix socket `/cloudsql/...`), or on a GCE instance (`septober26-mini`).

## Functional Requirements
- **FR-1: Configuration & Secret Hygiene**
  - Provide a safe `.septober.yml.example` template without credentials.
  - Add explicit `.gitignore` rules ensuring `.septober.yml` and any local credential files are never committed to git.
  - Support reading connection credentials from environment variables (`SEPTOBER_SITE`, `SEPTOBER_USER`, `SEPTOBER_PASSWORD`) in `septober-cli-26` as well as config file.
- **FR-2: CLI 2026 Resiliency**
  - `bin/septober-cli-26` must support `list`, `add`, `show`, `done`, and `toggle` subcommands.
  - Provide meaningful diagnostics when the remote host is unresponsive or returns HTTP 5xx.
  - Write automated tests (`tests/test_septober_cli_26.py`) verifying CLI parsing, auth headers, and mock API interactions.
- **FR-3: Docker & Cloud SQL Support**
  - Update `config/database.yml` and `entrypoint-8080.sh` to support Cloud SQL Unix sockets (`socket: /cloudsql/<INSTANCE_CONNECTION_NAME>`).
  - Configure build script / Cloud Build configuration for automated image generation without requiring local Docker daemon.
- **FR-4: Deployment Target**
  - Primary target: Cloud Run in project `7eptober` (or `ric-cccwiki` if Cloud SQL is reused).
  - Fallback option: Compute Engine `septober26-mini` (e2-micro/e2-small) with pre-configured container runtime.

## Acceptance Criteria
- [ ] No secrets or cleartext passwords committed in git repository.
- [ ] `bin/septober-cli-26` runs unit tests cleanly and handles network timeouts gracefully.
- [ ] Container image builds successfully and connects to database when supplied with valid credentials and socket/host.
- [ ] Live endpoint responds with HTTP 200 on health check and returns JSON for `/api/todos.json`.
