# Specification: User Model Parent-Child Agent Hierarchy & Schema Migration

## 1. Overview
Transform Septober's `User` model into a single-level parent-child hierarchy (`parent_id`) allowing the master human user (`rcarlesso` / `palladius`) to spawn autonomous AI copilot sub-accounts (`ermete`, `lobby`). This enables isolated credentials, independent blast radiuses, immutable login-level task attribution, and unified family workspace visibility.

## 2. Functional Requirements
- **Database Schema Migration (`AddParentIdAndAgentMetadataToUsers`):**
  - Add `parent_id` (integer, indexed) to `users` table.
  - Add `is_agent` (boolean, default: false, null: false) to `users` table.
  - Add `agent_host` (string, e.g. "mini-lobby") to `users` table.
  - Add `agent_icon` (string, e.g. "🚛", "🦞") to `users` table.
  - Composite index on `[:parent_id, :is_agent]`.
- **Model Hierarchy & Validations (`app/models/user.rb`):**
  - Self-referential associations: `belongs_to :parent, class_name: "User"` and `has_many :agents, class_name: "User", foreign_key: "parent_id"`.
  - Strict 1-Level Depth Validation: Agents cannot have sub-agents (no grandparents or deep recursion).
  - Helper methods: `human?`, `agent?`, `family_user_ids`.
- **Unified Family Workspace (`app/models/todo.rb` & Controllers):**
  - Add scope `for_family(user)` in `Todo`: returns tasks belonging to `user` plus all child agents if `user` is human.
  - CLI and API endpoints allow filtering by specific agent while showing family tasks by default.
- **Initial Agent Seeding / Provisioning:**
  - Provision sub-account `rcarlesso.ermete` (Icon: 🚛, Host: `mini-lobby`).
  - Provision sub-account `rcarlesso.lobby` (Icon: 🦞, Host: `mini-lobby`).
  - Provision sub-account `rcarlesso.pux` (Icon: 🐾, Host: `openclaw`).
- **Agent Identity & ENV Auto-Resolution (`septober-cli-26`):**
  - Priority resolution order for credentials:
    1. Explicit `SEPTOBER_USER` and `SEPTOBER_PASSWORD` environment variables.
    2. Explicit `--agent <name>` CLI flag or `SEPTOBER_AGENT` environment variable (resolving from `~/.septober.local.yml` agent section).
    3. Auto-detected harness identity: if running under Hermes (`HARNESS_NICKNAME="Ermete Bottazzi"`), auto-select `rcarlesso.ermete`. If under OpenClaw, auto-select `rcarlesso.lobby` or `rcarlesso.pux`.
    4. Fallback to master human account (`rcarlesso`).
- **Documentation (`doc/AGENT_ONBOARDING.md`):**
  - Step-by-step guide on how to configure each agent's environment file (`~/.hermes/.env`, `~/.openclaw/.env`, etc.) with copy-paste snippets.

## 3. Non-Functional Requirements
- Backward compatibility with existing Rails 3 authentication (`User.authenticate`).
- Zero downtime schema migration on Cloud SQL MySQL (`prod`).
- No password or secret leakage in git tracking.

## 4. Acceptance Criteria
- Migration executes cleanly against Cloud SQL `prod` without disrupting existing user/todo records.
- User validations reject recursive or multi-level agent nesting.
- `rcarlesso` queries return all family tasks, including todos created by child agents.
- Agent accounts authenticate independently via HTTP Basic Auth.
- `septober-cli-26` displays agent attribution icons in list/show.

## 5. Out of Scope
- Multi-tier recursive hierarchies (strictly 1-level parent -> children).
- Web UI frontend redesign (handled in a separate track; this track focuses on DB, model, API, and CLI).
