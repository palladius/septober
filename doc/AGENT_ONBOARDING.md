# 🤖 Septober 2026: Multi-Agent Subaccounts & Onboarding Guide

This document describes how to configure and onboard autonomous copilots (**Ermete Bottazzi**, **Lobby**, **Pux**) to interact directly with the Septober API and CLI.

---

## 🎯 Architectural Overview: Single-Level Agent Hierarchy

- **Master Human User:** `rcarlesso` (ID: 10, email: `rcarlesso@google.com`)
- **Child Agents:**
  | Agent | Username | User ID | Icon | Host | Email |
  |---|---|---|---|---|---|
  | **Ermete Bottazzi** | `rcarlesso.ermete` | `12` | 🚛 | `mini-lobby` | `palladiusbonton+ermete@gmail.com` |
  | **Lobby** | `rcarlesso.lobby` | `13` | 🦞 | `mini-lobby` | `palladiusbonton+lobby@gmail.com` |
  | **Pux** | `rcarlesso.pux` | `14` | 🐾 | `openclaw` | `palladiusbonton+pux@gmail.com` |

### Key Properties:
1. **Isolated Credentials:** Each agent has its own password hash and salt in MySQL. If an agent key is leaked, only that subaccount's password is rotated.
2. **Immutable Attribution:** Every todo created by an agent is stamped with that agent's native `user_id` at the HTTP Basic Auth layer.
3. **Unified Workspace:** When the master human (`rcarlesso`) lists todos, Septober automatically aggregates tasks from the master account and all child agents (`family_user_ids`).

---

## 🔑 Credentials & Agent Configuration

### 1. Ermete Bottazzi (Hermes on `mini-lobby`)
Add the following lines to `~/.hermes/.env`:

```bash
# Septober API Integration for Ermete Bottazzi
SEPTOBER_SITE="https://septober-mysql-2-3-12-prova-134140879415.europe-central2.run.app/api/"
SEPTOBER_USER="rcarlesso.ermete"
SEPTOBER_PASSWORD="septober-ermete-2026"
SEPTOBER_AGENT="ermete"
```

### 2. Lobby (OpenClaw on `mini-lobby`)
Add the following lines to `~/.openclaw/.env` (or Lobby launch agent):

```bash
# Septober API Integration for Lobby
SEPTOBER_SITE="https://septober-mysql-2-3-12-prova-134140879415.europe-central2.run.app/api/"
SEPTOBER_USER="rcarlesso.lobby"
SEPTOBER_PASSWORD="septober-lobby-2026"
SEPTOBER_AGENT="lobby"
```

### 3. Pux (OpenClaw / External)
Add the following environment variables to Pux's runtime environment:

```bash
# Septober API Integration for Pux
SEPTOBER_SITE="https://septober-mysql-2-3-12-prova-134140879415.europe-central2.run.app/api/"
SEPTOBER_USER="rcarlesso.pux"
SEPTOBER_PASSWORD="septober-pux-2026"
SEPTOBER_AGENT="pux"
```

---

## 🛠️ Local Centralized Registry: `~/.septober.local.yml`

On workstations where you want `septober-cli-26` to switch agents effortlessly, update `~/.septober.local.yml`:

```yaml
remote: &cloudrun
  site: https://septober-mysql-2-3-12-prova-134140879415.europe-central2.run.app/api/
  user: rcarlesso
  password: pwddilavoro

septober:
  <<: *cloudrun
  description: "Septober on Google Cloud Run (Authenticated)"

# Child Agent Profiles
agents:
  ermete:
    user: rcarlesso.ermete
    password: septober-ermete-2026
    icon: "🚛"
    host: "mini-lobby"
  lobby:
    user: rcarlesso.lobby
    password: septober-lobby-2026
    icon: "🦞"
    host: "mini-lobby"
  pux:
    user: rcarlesso.pux
    password: septober-pux-2026
    icon: "🐾"
    host: "openclaw"
```

---

## 🚀 How Agents & Humans Use the CLI

### 1. Auto-Resolution from Environment
If `SEPTOBER_USER` and `SEPTOBER_PASSWORD` are set in the agent's environment, `septober-cli-26` automatically authenticates as that agent:
```bash
septober-cli-26 add "Ripristinare gateway OpenClaw dopo blackout"
# -> Stamped with user_id: 13 (Lobby), where: mini-lobby
```

### 2. Switching Personas via `--agent`
```bash
# Act as Ermete
septober-cli-26 --agent ermete add "Controllo pressione pneumatici Iveco Stralis"

# Act as Lobby
septober-cli-26 --agent lobby add "Verifica heartbeat gateway"

# Act as Pux
septober-cli-26 --agent pux add "Analisi log anomali"
```

### 3. Viewing the Unified Family Workspace
When running as master user `rcarlesso`:
```bash
# View all family tasks (Riccardo + Ermete + Lobby + Pux)
septober-cli-26 list

# Filter tasks created specifically by an agent
septober-cli-26 list --agent ermete
```
