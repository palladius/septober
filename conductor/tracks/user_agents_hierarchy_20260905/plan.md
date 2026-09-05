# Implementation Plan: User Model Parent-Child Agent Hierarchy

## Phase 1: Database Migration & Schema Update (Cloud SQL) [checkpoint: b3c0f06]
- [x] Task: Generate ActiveRecord migration file `db/migrate/20260905140000_add_parent_id_and_agent_metadata_to_users.rb` [7503296]
  - [x] Add `parent_id`, `is_agent`, `agent_host`, `agent_icon`
  - [x] Add indexes on `parent_id` and `[:parent_id, :is_agent]`
- [x] Task: Apply migration to Cloud SQL MySQL instance `prod` [b3c0f06]
  - [x] Execute DDL statements safely on Cloud SQL `35.198.182.127`
- [x] Task: Verify schema changes [b3c0f06]
  - [x] Verify `DESCRIBE users;` returns new columns
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) [b3c0f06]

## Phase 2: User Model & Family Workspace Logic (TDD & Implementation) [checkpoint: 0368329]
- [x] Task: Write tests for User parent-child association and depth validation [0368329]
  - [x] Test that a user can have child agents
  - [x] Test that an agent cannot have its own child agents (single-level restriction)
- [x] Task: Implement parent-child associations and validations in `app/models/user.rb` [0368329]
  - [x] Add `belongs_to :parent`, `has_many :agents`, and `validate_single_level_depth`
  - [x] Add helper methods: `human?`, `agent?`, and `family_user_ids`
- [x] Task: Write tests for `Todo.for_family(user)` scope [0368329]
  - [x] Test that querying todos for a parent returns todos owned by parent and children
  - [x] Test that querying todos for a child agent returns only child todos
- [x] Task: Implement `for_family` scope in `app/models/todo.rb` and update `Api::TodosController` [0368329]
  - [x] Update `Api::TodosController#index` to use family workspace for human users
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) [0368329]

## Phase 3: Agent Seeding & End-to-End Authentication [checkpoint: 68537fb]
- [x] Task: Seed initial child agents under `rcarlesso` [68537fb]
  - [x] Provision `rcarlesso.ermete` (🚛, host: `mini-lobby`)
  - [x] Provision `rcarlesso.lobby` (🦞, host: `mini-lobby`)
  - [x] Provision `rcarlesso.pux` (🐾, host: `openclaw`)
- [x] Task: Verify agent authentication via HTTP Basic Auth [68537fb]
  - [x] Test authentication for all 3 agents with isolated credentials
- [x] Task: Verify task creation by agent and attribution in parent workspace [68537fb]
  - [x] Create todo as `rcarlesso.ermete` and verify `rcarlesso` sees it in family workspace
- [x] Task: Document agent onboarding in `doc/AGENT_ONBOARDING.md` [68537fb]
  - [x] Document ENV variables (`SEPTOBER_USER`, `SEPTOBER_PASSWORD`, `SEPTOBER_AGENT`)
  - [x] Provide ready-to-copy snippets for `~/.hermes/.env` and `~/.openclaw/.env`
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) [68537fb]

## Phase 4: CLI Enhancement & Cloud Run Deployment [checkpoint: a1b6108]
- [x] Task: Implement agent auto-detection and badge rendering in `septober-cli-26` [a1b6108]
  - [x] Support `--agent` flag and `SEPTOBER_AGENT` env variable
  - [x] Auto-detect identity when running inside Hermes or OpenClaw harness
  - [x] Render agent icons in `list` and `show`
- [x] Task: Write CLI tests for agent detection and icon rendering [a1b6108]
- [x] Task: Build and deploy updated container revision to Cloud Run [7cb9844]
  - [x] Submit Cloud Build patch image and deploy to `septober-mysql-2-3-12-prova`
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) [a1b6108]
