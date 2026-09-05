# Implementation Plan: Agent Visual Badges and Family View in Web UI

## Phase 1: Controller Family Aggregation & Unit Tests
- [ ] Task: Write tests for `TodosController#index` family aggregation
  - [ ] Verify parent user sees child agent todos in HTML index
- [ ] Task: Update `TodosController#index` in `app/controllers/todos_controller.rb`
  - [ ] Use `current_user.family_user_ids` for `:user_id` condition
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: View Helpers & ERB Badges (Zero CSS changes)
- [ ] Task: Implement agent badge helpers in `app/helpers/todos_helper.rb`
  - [ ] Helper `render_agent_first_row_icon(todo)`: renders robot + agent emoji
  - [ ] Helper `render_agent_badge(todo)`: renders agent pill badge for second row
- [ ] Task: Update `app/views/todos/_tr_line.html.erb` with agent badges
- [ ] Task: Update `app/views/todos/_show.html.erb` with agent attribution
- [ ] Task: Update `app/views/layouts/_nifty_login.html.erb` with user identity
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Container Build, Cloud Run Deploy & End-to-End Verification
- [ ] Task: Build updated Docker image and deploy to Cloud Run
- [ ] Task: Verify visually via `http://localhost:3000/` in browser
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
