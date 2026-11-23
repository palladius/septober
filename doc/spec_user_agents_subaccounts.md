# 🚀 Specification: User Model Parent-Child Agent Hierarchy (Septober 2026)
**Author:** Riccardo Carlesso & Ermete Bottazzi 🚛  
**Date:** September 4, 2026  
**Status:** Approved Architectural Plan / Ready for Implementation  

---

## 🎯 Executive Summary & Motivation
Riccardo operates multiple autonomous AI copilots across different workstations and cloud hosts:
- **Ermete Bottazzi** (Romagna Trucking / Telegram primary messenger)
- **Lobby / OpenClaw** (Autonomous operations daemon on mini-lobby)
- **Gamberone** (Heavy agentic workflows)
- **Anti-Gravity (Home Workstation)**
- **Anti-Gravity (Laptop / Work)**

### 💡 The Big Idea (Genialata di Riccardo):
Transform Septober's `User` model into a **single-level parent-child hierarchy**:
1. **Parent User (Master):** Riccardo (`palladius` / `rcarlesso`).
2. **Child Users (Sub-Identities):** Up to $N$ autonomous agents directly parented to Riccardo.
3. **Single-Level Depth:** Strictly `Parent -> Children`. No grandparents, no infinite nesting.
4. **Native Authentication:** Each agent has its own unique `username`, `email`, and separate `password_hash`/`salt`.
5. **Security Isolation:** If an agent key leaks or an agent goes haywire, Riccardo simply changes that agent's password without affecting his master account or other agents.
6. **Immutable UI Attribution:** Authentication happens at the login layer (HTTP Basic Auth or session). Every todo created by an agent is stamped with that agent's `user_id`, allowing the UI to render badges like `[Ermete 🚛]` or `[Pinco Pallo 🤖]`.

---

## 🏗️ 1. Database Schema Changes

### Migration: `AddParentIdAndAgentMetadataToUsers`
```ruby
class AddParentIdAndAgentMetadataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :parent_id, :integer
    add_column :users, :is_agent, :boolean, default: false, null: false
    add_column :users, :agent_host, :string # e.g. "mini-lobby", "macbook-m1", "cloudrun"
    add_column :users, :agent_icon, :string # e.g. "🚛", "🦞", "💻"
    
    add_index :users, :parent_id
    add_index :users, [:parent_id, :is_agent]
  end
end
```

---

## 🧩 2. User Model Logic (`app/models/user.rb`)

```ruby
class User < ActiveRecord::Base
  # ... existing attributes ...
  attr_accessible :parent_id, :is_agent, :agent_host, :agent_icon
  
  # Self-referential parent-child association
  belongs_to :parent, class_name: "User", foreign_key: "parent_id"
  has_many :agents, class_name: "User", foreign_key: "parent_id", dependent: :destroy
  
  # Strict single-level depth validation (No Grandparents!)
  validate :validate_single_level_depth
  
  def validate_single_level_depth
    if parent_id.present?
      if parent && parent.parent_id.present?
        errors.add(:parent_id, "Cannot create nested agent hierarchies: single-level only (no grandparents allowed).")
      end
      if is_agent == false
        errors.add(:is_agent, "Child users must have is_agent: true")
      end
    end
  end
  
  # Helper to retrieve entire family workspace (Parent + all child agents)
  def family_user_ids
    if parent_id.present?
      [parent_id] + parent.agents.pluck(:id)
    else
      [id] + agents.pluck(:id)
    end
  end
  
  def all_family_todos
    Todo.where(user_id: family_user_ids)
  end
  
  def display_identity_badge
    if is_agent?
      "#{agent_icon || '🤖'} #{username} (#{agent_host || 'agent'})"
    else
      "👤 #{username}"
    end
  end
end
```

---

## 📧 3. Agent Naming & Email Strategy

To ensure global uniqueness, easy identification, and resilience when parent emails update:

### Recommended Pattern: Sub-addressing / Slug
1. **Username:** `<parent_username>.<agent_slug>`  
   *Examples:*  
   - `rcarlesso.ermete`  
   - `rcarlesso.lobby`  
   - `rcarlesso.antigravity-home`  
   - `rcarlesso.antigravity-laptop`  

2. **Email Address:**  
   - Primary: `<parent_email_prefix>+<agent_slug>@gmail.com`  
     *Example:* `palladiusbonton+ermete@gmail.com`  
   - Secondary / Synthetic: `<agent_slug>@agents.septober.internal`  
   - *Advantage:* Standard RFC-compliant plus-addressing routing directly to Riccardo's inbox for system notifications, without requiring external mailbox setups.

3. **Cascade on Parent Update:**  
   Because records are relational (`belongs_to :parent`), changing the parent's email does **not** break the database association or orphaned agent records!

---

## 🎨 4. UI & Attribution Features

1. **Todo List Table:**
   - Add a creator badge column:
     - If created by parent: subtle tag or omitted.
     - If created by agent: pill badge with agent icon:  
       `<span class="badge badge-agent">🚛 Ermete</span>`  
       `<span class="badge badge-agent">🦞 Lobby</span>`  
       `<span class="badge badge-agent">💻 Antigravity (Casa)</span>`

2. **Login & Session Awareness:**
   - In `ApplicationController`:
     ```ruby
     def current_user_badge
       current_user.display_identity_badge
     end
     ```
   - Header shows: `Logged in as: 🚛 rcarlesso.ermete (Copilot of Riccardo)` with quick-switch or master logout.

---

## 🛡️ 5. Key Operational Benefits
1. **Blast Radius Reduction:** If an agent's terminal or local `.septober.yml` is compromised, simply run:
   ```ruby
   agent = User.find_by_username("rcarlesso.ermete")
   agent.update!(password: SecureRandom.hex(16))
   ```
   Riccardo's master login remains completely untouched.
2. **True Auditing:** Complete clarity over automated vs manual human todo creation.
3. **Rate-Limiting & Quotas:** Ability to throttle specific hyperactive agent processes without locking out Riccardo.
