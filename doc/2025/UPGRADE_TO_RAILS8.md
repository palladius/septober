# Upgrade to Rails 8 (2025)

Tracking the migration of Septober from Rails 5.2 (originally 3.0) to Rails 8.0.

## Status: COMPLETED

## Action Items

- [x] Create new Rails 8 app (`septober_v8`)
- [x] **Models Migration**
    - [x] Port `User` model
    - [x] Port `Project` model
    - [x] Port `Todo` model
    - [x] Remove `attr_accessible` (use Strong Params in controllers)
    - [x] Remove `acts_as_carlesso` / Extract `ric` gem logic to `lib/`
    - [x] Add `acts-as-taggable-on` (or alternative)
- [x] **Database Setup**
    - [x] Create migrations for new schema (matching old one)
    - [x] Migrate DB
- [x] **Controllers Migration**
    - [x] Port `TodosController`
    - [x] Port `ProjectsController`
    - [x] Implement Strong Parameters
- [x] **Views Facelift**
    - [x] Create new Layout (Hotwire/Turbo enabled)
    - [x] Port/Redesign Todo views
    - [x] Port/Redesign Project views
- [x] **CLI & API**
    - [x] Ensure API endpoints exist for CLI (JSON/XML added to TodosController)
    - [x] Create/Port CLI tool (Basic script in `bin/septober`)
- [x] **Verification**
    - [x] Verify `rails server` starts
    - [x] Verify CRUD operations (via console/provisioning)
    - [x] Verify Search (Implemented in Controller/View)
