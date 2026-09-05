# Implementation Plan: User Model Parent-Child Agent Hierarchy

## Phase 1: Database Migration & Schema Update (Cloud SQL)
- [ ] Task: Generate ActiveRecord migration file `db/migrate/20260905140000_add_parent_id_and_agent_metadata_to_users.rb`
  - [ ] Add `parent_id`, `is_agent`, `agent_host`, `agent_icon`
  - [ ] Add indexes on `parent_id` and `[:parent_id, :is_agent]`
- [ ] Task: Apply migration to Cloud SQL MySQL instance `prod`
  - [ ] Execute DDL statements safely on Cloud SQL `35.198.182.127`
- [ ] Task: Verify schema changes
  - [ ] Verify `DESCRIBE users;` returns new columns
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: User Model & Family Workspace Logic (TDD & Implementation)
- [ ] Task: Write tests for User parent-child association and depth validation
  - [ ] Test that a user can have child agents
  - [ ] Test that an agent cannot have its own child agents (single-level restriction)
- [ ] Task: Implement parent-child associations and validations in `app/models/user.rb`
  - [ ] Add `belongs_to :parent`, `has_many :agents`, and `validate_single_level_depth`
  - [ ] Add helper methods: `human?`, `agent?`, and `family_user_ids`
- [ ] Task: Write tests for `Todo.for_family(user)` scope
  - [ ] Test that querying todos for a parent returns todos owned by parent and children
  - [ ] Test that querying todos for a child agent returns only child todos
- [ ] Task: Implement `for_family` scope in `app/models/todo.rb` and update `Api::TodosController`
  - [ ] Update `Api::TodosController#index` to use family workspace for human users
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Agent Seeding & End-to-End Authentication
- [ ] Task: Seed initial child agents under `rcarlesso`
  - [ ] Provision `rcarlesso.ermete` (🚛, host: `mini-lobby`)
  - [ ] Provision `rcarlesso.lobby` (🦞, host: `mini-lobby`)
- [ ] Task: Verify agent authentication via HTTP Basic Auth
  - [ ] Test authentication as `rcarlesso.ermete` with isolated credentials
- [ ] Task: Verify task creation by agent and attribution in parent workspace
  - [ ] Create todo as `rcarlesso.ermete` and verify `rcarlesso` sees it in family workspace
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: CLI Enhancement & Cloud Run Deployment
- [ ] Task: Write CLI tests for agent icon rendering
  - [ ] Test that list/show output renders `[🚛 Ermete]` badge when todo belongs to an agent
- [ ] Task: Update `septober-cli-26` to display agent attribution badges
  - [ ] Render agent icons in `list` and `show`
- [ ] Task: Build and deploy updated container revision to Cloud Run
  - [ ] Submit Cloud Build patch image and deploy to `septober-mysql-2-3-12-prova`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
