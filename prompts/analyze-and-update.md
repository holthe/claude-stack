# Task: Analyze Repositories and Generate/Update Subagent Architecture

## Overview
This prompt analyzes ONLY the repositories configured in `~/git/claude-stack/config/repos.conf`, discovers patterns, audits existing agents for drift, identifies gaps, and generates an optimal subagent architecture for a React + Supabase + Capacitor + shadcn/ui stack.

## Settings

First, read the settings file to check for model override:
```bash
cat ~/git/claude-stack/config/settings.conf
```

If `MODEL_OVERRIDE` is set (not commented), use that model for ALL agents regardless of tier. Valid values: `opus`, `sonnet`, `haiku`. If not set or commented out, use the default tiered approach (sonnet/haiku based on complexity).

**Store this setting and apply it in Phase 8 when creating/updating agents.**

## Repositories to Analyze

**IMPORTANT: Only analyze repositories listed in `~/git/claude-stack/config/repos.conf`.**

First, read the config file and extract the repository paths:
```bash
cat ~/git/claude-stack/config/repos.conf
```

Analyze ONLY those repositories. Do NOT scan ~/git/ or any other directories. If a path in the config doesn't exist, skip it and note it in the report.

---

## Pre-Analysis: Existing Agent Inventory

Before analyzing repos, catalog what already exists:

1. Scan `~/.claude/agents/` for user-level agents
2. Scan `~/git/claude-stack/agents/` if it exists
3. For each configured repo, scan `[repo]/.claude/agents/` for project agents
4. For each existing agent, extract:
   - Name and description
   - Model setting
   - Tools allowed
   - Key knowledge areas
   - Last modified date (from filesystem)
   - Patterns/file paths it references
   - Which repos it mentions

Create: `~/git/claude-stack/analysis/existing-agents.md`

---

## Phase 1: Deep Discovery

For each repository listed in `~/git/claude-stack/config/repos.conf`:

### 1.1 Configuration Files
- Read package.json (dependencies, scripts, versions)
- Read tsconfig.json (TypeScript configuration)
- Read capacitor.config.ts (mobile settings, plugins)
- Read vite.config.ts or equivalent build config
- Read tailwind.config.js (theme, plugins)
- Read .env.example (environment variables used)
- Read supabase/config.toml if present

### 1.2 Source Code Analysis
- Map complete src/ directory structure
- Identify component patterns (naming, organization)
- Analyze imports to understand dependency relationships
- Find shared utilities and hooks
- Identify state management approach
- Map API/data fetching patterns
- Find error boundary and error handling patterns

### 1.3 Supabase Specifics
- Read supabase/migrations/ for schema
- Identify tables, relationships, RLS policies
- Find Edge Functions in supabase/functions/
- Note realtime subscriptions in use
- Check for generated types location

### 1.4 Capacitor/Mobile Specifics
- List Capacitor plugins in use
- Check ios/App/Podfile for iOS dependencies
- Check android/app/build.gradle for Android config
- Find platform-specific code (Capacitor.getPlatform() usage)
- Identify native module bridges if any

### 1.5 UI/Component Patterns
- Map shadcn/ui components in use
- Find custom component conventions
- Identify form handling patterns
- Check accessibility implementations
- Note animation/transition approaches

### 1.6 Testing & Quality
- Identify test framework (vitest, jest, etc.)
- Map test file locations and patterns
- Check for e2e tests (Playwright, Cypress)
- Find linting/formatting configs
- Check CI/CD workflows (.github/workflows/)

### 1.7 Git History Analysis
- Find frequently changed files (hotspots)
- Identify recent major changes (last 30 days)
- Check for patterns in commit messages
- Find TODO/FIXME comments in code

### 1.8 Documentation
- Read existing CLAUDE.md
- Read README.md
- Find inline documentation patterns
- Check for API documentation

Create: `~/git/claude-stack/analysis/repo-discovery.md` with a section per repo.

---

## Phase 2: Pattern Mining

Compare all configured repos and extract common patterns:

### 2.1 Shared Technical Patterns

**Dependencies:**
- Common packages across all/most repos
- Version ranges in use
- Peer dependency patterns

**TypeScript:**
- Strict mode settings
- Path aliases (@/ patterns)
- Type definition approaches
- Generic usage patterns

**React Patterns:**
- Component structure (FC, forwardRef, etc.)
- Hook patterns (custom hooks, composition)
- Context usage
- Suspense/error boundary patterns

**Supabase Patterns:**
- Client initialization
- Auth flow implementation
- Query patterns (select, insert, update)
- Realtime subscription patterns
- RLS policy patterns

**Capacitor Patterns:**
- Plugin usage patterns
- Platform detection
- Permission handling
- Deep link handling

