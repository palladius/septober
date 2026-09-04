---
sumaron_version: 0.1.0
date: 2026-09-04
path: /Users/riccardo/bin/sumaron
hostname: mini-lobby
timestamp: 2026-09-04T08:23:00+02:00
model: gemini-flash-latest
files:
  - README.md
  - TODO.md
  - docker-experiments/01-septober-vintage-volume/README.md
  - docker-experiments/02-septober-vintage-volume-singlerepo/README.md
  - docker-experiments/septober-oldtest/README.md
  - docker-experiments/septober-vintage-mysql-env/README.md
  - public/404.html
  - public/422.html
  - public/500.html
  - public/javascripts/README.md
  - septober26-spec.md
  - walkthrough.md
---

# 📅 Septober Codebase Summary

**Septober** is a vintage Ruby on Rails (v3.x / Ruby 1.9.3) task and project management application created by Riccardo Carlesso (`palladius`). The name humorously originates from a Bolognese slang term for a non-existent month used when procrastinating on low-priority tasks. The codebase is currently being preserved and modernized into a context-aware backend ("Living To-Dos") for AI agents.

---

### 🚀 Key Components & Features

* **Task & Project Engine (Rails 3)**:
  * Manages todos with attributes such as projects, priorities, due dates, geo/location (`where`), URLs, tags, procrastination flags, and dependency tracking.
  * Features smart natural language parsing for quick creation (e.g., extracting due dates and priorities from regex patterns like `"buy milk by tomorrow!!"`).
* **CLI Interface (`bin/septober`)**:
  * Command-line tool (distributed via the `ric` / `septober` gems) enabling listing, adding, viewing, and resolving tasks locally or over HTTP APIs.
  * Configured via a local `~/.septober.yml` file.
* **Modernization & AI Integration Spec (`septober26-spec.md`)**:
  * A 2026 revival RFC designed to integrate Septober with an agentic framework (**Hermes Agent / Ermete Bottazzi**).
  * Repurposes the rich Rails data schema (`sys_notes`, `source`, `where`, `url`) to capture contextual todos directly from Telegram voice/text prompts.
  * Targets deployment on **Google Cloud Run** in project `7eptober` backed by **GCP Cloud SQL (MySQL)**.

---

### 🐳 Infrastructure & Dockerization

* **Database Strategy**:
  * **Development**: Lightweight local SQLite3 (`db/development.sqlite3`).
  * **Production / Staging**: MySQL via standard environment variables (`DATABASE_HOST`, `DATABASE_USER`, `DATABASE_PASSWORD`, etc.).
* **Docker Setup & Experiments (`docker-experiments/`)**:
  * Accommodates the vintage Ruby 1.8/1.9 and Rails 3 runtime dependencies that are otherwise difficult to run natively on modern OS/ARM64 platforms.
  * Uses Docker volumes for live local editing (`02-septober-vintage-volume-singlerepo/`).
  * Provides `docker-compose.yml` configurations for fast local testing with MySQL.

---

### 📁 Notable Files & Assets

* **`README.md`**: Main project overview, installation guides, Docker workflows, and CLI usage.
* **`septober26-spec.md`**: Architectural specification for deploying on Cloud Run and integrating with LLM/agentic workflows.
* **`walkthrough.md`**: Interactive Google Cloud Shell onboarding guide.
* **`TODO.md`**: Backlog of security patches, UI improvements (edit-in-place jQuery fixes), gem updates (`sqlite3-ruby` $\rightarrow$ `sqlite3`), and experimental TUI tools (Bubbletea).
* **`public/`**: Standard Rails static assets and error pages (`404`, `422`, `500`), plus debugging notes for asset routing (`public/javascripts/README.md`).