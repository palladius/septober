# Specification: Agent Visual Badges and Family View in Web UI

## 1. Overview
Render visual agent attribution badges and emoji indicators in the Web UI of Septober without modifying any CSS files (which are concurrently being refactored by another agent). Ensure that when a human parent user (`palladius`) visits the Web UI (`todos/index`), todos created by child agents (`rcarlesso.ermete`, `rcarlesso.lobby`, `rcarlesso.pux`) are included in the view and clearly distinguished.

## 2. Functional Requirements
- **First Row (Todo Title & Name):**
  - If the todo is authored by an agent (`todo.user.try(:is_agent?)`):
    - Display a robot indicator and the agent's emoji icon (e.g. `🤖 🚛` or `🤖 todo.user.agent_icon`).
- **Second Row (Metadata):**
  - In `render_todo_second_row(todo)` / `todos/_tr_line.html.erb`:
    - Display the full agent attribution badge: `[<icon> <AgentName> @ <agent_host>]`.
- **Todo Detail View (`todos/_show.html.erb`):**
  - Display author / copilot identity:
    - If human: `👤 palladius`
    - If agent: `🤖 <agent_icon> <username> (Host: <agent_host>, Copilot of <parent_username>)`.
- **Web Controller (`TodosController#index`):**
  - Query across `current_user.family_user_ids` instead of strictly `current_user.id`, enabling full family workspace aggregation in the browser.
- **Header (`_nifty_login.html.erb`):**
  - Show the current logged-in identity badge (e.g. `👤 Palladius` or `<icon> <agent_name>`).

## 3. Non-Functional Requirements & Constraints
- **STRICT NO CSS RULE:** Do NOT modify `public/stylesheets/*.css` or any stylesheets. Use clean HTML structure and semantic class names so the concurrent CSS revamp will style them naturally.
- Maintain backward compatibility with existing projects and todo rendering helpers.

## 4. Acceptance Criteria
- Loading `http://localhost:3000/` as `palladius` displays both personal todos and todos created by child agents.
- Agent todos display the robot + agent emoji on the first line, and agent pill badge on the second row.
- Zero edits to CSS files.
