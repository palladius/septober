# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-09-06

### Major Modernization (Rails 8 & Native PWA)
- **Framework & Ruby Upgrade**: Leapfrogged from Rails 3.0.3 (Ruby 1.9.3) to **Rails 8.0.4** running natively on **Ruby 3.4.5**.
- **Solid Suite**: Configured `solid_cache`, `solid_queue`, and `solid_cable` database-backed infrastructure.
- **Propshaft & Importmaps**: Modern asset pipeline without Node.js or Webpack.
- **Native PWA Support**:
  - Web App Manifest (`/manifest`) with `display: standalone` and adaptive app icons.
  - Service Worker (`/service-worker`) for offline asset shell caching and future web push support.
  - "Add to Dock" macOS and Linux desktop launcher readiness.
  - 20-year persistent encrypted authentication ("Remember Me on this Mac / Device").
- **Touch & Pointer Gesture Engine**:
  - Stimulus `swipe_controller.js` on every todo item: swipe-right to complete (green), swipe-left to snooze/procrastinate 7 days (amber).
  - Turbo streams for instant zero-reload card updates.
- **Multi-Agent Hierarchy Preservation**:
  - Retained `parent_id`, `is_agent`, `agent_icon`, `agent_host`, and `family_user_ids`.
  - Copilot badges (🚛 Ermete, 🦞 Lobby, 🐾 Pux, 🤖 generic) and filter chips.
  - Modernized REST JSON API (`/api/todos`) with HTTP basic auth for CLI and Telegram/Hermes agents.
- **Containerization**: Modern production `Dockerfile` powered by Thruster & Kamal.

## [2.5.04] - 2026-09-06

### Documentation & Architecture
- **Rails 8 + PWA Strategy**: Added comprehensive architectural strategy blueprint in `doc/STRATEGY_RAILS8_PWA.md` detailing the migration path to Ruby 3.4+ / Rails 8.0, native PWA "Add to Dock", touch gesture support, and Solid suite integration.
- **Convenience Symlink**: Symlinked `docs` -> `doc`.

## [2.5.03] - 2026-09-06

### Improved
- **In-Place Editing Experience**: Converted todo description in-place editing to a responsive, multi-line `textarea` with automatic text wrapping (`overflow-wrap: break-word`, `white-space: pre-wrap`) and modern `field-sizing: content` support.
- **Form Controls & Modals**: Polished in-place edit containers with theme-aware elevation, subtle borders, focus glow, and modernized Ok/Cancel buttons.
- **Action Icons & Micro-Animations**: Added smooth spring transforms, hover scaling, priority arrow micro-nudges, and checkmark glow effects.

## [2.5.02] - 2026-09-06

### Added
- **Autonomous Agent Badges**: Render first-row emoji (`🤖 <icon>`) and second-row author badge (`[<icon> <Agent> @ <host>]`) for copilots.
- **Header Upright Navigation**: Added active agents synoptic list with filter links (`/todos?agent_id=<id>`) and `+ New Agent` shortcut.
- **Sub-Agent Provisioning UI**: Embedded copilots table and self-service provisioning form on `/user/edit`.
- **Sub-Agent Provisioning Skill**: Documented subagent architecture, environment configurations, and auth conventions in `septober-subagent-provisioning`.

### Changed
- **Sub-Agent Naming Convention**: Standardized agent usernames to `palladius.<slug>` (`palladius.ermete`, `palladius.lobby`, `palladius.pux` on host `pupurabbux`).
- **Dark Mode Compatibility**: Removed hardcoded light backgrounds from tables, badges, and documentation code blocks.

## [2.5.01] - 2026-09-05

### Fixed
- **Header Title Clipping**: Corrected `.header_table` navigation selector scoping to avoid clashing with the main application title.
- **Banner Alignment**: Fixed vertical centering (`background-position: center center !important`) for the 2026 developer desk header.

### Documentation
- Updated Conductor tracks and semantic dependency blueprints.

## [2.5.00] - 2026-09-05

### Added
- **Dark First Architecture**: Default deep dark theme with semantic CSS variables and full Light mode adaptation.
- **Client-Side Theme Toggle**: Interactive floating toggle in bottom-left (`Dark Mode` / `Light Mode`) with `localStorage` persistence.
- **Ultra-Wide 5:1 Header Banner**: Reimagined desk workspace banner generated with Nano Banana (2800x560 px).
- **Glassmorphic Floating Badge**: Preserved and modernized "Powered by Palladius" floating pill badge in bottom-right.
- **Project Color Overrides**: Legibility enhancements mapping dark-theme inline colors (blue to sky-blue, black to crisp white) and light-theme colors.

### Changed
- **Typography & Layout**: Adopted Modern Web Guidance specs (`text-wrap: balance` on headings, `text-wrap: pretty` on copy, responsive elastic card container).
- **Flashy Header Title**: Super bold 2.6rem gradient title with neon glow filter and uppercase styling.
- **Task List & Badges**: Soft pill badges for overdue tasks and priority chips.
- **Action Icons**: Polished rounded icon wrappers with hover elevation.

## [2.4.04] - 2026-01-17
### Changed
- Maintenance release: version bump and blueprint update.

## [2.4.03] - 2022-01-08
### Changed
- Faster Dockerfile caching based on Gemfile changes.