**shadcn/ui Patterns:**
- Component customization approach
- Variant patterns with cva()
- Form integration
- Theme customization

**Folder Structures:**
- Common directory organization
- File naming conventions
- Index file patterns

### 2.2 Shared Workflow Patterns

**Build & Deploy:**
- Build commands
- Environment handling
- Deployment targets

**Testing:**
- Test file naming
- Mock patterns
- Coverage requirements

**Git Workflow:**
- Branch naming
- Commit message format
- PR patterns

Create: `~/git/claude-stack/analysis/shared-patterns.md`

---

## Phase 3: Agent Drift Analysis

Compare existing agents against current repo state:

### 3.1 For Each Existing Agent, Check:

**Stale References:**
- File paths mentioned that no longer exist
- Components or functions referenced that were renamed/deleted
- Old folder structures

**Version Drift:**
- Dependencies upgraded since agent was written
- API changes in libraries (React 18→19, Capacitor 5→6, etc.)
- Deprecated patterns still suggested

**Missing Patterns:**
- New conventions in code not reflected in agent
- New components or utilities not mentioned
- New integrations not covered

**Deprecated Patterns:**
- Agent suggests approaches no longer used in codebase
- Old library APIs that have been replaced
- Outdated best practices

**Scope Changes:**
- Agent's domain has grown (needs expansion)
- Agent's domain has shrunk (needs focus)
- Overlap with other agents

**Model Appropriateness:**
- Task complexity has changed
- Could use cheaper model for same quality
- Needs upgrade for better results

### 3.2 Categorize Each Existing Agent:

| Status | Meaning |
|--------|---------|
| ✅ CURRENT | No changes needed |
| 🔄 UPDATE | Needs refresh with new patterns |
| 🔀 MERGE | Should be combined with another agent |
| ✂️ SPLIT | Should be broken into multiple agents |
| 🗑️ DEPRECATE | No longer needed |
| ⬆️ UPGRADE | Needs more capable model |
| ⬇️ DOWNGRADE | Can use cheaper model |

Create: `~/git/claude-stack/analysis/agent-drift.md`

---

## Phase 4: Gap Analysis — Discover Missing Expertise

Identify areas where specialized agents would help but don't exist:

### 4.1 Complexity Analysis
- Files with >300 lines that lack specialized agent coverage
- Modules with high cyclomatic complexity
- Code with many dependencies/imports

### 4.2 Integration Points
- External APIs without dedicated agent knowledge
- OAuth flows needing deep expertise
- Webhook handlers
- Third-party SDK integrations

### 4.3 Platform-Specific Needs
- iOS-specific code patterns
- Android-specific code patterns
- Platform conditional logic
- Native module bridges

### 4.4 Data Layer Complexity
- Complex SQL queries
- RLS policies needing security expertise
- Migration patterns
- Realtime sync edge cases
- Offline-first patterns

### 4.5 Performance-Critical Paths
- Render-heavy components
- Large list virtualization
- Image optimization
- Bundle size concerns
- Memory management on mobile

### 4.6 Security-Sensitive Areas
- Authentication flows
- Authorization checks
- Input validation patterns
- API key management
- Data encryption

### 4.7 Accessibility Needs
- Components lacking ARIA
- Keyboard navigation gaps
- Screen reader support
- Color contrast issues
- Focus management

### 4.8 Localization Needs
- Danish language support
- Date/time formatting
- Currency formatting (DKK)
- RTL considerations if applicable

### 4.9 Testing Gaps
- Critical paths without tests
- Integration test needs
- E2E scenario coverage
- Mobile-specific test needs

### 4.10 Documentation Gaps
- Undocumented APIs
- Missing component docs
- Setup instructions needed
- Architecture documentation

### 4.11 DevOps/Infrastructure
- CI/CD pipeline expertise
- Deployment automation
- Environment management
- Monitoring/logging

For each gap discovered, document:
- What the gap is
- Which repos are affected
- Severity (critical/important/nice-to-have)
- Proposed agent to fill gap

Create: `~/git/claude-stack/analysis/gap-analysis.md`

---

## Phase 5: Project-Specific Intelligence

For each configured repository, document deep domain knowledge:

### 5.1 Project Identity
- Project name and purpose
- Target users/audience
- Business domain
- Danish market considerations

### 5.2 Data Model
- Core entities (actual Supabase table names)
- Relationships between entities
- Key fields and their purposes
- Enums and constants

### 5.3 Unique Integrations
- External services used
- API endpoints consumed
- Authentication with third parties
- Webhooks received

### 5.4 Domain Language
- Business terminology
- Domain-specific jargon
- Naming conventions from domain
- User-facing labels

### 5.5 User Journeys
- Key user flows
- Critical paths
- Edge cases to handle

