# Claude Code Agent Stack

Shared and project-specific Claude Code agents.

## Quick Start

```bash
# 1. Add your repositories (from anywhere)
./scripts/add-repo.sh ~/git/maggie
./scripts/add-repo.sh ~/work/client-project
./scripts/add-repo.sh .  # Current directory

# 2. Save analyze-and-update.md to prompts/

# 3. Generate agents
./scripts/refresh-agents.sh

# 4. Verify
./scripts/list-agents.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `add-repo.sh` | Add a repository (any path) |
| `remove-repo.sh` | Remove repo from config |
| `list-repos.sh` | List configured repositories |
| `refresh-agents.sh` | Analyze and update agents |
| `ralph-refresh.sh` | Thorough refresh with Ralph loop |
| `check-freshness.sh` | Check if refresh needed |
| `list-agents.sh` | List all agents |
| `setup-symlinks.sh` | Recreate symlinks |

## Directory Structure

```
claude-stack/
├── agents/          # Shared agents (symlinked)
├── config/
│   └── repos.conf   # Repository paths
├── scripts/
├── prompts/
├── templates/
├── analysis/
└── deprecated/
```

## Maintenance

```bash
./scripts/check-freshness.sh   # Monthly check
./scripts/refresh-agents.sh    # When needed
```
