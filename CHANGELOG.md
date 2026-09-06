# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
