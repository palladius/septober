# Track: UI Agent Badges, Copilot Upright Navigation & Sub-Agent Provisioning

- **Branch**: `feat/ui-agent-badges`
- **Worktree**: `.worktrees/ui-agent-badges`
- **Status**: Complete / Verified
- [Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Metadata](./metadata.json)

## Summary
Build visual UI representation for autonomous copilots/sub-agents connected to personal account `palladius` (ID: 1):
1. **First Row Icon**: Render `🤖 <agent_icon>` in todo title when created by agent.
2. **Second Row Badge**: Render `[<agent_icon> <AgentName> @ <host>]`.
3. **Upright Navigation**: Synoptic list of agents with filter links (`todos?agent_id=<id>`) and `+ New Agent` link.
4. **User Profile Edit (`/user/edit`)**: Copilots table showing task counts and an inline sub-agent provisioning form.
5. **Sub-Agent Provisioning Skill**: Documented under `~/git/skillume/gemini-cli-palladius-private-goodies/skills/septober-subagent-provisioning/SKILL.md` and linked in `GEMINI.md`.
6. **Zero CSS Modification Constraint**: Strictly maintained.
