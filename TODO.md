# 🚀 SEPTOBER 2026 ROADMAP & TOP PRIORITIES

## 🌟 [P0/URGENT] User Model Parent-Child Agent Hierarchy (Genialata di Riccardo)
* **Status:** Designed & Specified in `doc/spec_user_agents_subaccounts.md`.
* **Concept:** Evolve `User` into a **single-level parent-child hierarchy** (`parent_id`) allowing Riccardo (`palladius`) to spawn $N$ autonomous agent copilots (`ermete`, `lobby`, `gamberone`, `antigravity-casa`, `antigravity-laptop`).
* **Key Specs:**
  1. **Strict 1-Level Depth:** Master Human -> Child Agents (no grandparents, no infinite loops).
  2. **Independent Credentials:** Each agent has its own `id`, `username` (`rcarlesso.ermete`), `email` (`palladiusbonton+ermete@gmail.com`), and isolated `password_hash`/`salt`.
  3. **Blast Radius Control:** If an agent bot goes crazy or leaks credentials, revoke/rotate only that agent's password; Riccardo's master login is unaffected.
  4. **Login-Level Attribution:** Agents authenticate natively via HTTP Basic Auth. Every todo created is stamped with that agent's `user_id`.
  5. **UI Badges:** Visual attribution badges in the web UI table (`[🚛 Ermete]`, `[🦞 Lobby]`, `[💻 Antigravity]`).
  6. **Unified Workspace:** Parent user automatically queries family workspace (`Todo.where(user_id: family_user_ids)`).
* **Reference Spec:** See `doc/spec_user_agents_subaccounts.md` for complete Rails migration, model validations, and UI blueprints.

## 🧠 [P1] Semantic File Dependencies (`semantic-deps.yml` + `GEMINI.md`)
* **Idea:** Link an explicit declarative dependency graph (e.g. `etc/semantic-deps.yml` referenced by `GEMINI.md` / `CLAUDE.md`) instructing LLM agents that edits to File A (e.g. `schema.rb`, API route, model) strictly require co-updating File B (e.g. serializers, migrations, docs, frontend types).
* **Objective:** Prevent silent out-of-sync agent edits (co-change propagation for AI coding agents).
* **Online State of the Art:** Investigated existing patterns (Cursor rules glob targeting, Aider RepoMap/PageRank, Claude Code CLAUDE.md file-specific rules, CodeQL semantic graphs, and Git co-change mining).

---

Docker
======

* Consider using RAILS_SERVE_STATIC_FILES to serve static files. See
  also Google ruby/CDN docs:
  https://cloud.google.com/appengine/docs/flexible/ruby/serving-static-files

Vulnerabilities
===============

* Try to merge github pull requuests and see if it still woks.
* https://github.com/palladius/septober/pulls
* If jquery is patched, verify the EDIT IN PLACE still works Riccardo

CLI
===

* septober tag 123 travels,shopping,riccardo
* TAGS work => 1 bug security, see github
* (Nice-to-have) Explore Charm/Bubbletea for a glamorous TUI (currently broken on ARM64/Ruby 3.4).

Facebook
========

* septober tag 123 travels,shopping,riccardo
* TAGS work => 1 bug security, see github
* Facebook
* FEATURE: Todo.Refactorize into:
  - provide maybe with ajax growing number of textfields (or maybe just 5)
  - with many fields

 Notable queries
 ===============

  - here (GPS/IP/address)
  - this computer (hostname matches)
  - assign a virtual relevance points (1..1000) depending on PRI, GPD closeness , overdueness, ... and sort over this!

Gemfile
=======

1. Vulnerabilities

2. sqlite3 gem

Hello! The sqlite3-ruby gem has changed it's name to just sqlite3.  Rather than
installing `sqlite3-ruby`, you should install `sqlite3`.  Please update your
dependencies accordingly.