### 5.6 Technical Debt
- Known issues
- Planned refactors
- Performance concerns
- Security concerns

### 5.7 Roadmap Items
- TODOs in code
- Planned features (from docs/issues)
- Upcoming integrations

Create: `~/git/claude-stack/analysis/project-specific.md`

---

## Phase 6: Agent Architecture Design

Based on all analysis, design the optimal hierarchy:

### Tier 1: Core Shared Agents (Essential, used constantly)
These agents are used in nearly every coding session across all projects.
- Should be highly polished
- Reference real patterns from repos
- Model: sonnet (default, unless MODEL_OVERRIDE is set)

### Tier 2: Specialized Shared Agents (Important, used frequently)
Cross-cutting concerns that apply to multiple projects but not every session.
- Security, accessibility, performance, testing, i18n
- Model: sonnet or haiku depending on complexity

### Tier 3: Utility Agents (Task-specific, high-volume)
Fast, focused agents for routine tasks.
- Code review, linting, type checking, search
- Model: haiku (speed and cost efficiency)

### Tier 4: Project-Specific Agents (Domain experts)
Deep knowledge of one project's unique domain.
- Business logic, integrations, data models
- Model: sonnet (need reasoning for domain complexity)

### For Each Proposed Agent Document:
```markdown
### [agent-name]
- **Tier:** 1/2/3/4
- **Model:** opus/sonnet/haiku
- **Tools:** Read, Write, Edit, Bash, Glob, Grep (as appropriate)
- **Scope:** Shared / Project-specific ([project name])
- **Rationale:** Why this agent is needed (reference specific findings)
- **Key Knowledge:**
  - Bullet points of what it knows
- **Repos Affected:** List of repos that benefit
- **Priority:** Essential / Important / Nice-to-have
```

Create: `~/git/claude-stack/analysis/agent-architecture.md`

---

## Phase 7: Change Plan

Create a concrete, actionable plan:

### 7.1 Updates to Existing Agents

For each agent needing updates:
```markdown
### [agent-name].md — 🔄 UPDATE

**Current State:**
- [What agent currently covers]

**Required Changes:**
1. Add: [new patterns to add]
2. Update: [outdated references to fix]
3. Remove: [deprecated patterns to remove]
4. Model: [keep/change to X]

**Specific Edits:**
- Line X: Change "old/path" to "new/path"
- Section Y: Add new pattern for [feature]

**Rationale:**
[Why these changes are needed, referencing analysis]
```

### 7.2 New Agents to Create

For each new agent:
```markdown
### [agent-name].md — ✨ NEW

**Tier:** X
**Model:** sonnet/haiku/opus
**Scope:** Shared / [Project]-specific

**Purpose:**
[What gap this fills]

**Knowledge Areas:**
- [Specific areas of expertise]

**Rationale:**
[Why this is needed, referencing gap analysis]

**Priority:** Essential / Important / Nice-to-have
```

### 7.3 Agents to Merge

```markdown
### [source-agent].md → [target-agent].md — 🔀 MERGE

**Reason:**
[Why these should be combined]

**Knowledge to Transfer:**
- [What to bring from source to target]

**After Merge:**
- Move source to deprecated/
```

### 7.4 Agents to Deprecate

```markdown
### [agent-name].md — 🗑️ DEPRECATE

**Reason:**
[Why no longer needed]

**Replacement:**
[What to use instead, if anything]

**Action:**
Move to deprecated/ with note
```

### 7.5 Model Changes

```markdown
### [agent-name].md — ⬆️/⬇️ MODEL CHANGE

**Current:** haiku
**Proposed:** sonnet

**Reason:**
[Why the change is warranted]
```

### 7.6 Summary Table

| Agent | Status | Priority | Model | Action |
|-------|--------|----------|-------|--------|
| ... | ... | ... | ... | ... |

Create: `~/git/claude-stack/analysis/change-plan.md`

---

## Phase 8: Execute All Changes

### 8.1 Create Directory Structure

```bash
mkdir -p ~/git/claude-stack/{agents,deprecated,analysis,scripts,prompts,templates}
```

### 8.2 Update Existing Agents

For each agent marked UPDATE:
1. Read current agent file
2. Preserve header structure
3. Update content per change plan
4. Update "last updated" timestamp
5. Update "source repos" list
6. Validate no broken references

### 8.3 Create New Agents

**IMPORTANT:** If `MODEL_OVERRIDE` is set in settings.conf, use that model for ALL agents. Otherwise use the tier defaults.

Each new agent must follow this template:

