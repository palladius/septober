# How I Upgraded from Rails 5 (Legacy 3.0) to Rails 8.0 with Antigravity

**Date:** November 28, 2025
**Author:** Antigravity (AI Assistant) & Riccardo Carlesso

This document details the journey of migrating "Septober," a legacy Rails application, to Rails 8.0 using a "Fresh Start" approach.

## The Challenge

The starting point was a Rails application that was:
*   Originally built on Rails 3.0.3 (Ruby 1.9.3).
*   Partially upgraded locally to Rails 5.2.3 (Ruby 3.1.2).
*   Heavily reliant on legacy patterns like `attr_accessible` and a custom gem called `ric`.
*   Suffering from broken features (CLI, Search) and an outdated UI.

The goal was to leapfrog to **Rails 8.0** and give the app a modern facelift, while preserving its core logic and data.

## The Strategy: Fresh Start

Instead of an incremental upgrade (which would have been painful given the version gap), we chose a **Fresh Start** strategy:
1.  Create a new Rails 8 app in a subdirectory (`septober_v8`).
2.  Port models and logic, adapting them to modern standards.
3.  Rebuild controllers and views from scratch using Rails 8 defaults.
4.  Migrate data (if needed, though we started with a fresh DB for testing).

## Step-by-Step Execution

### 1. Setting the Foundation
We initialized a new Rails 8 application. We encountered a conflict with the existing Rails app in the parent directory, which we solved by temporarily renaming the old config files.

### 2. Porting the Core (Models)
We moved `User`, `Project`, and `Todo` models. Key changes included:
*   **Strong Parameters:** Replaced `attr_accessible` with `params.require(:model).permit(...)` in controllers.
*   **Gem Extraction:** The `ric` gem had custom logic (`acts_as_carlesso`). We extracted this into a local concern (`app/models/concerns/acts_as_carlesso.rb`) to remove the external dependency.
*   **Modern Syntax:** Updated validations and scopes to Rails 8 standards.
*   **Fixing Associations:** Added `dependent: :destroy` to `User` and `Project` to prevent orphaned records, a bug discovered during testing.

### 3. The Facelift (Views & UI)
We didn't just copy the old ERB files. We rebuilt the UI using **Vanilla CSS** and modern Rails 8 conventions (Hotwire/Turbo).
*   **Layout:** Created a clean, responsive layout with a dark/light mode friendly color palette.
*   **Components:** Designed reusable cards for Todos and Projects.
*   **UX Improvements:** Added visual cues for "Done" items and priority indicators.

### 4. Fixing the Search Engine
The old search relied on a gem. We implemented a simple but effective search scope in the `ActsAsCarlesso` concern.
*   **Bug Encountered:** `SQLite3::SQLException: ambiguous column name: name`.
*   **The Fix:** We updated the search scope to explicitly prefix column names with the table name (e.g., `todos.name`), resolving the ambiguity when joining tables.

### 5. The CLI Tool
We created a new CLI script (`bin/septober`) that interacts with the Rails app via a JSON API.
*   **API:** Added `format.json` support to `TodosController`.
*   **Script:** The Ruby script uses `Net::HTTP` to fetch and display todos, proving the concept of a headless interface.

## How Antigravity Helped (The AI Advantage)

This wasn't just code generation; it was an interactive pair programming session.

*   **Browser Subagent:** I used a headless browser to navigate the running local server (`http://localhost:42042`).
    *   **Link Checking:** I crawled the site to ensure all navigation links worked.
    *   **Error Hunting:** When I found a broken link (e.g., `/users/2/edit`), I captured the Rails error page ("No view template"), which told me exactly which view was missing.
    *   **Verification:** I signed up a new user (`riccardo_antigravity`) through the UI to verify the full authentication flow.
*   **Terminal Integration:** I ran `rails runner` scripts to verify database states and debug model logic without needing a UI.
*   **Proactive Fixes:** When the user mentioned a bug (like the search issue), I immediately tailed the logs, identified the SQL error, and applied a fix.

## Conclusion

We successfully transformed a legacy Rails 3/5 app into a modern Rails 8 application in a single session. The new app is faster, cleaner, and easier to maintain, with no external legacy gem dependencies.

**Next Steps:**
*   Import legacy data.
*   Enhance the CLI with full CRUD capabilities.
*   Deploy to production!
