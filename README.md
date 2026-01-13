# Claude Code Agent Stack

Shared and project-specific Claude Code agents for the React + Supabase + Capacitor + Tailwind stack.

## Current Status

**Last Refresh:** 2026-01-12

| Metric | Count |
|--------|-------|
| Repositories | 4 |
| Shared Agents | 12 |
| Project Agents | 4 |

## Agents

### Tier 1: Core (Essential)

| Agent | Model | Purpose |
|-------|-------|---------|
| react-expert | sonnet | React 18/19, hooks, state management, Context, Zustand |
| supabase-expert | sonnet | Database, auth, RLS, realtime, edge functions |
| capacitor-expert | sonnet | Mobile features, plugins, iOS/Android deployment |

### Tier 2: Specialized (Important)

| Agent | Model | Purpose |
|-------|-------|---------|
| tailwind-ui | haiku | Tailwind CSS, shadcn/ui, CVA variants |
| testing-expert | sonnet | Vitest, React Testing Library, mocking |
| security-expert | sonnet | Auth, RLS policies, input validation |
| i18n-expert | haiku | react-i18next, translations, Danish locale |
| offline-expert | sonnet | Sync queues, caching, offline-first |
| accessibility-expert | sonnet | WCAG, ARIA, keyboard navigation |

### Tier 3: Utility (Quick Tasks)

| Agent | Model | Purpose |
|-------|-------|---------|
| code-reviewer | haiku | Quick code quality checks |
| type-checker | haiku | TypeScript type fixes |
| lint-fixer | haiku | ESLint configuration and fixes |

### Tier 4: Project-Specific

| Agent | Project | Location |
|-------|---------|----------|
| two-socks-context | two-socks | .claude/agents/ |
| maggie-context | maggie-v3 | .claude/agents/ |
| quiet-kicks-context | quiet-kicks | .claude/agents/ |
| wedding-context | wedding | .claude/agents/ |

## Setup

### Symlink (Already configured)

```bash
~/.claude/agents -> ~/git/claude-stack/agents
```

### Add a Repository

Edit `config/repos.conf`:
```
/home/augustin/git/your-project
```

### Refresh Agents

```bash
# Run the analysis prompt in Claude Code
cat ~/git/claude-stack/prompts/analyze-and-update.md
```

## Directory Structure

```
claude-stack/
├── agents/              # 12 shared agents (symlinked to ~/.claude/agents)
├── analysis/            # Discovery and architecture documents
├── config/
│   └── repos.conf       # Repository paths to analyze
├── prompts/
│   └── analyze-and-update.md  # Main analysis prompt
├── deprecated/          # Archived agents
├── templates/           # Agent templates
└── scripts/             # Utility scripts
```

## Configured Repositories

| Repository | Tech Stack |
|------------|------------|
| two-socks | React 19, TypeScript, Tailwind v4, Zustand, Capacitor 8 |
| maggie-v3 | React 18, TypeScript, shadcn/ui, Context API, Capacitor 8 |
| quiet-kicks | React 18, JavaScript, CSS Variables, Capacitor 5 |
| wedding | React 19, TypeScript, shadcn/ui, Capacitor 8 |

## Maintenance

**Recommended refresh:** Monthly or when major changes occur

1. Edit `config/repos.conf` if repositories changed
2. Run `prompts/analyze-and-update.md` in Claude Code
3. Review generated agents
4. Commit changes to claude-stack

## Analysis Documents

| Document | Purpose |
|----------|---------|
| existing-agents.md | Pre-analysis inventory |
| repo-discovery.md | Deep discovery findings |
| shared-patterns.md | Cross-repo patterns |
| agent-drift.md | Drift analysis |
| gap-analysis.md | Missing expertise |
| project-specific.md | Domain intelligence |
| agent-architecture.md | Architecture design |
| change-plan.md | Execution plan |
| execution-summary.md | Results summary |