```markdown
---
name: [agent-name]
description: [Clear description for automatic invocation - what triggers this agent]
model: [opus/sonnet/haiku]
tools: [Read, Write, Edit, Bash, Glob, Grep - as appropriate]
# Last updated: [YYYY-MM-DD]
# Source repos: [comma-separated list]
# Tier: [1/2/3/4]
---

You are an expert in [domain].

## Context
[What this agent knows about the projects]

## Tech Stack
[Specific technologies and versions]

## Patterns
[Actual patterns from the analyzed repos]

## File Locations
[Real paths from the projects]

## Conventions
[Coding conventions discovered]

## Common Tasks
[What this agent typically helps with]

## Examples
[Example interactions or code patterns]
```

### 8.4 Create Project-Specific Agents

For each configured project, create in `[project-path]/.claude/agents/`:

**[project]-context.md** (always create/update):
```markdown
---
name: [project]-context
description: Deep knowledge of [project] domain, data models, and business logic. Use for any [project]-specific questions or implementations.
model: sonnet
tools: Read, Write, Edit, Bash, Glob, Grep
# Last updated: [YYYY-MM-DD]
---

You are an expert in the [project] application.

## Purpose
[What the project does - from analysis]

## Target Users
[Who uses it]

## Data Model
[Actual Supabase tables and relationships]

## Key Features
[Main features]

## Integrations
[External services]

## Domain Terminology
[Glossary of terms]

## Important Files
[Key files and their purposes]
```

Plus any domain-specific agents identified in analysis.

### 8.5 Archive Deprecated Agents

For each deprecated agent:
1. Add deprecation header:
```markdown
# ⚠️ DEPRECATED: [YYYY-MM-DD]
# Reason: [why]
# Replacement: [what to use instead]
# Original content below for reference
---
[original content]
```
2. Move to `~/git/claude-stack/deprecated/`

### 8.6 Update Project CLAUDE.md Files

For each configured project, create/update `CLAUDE.md`:

```markdown
# [Project Name]

## Overview
[Project description - from analysis]

## Tech Stack
- Frontend: [actual from package.json]
- UI: [actual UI library]
- Backend: [actual backend]
- Mobile: [if applicable]

## Project Structure
[Actual structure from analysis]

## Key Files
[Important entry points and modules]

## Database
- Project: [Supabase project if applicable]
- Key tables: [list from analysis]
- RLS: [notes]

## Available Agents

### Shared (from ~/.claude/agents/)
[List discovered shared agents]

### Project-Specific (from .claude/agents/)
[List project agents]

## Commands
[Actual commands from package.json]

## Current Focus
[From TODOs and recent commits]

## Notes
[Any special considerations]
```

---

## Phase 9: Create Maintenance Infrastructure

### 9.1 Save This Prompt

Ensure this prompt is saved at `~/git/claude-stack/prompts/analyze-and-update.md`

---

## Phase 10: Verification

After all changes:

### 10.1 File Structure Check
Verify all expected files exist:
- [ ] ~/git/claude-stack/agents/ contains all shared agents
- [ ] ~/.claude/agents symlink points to ~/git/claude-stack/agents/
- [ ] Each configured project has .claude/agents/ with context agent
- [ ] Each configured project has updated CLAUDE.md
- [ ] Scripts are executable

### 10.2 Agent Validation
For each agent file, verify:
- [ ] Valid YAML frontmatter
- [ ] Description is clear for auto-invocation
- [ ] Model is set appropriately
- [ ] Tools list is appropriate for the agent's purpose
- [ ] No broken file path references
- [ ] Last updated date is current

### 10.3 Cross-Reference Check
- [ ] All repos mentioned in agents exist
- [ ] All file paths in agents are valid
- [ ] No duplicate agent names
- [ ] No conflicting agent descriptions

### 10.4 Summary Report

Create final summary:
```markdown
## Execution Summary

**Date:** [YYYY-MM-DD]

**Repos Analyzed:** X
- [list of repos from config]

**Shared Agents:** Y
- [list with tiers]

**Project Agents:** Z
- [by project]

**Changes Made:**
- Created: X new agents
- Updated: Y existing agents
- Deprecated: Z old agents
- Merged: W agents

**Action Items:**
- [ ] Any manual steps needed
- [ ] Things to verify
- [ ] Follow-up tasks

**Next Refresh:** [date + 30 days]
```

Create: `~/git/claude-stack/analysis/execution-summary.md`

---

## Success Criteria

- [ ] All existing agents audited for drift
- [ ] Outdated references fixed in all agents
- [ ] New patterns from repos incorporated
- [ ] New agents created where gaps existed
- [ ] Deprecated agents archived (not deleted)
- [ ] Project-specific agents created for each configured repo
- [ ] CLAUDE.md updated for each configured project
- [ ] Change plan documents all decisions with rationale
- [ ] README documents the complete setup
- [ ] Symlinks verified working
- [ ] All agents use appropriate models for their complexity

Output <promise>COMPLETE</promise> when all phases are finished.
