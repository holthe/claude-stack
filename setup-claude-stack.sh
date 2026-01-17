#!/bin/bash
#
# Claude Code Agent Stack - Initial Setup
# 
# This script creates the complete directory structure, helper scripts,
# and symlinks for managing shared Claude Code agents across projects.
#
# Usage: ./setup-claude-stack.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - derive STACK_DIR from this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$SCRIPT_DIR"
USER_AGENTS="$HOME/.claude/agents"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Agent Stack - Initial Setup              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# -----------------------------------------------------------------------------
# Step 1: Create directory structure
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/7]${NC} Creating directory structure..."

mkdir -p "$STACK_DIR"/{agents,deprecated,analysis,scripts,prompts,templates,config}
mkdir -p "$HOME/.claude"

echo -e "  ${GREEN}✓${NC} Created $STACK_DIR/"
echo -e "  ${GREEN}✓${NC} Created subdirectories: agents, deprecated, analysis, scripts, prompts, templates, config"

# -----------------------------------------------------------------------------
# Step 2: Create repos.conf
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/7]${NC} Creating configuration..."

cat > "$STACK_DIR/config/repos.conf" << 'REPOS_CONF'
# Claude Code Agent Stack - Repository Configuration
#
# List absolute paths to repositories to include in agent analysis.
# One path per line. Lines starting with # are comments.
#
# Examples:
#   /home/peter/git/maggie
#   /home/peter/git/two-socks
#   /home/peter/work/client-project
#   /Users/peter/Projects/side-project
#
# After editing, run: ./scripts/refresh-agents.sh (from claude-stack directory)
#

# Add your repositories below:

REPOS_CONF

echo -e "  ${GREEN}✓${NC} Created config/repos.conf"

# Create settings.conf with defaults
cat > "$STACK_DIR/config/settings.conf" << 'SETTINGS_CONF'
# Claude Stack Settings
#
# MODEL_OVERRIDE - Force all subagents to use a specific model
# Leave commented to use tiered defaults (sonnet/haiku based on complexity)
# Options: opus, sonnet, haiku
#
# MODEL_OVERRIDE=opus
SETTINGS_CONF

echo -e "  ${GREEN}✓${NC} Created config/settings.conf"

# Create .claude/settings.local.json with permissions for non-interactive refresh
mkdir -p "$STACK_DIR/.claude"
cat > "$STACK_DIR/.claude/settings.local.json" << SETTINGS_JSON
{
  "permissions": {
    "allow": [
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Bash(tree:*)",
      "Bash(find:*)",
      "Bash(head:*)",
      "Bash(wc:*)",
      "Bash(mkdir:*)",
      "Read($HOME/git/**)",
      "Write($STACK_DIR/**)",
      "Edit($STACK_DIR/**)"
    ]
  }
}
SETTINGS_JSON

echo -e "  ${GREEN}✓${NC} Created .claude/settings.local.json"

# -----------------------------------------------------------------------------
# Step 3: Create helper functions script
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/common.sh" << 'COMMON_SCRIPT'
#!/bin/bash
#
# Common functions for Claude Code Agent Stack scripts
#

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# Paths - derive STACK_DIR from this script's location
# common.sh is in scripts/, so STACK_DIR is one level up
COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STACK_DIR="$(cd "$COMMON_SCRIPT_DIR/.." && pwd)"
export USER_AGENTS="$HOME/.claude/agents"
export REPOS_CONF="$STACK_DIR/config/repos.conf"

# Get list of configured repositories
get_repos() {
    if [ ! -f "$REPOS_CONF" ]; then
        echo ""
        return
    fi
    
    # Read non-empty, non-comment lines
    grep -v '^#' "$REPOS_CONF" | grep -v '^[[:space:]]*$' | while read -r line; do
        # Expand ~ to $HOME
        expanded="${line/#\~/$HOME}"
        if [ -d "$expanded" ]; then
            echo "$expanded"
        fi
    done
}

# Check if repos are configured
check_repos_configured() {
    local repos=$(get_repos)
    if [ -z "$repos" ]; then
        echo -e "${YELLOW}⚠️  No repositories configured${NC}"
        echo ""
        echo "Add repository paths to: $REPOS_CONF"
        echo ""
        echo "Example:"
        echo "  echo '$HOME/git/maggie' >> $REPOS_CONF"
        echo "  echo '$HOME/git/two-socks' >> $REPOS_CONF"
        echo ""
        return 1
    fi
    return 0
}

# Count configured repos
count_repos() {
    get_repos | wc -l | tr -d ' '
}

# Print repo list
print_repos() {
    echo -e "${BLUE}Configured repositories:${NC}"
    get_repos | while read -r repo; do
        if [ -n "$repo" ]; then
            name=$(basename "$repo")
            echo -e "  ${GREEN}✓${NC} $name ($repo)"
        fi
    done
}
COMMON_SCRIPT

chmod +x "$STACK_DIR/scripts/common.sh"
echo -e "  ${GREEN}✓${NC} Created scripts/common.sh"

# -----------------------------------------------------------------------------
# Step 4: Create add-repo.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/add-repo.sh" << 'ADD_REPO_SCRIPT'
#!/bin/bash
#
# Add a repository to the Claude Code Agent Stack
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ -z "$1" ]; then
    echo -e "${BLUE}Add Repository to Claude Code Agent Stack${NC}"
    echo ""
    echo "Usage: $0 <path-to-repo>"
    echo ""
    echo "Examples:"
    echo "  $0 ~/git/maggie"
    echo "  $0 /home/peter/work/client-project"
    echo "  $0 .                    # Current directory"
    echo ""
    
    if check_repos_configured 2>/dev/null; then
        echo ""
        print_repos
    fi
    exit 0
fi

# Resolve path
INPUT_PATH="$1"

# Handle relative paths and .
if [[ "$INPUT_PATH" == "." ]]; then
    REPO_PATH="$(pwd)"
elif [[ "$INPUT_PATH" != /* ]]; then
    # Relative path - make absolute
    REPO_PATH="$(cd "$INPUT_PATH" 2>/dev/null && pwd)" || {
        echo -e "${RED}❌ Path not found: $INPUT_PATH${NC}"
        exit 1
    }
else
    # Already absolute, expand ~
    REPO_PATH="${INPUT_PATH/#\~/$HOME}"
fi

# Verify it's a directory
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}❌ Not a directory: $REPO_PATH${NC}"
    exit 1
fi

# Verify it's a git repo (optional but recommended)
if [ ! -d "$REPO_PATH/.git" ]; then
    echo -e "${YELLOW}⚠️  Not a git repository: $REPO_PATH${NC}"
    read -p "Add anyway? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

REPO_NAME=$(basename "$REPO_PATH")

# Check if already added
if grep -q "^$REPO_PATH$" "$REPOS_CONF" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Repository already configured: $REPO_NAME${NC}"
    exit 0
fi

# Add to config
echo "$REPO_PATH" >> "$REPOS_CONF"
echo -e "${GREEN}✓${NC} Added repository: $REPO_NAME"
echo -e "  Path: ${BLUE}$REPO_PATH${NC}"

# Create .claude/agents directory
mkdir -p "$REPO_PATH/.claude/agents"
echo -e "${GREEN}✓${NC} Created .claude/agents/"

# Create project context agent
cat > "$REPO_PATH/.claude/agents/${REPO_NAME}-context.md" << CONTEXT_AGENT
---
name: ${REPO_NAME}-context
description: Deep knowledge of ${REPO_NAME} domain, data models, and business logic. Use for any ${REPO_NAME}-specific questions or implementations.
model: sonnet
tools: Read, Write, Edit, Bash, Glob, Grep
# Last updated: $(date +%Y-%m-%d)
---

You are an expert in the ${REPO_NAME} application.

## Purpose
[Describe what this project does]

## Tech Stack
- Frontend: React 18 + TypeScript + Vite
- UI: shadcn/ui + Tailwind CSS
- Backend: Supabase
- Mobile: Capacitor 6

## Data Model
[List key Supabase tables and relationships]

## Key Features
[List main features]

## Important Files
- src/App.tsx - Main application entry
- src/lib/supabase.ts - Supabase client
[Add more key files]

## Domain Terminology
[Add project-specific terms and jargon]
CONTEXT_AGENT

echo -e "${GREEN}✓${NC} Created ${REPO_NAME}-context.md agent"

# Create CLAUDE.md if it doesn't exist
if [ ! -f "$REPO_PATH/CLAUDE.md" ]; then
    cat > "$REPO_PATH/CLAUDE.md" << CLAUDE_MD
# ${REPO_NAME}

## Overview
[Brief description of the project]

## Tech Stack
- Frontend: React 18 + TypeScript + Vite
- UI: shadcn/ui + Tailwind CSS
- Backend: Supabase (Auth, Database, Realtime, Storage)
- Mobile: Capacitor 6 (iOS + Android)

## Project Structure
\`\`\`
src/
├── components/     # React components
│   └── ui/         # shadcn components
├── pages/          # Route pages
├── lib/            # Supabase client, utilities
├── hooks/          # Custom React hooks
└── types/          # TypeScript types
\`\`\`

## Available Agents

### Shared (from ~/.claude/agents/)
- react-shadcn-expert: UI components with shadcn
- supabase-expert: Database, auth, realtime
- capacitor-expert: Mobile/native features
- code-reviewer: Quality checks

### Project-Specific (from .claude/agents/)
- ${REPO_NAME}-context: Domain knowledge

## Key Commands
\`\`\`bash
npm run dev          # Start dev server
npm run build        # Build for production
npx cap sync         # Sync Capacitor
npx cap run ios      # Run on iOS
npx cap run android  # Run on Android
\`\`\`

## Current Focus
[What's currently being worked on]
CLAUDE_MD

    echo -e "${GREEN}✓${NC} Created CLAUDE.md"
else
    echo -e "${YELLOW}○${NC} CLAUDE.md already exists (skipped)"
fi

echo ""
echo -e "${GREEN}Repository added successfully!${NC}"
echo ""
echo "Next steps:"
echo -e "  1. Edit ${BLUE}$REPO_PATH/.claude/agents/${REPO_NAME}-context.md${NC}"
echo "     Add project-specific domain knowledge"
echo ""
echo -e "  2. Edit ${BLUE}$REPO_PATH/CLAUDE.md${NC}"
echo "     Update with project details"
echo ""
echo -e "  3. Run ${BLUE}$STACK_DIR/scripts/refresh-agents.sh${NC}"
echo "     To analyze and generate/update agents"
echo ""
ADD_REPO_SCRIPT

chmod +x "$STACK_DIR/scripts/add-repo.sh"
echo -e "  ${GREEN}✓${NC} Created add-repo.sh"

# -----------------------------------------------------------------------------
# Step 5: Create list-repos.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/list-repos.sh" << 'LIST_REPOS_SCRIPT'
#!/bin/bash
#
# List configured repositories
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Configured Repositories                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if ! check_repos_configured; then
    exit 0
fi

echo ""
count=$(count_repos)
echo -e "Found ${GREEN}$count${NC} repository(ies):"
echo ""

get_repos | while read -r repo; do
    if [ -n "$repo" ]; then
        name=$(basename "$repo")
        
        # Check for .claude/agents
        if [ -d "$repo/.claude/agents" ]; then
            agent_count=$(find "$repo/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            agents_status="${GREEN}$agent_count agents${NC}"
        else
            agents_status="${YELLOW}no agents${NC}"
        fi
        
        # Check for CLAUDE.md
        if [ -f "$repo/CLAUDE.md" ]; then
            claude_status="${GREEN}✓${NC}"
        else
            claude_status="${YELLOW}○${NC}"
        fi
        
        echo -e "  ${CYAN}$name${NC}"
        echo -e "    Path:      $repo"
        echo -e "    Agents:    $agents_status"
        echo -e "    CLAUDE.md: $claude_status"
        echo ""
    fi
done

echo ""
echo -e "Config file: ${BLUE}$REPOS_CONF${NC}"
echo ""
LIST_REPOS_SCRIPT

chmod +x "$STACK_DIR/scripts/list-repos.sh"
echo -e "  ${GREEN}✓${NC} Created list-repos.sh"

# -----------------------------------------------------------------------------
# Step 6: Create remove-repo.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/remove-repo.sh" << 'REMOVE_REPO_SCRIPT'
#!/bin/bash
#
# Remove a repository from the Claude Code Agent Stack
# (Does not delete the repo itself, just removes from config)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ -z "$1" ]; then
    echo -e "${BLUE}Remove Repository from Claude Code Agent Stack${NC}"
    echo ""
    echo "Usage: $0 <repo-name-or-path>"
    echo ""
    echo "This removes the repo from the config file."
    echo "It does NOT delete the repository or its agents."
    echo ""
    
    if check_repos_configured 2>/dev/null; then
        echo ""
        print_repos
    fi
    exit 0
fi

INPUT="$1"

# Find matching path
MATCHED_PATH=""
while read -r repo; do
    if [ -n "$repo" ]; then
        name=$(basename "$repo")
        expanded_input="${INPUT/#\~/$HOME}"
        if [ "$name" == "$INPUT" ] || [ "$repo" == "$INPUT" ] || [ "$repo" == "$expanded_input" ]; then
            MATCHED_PATH="$repo"
            break
        fi
    fi
done < <(get_repos)

if [ -z "$MATCHED_PATH" ]; then
    echo -e "${RED}❌ Repository not found in config: $INPUT${NC}"
    echo ""
    echo "Configured repositories:"
    get_repos | while read -r repo; do
        if [ -n "$repo" ]; then
            echo "  - $(basename "$repo") ($repo)"
        fi
    done
    exit 1
fi

REPO_NAME=$(basename "$MATCHED_PATH")

echo -e "Removing ${CYAN}$REPO_NAME${NC} from config..."
echo -e "  Path: $MATCHED_PATH"
echo ""

# Create temp file without the matched line
grep -v "^$MATCHED_PATH$" "$REPOS_CONF" > "$REPOS_CONF.tmp" || true
mv "$REPOS_CONF.tmp" "$REPOS_CONF"

echo -e "${GREEN}✓${NC} Removed from config"
echo ""
echo -e "${YELLOW}Note:${NC} The repository and its agents were NOT deleted."
echo "To re-add later: $STACK_DIR/scripts/add-repo.sh $MATCHED_PATH"
echo ""
REMOVE_REPO_SCRIPT

chmod +x "$STACK_DIR/scripts/remove-repo.sh"
echo -e "  ${GREEN}✓${NC} Created remove-repo.sh"

# -----------------------------------------------------------------------------
# Step 7: Create refresh-agents.sh
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/7]${NC} Creating maintenance scripts..."

cat > "$STACK_DIR/scripts/refresh-agents.sh" << 'REFRESH_SCRIPT'
#!/bin/bash
#
# Refresh Claude Code agents based on current repository state
# Run monthly or after major project changes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROMPT_FILE="$STACK_DIR/prompts/analyze-and-update.md"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Claude Code Agent Refresh                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check repos configured
if ! check_repos_configured; then
    exit 1
fi

# Check prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}❌ Prompt file not found: $PROMPT_FILE${NC}"
    echo ""
    echo "Please save the analyze-and-update.md prompt to:"
    echo "  $PROMPT_FILE"
    exit 1
fi

# Check Claude Code is available
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found${NC}"
    echo ""
    echo "Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Show configuration
echo -e "  Prompt file: ${GREEN}$PROMPT_FILE${NC}"
echo ""
print_repos
echo ""

# Confirm before running
echo -e "${YELLOW}This will analyze all configured repositories${NC}"
echo -e "${YELLOW}and update/create agents as needed.${NC}"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BLUE}Starting analysis...${NC}"
echo ""

# Run Claude with the prompt (it reads repos from config/repos.conf directly)
cd "$STACK_DIR"
claude -p "$(cat "$PROMPT_FILE")"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Agent refresh complete!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Analysis reports: ${BLUE}$STACK_DIR/analysis/${NC}"
echo -e "  Shared agents:    ${BLUE}$STACK_DIR/agents/${NC}"
echo ""
REFRESH_SCRIPT

chmod +x "$STACK_DIR/scripts/refresh-agents.sh"
echo -e "  ${GREEN}✓${NC} Created refresh-agents.sh"

# -----------------------------------------------------------------------------
# Step 8: Create ralph-refresh.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/ralph-refresh.sh" << 'RALPH_SCRIPT'
#!/bin/bash
#
# Refresh agents using Ralph Wiggum loop for thorough execution
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROMPT_FILE="$STACK_DIR/prompts/analyze-and-update.md"
MAX_ITERATIONS="${1:-25}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Agent Refresh (Ralph Mode)               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check repos configured
if ! check_repos_configured; then
    exit 1
fi

# Check prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}❌ Prompt file not found: $PROMPT_FILE${NC}"
    exit 1
fi

# Check Claude Code is available
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found${NC}"
    exit 1
fi

echo -e "  Max iterations: ${GREEN}$MAX_ITERATIONS${NC}"
echo ""
print_repos
echo ""

echo -e "${YELLOW}This will run a Ralph loop with up to $MAX_ITERATIONS iterations.${NC}"
echo -e "${YELLOW}This is more thorough but uses more tokens.${NC}"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BLUE}Starting Ralph loop...${NC}"
echo ""

# Run with Ralph loop (prompt reads repos from config/repos.conf directly)
cd "$STACK_DIR"
claude -p "/ralph-loop \"$(cat "$PROMPT_FILE")\" --max-iterations $MAX_ITERATIONS"

echo ""
echo -e "${GREEN}✓${NC} Ralph refresh complete!"
echo ""
RALPH_SCRIPT

chmod +x "$STACK_DIR/scripts/ralph-refresh.sh"
echo -e "  ${GREEN}✓${NC} Created ralph-refresh.sh"

# -----------------------------------------------------------------------------
# Step 9: Create check-freshness.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/check-freshness.sh" << 'FRESHNESS_SCRIPT'
#!/bin/bash
#
# Check if Claude Code agents need refreshing
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

AGENTS_DIR="$STACK_DIR/agents"

echo -e "${BLUE}Checking agent freshness...${NC}"
echo ""

if [ ! -d "$AGENTS_DIR" ]; then
    echo -e "${RED}❌ Agents directory not found: $AGENTS_DIR${NC}"
    echo "   Run refresh-agents.sh first."
    exit 1
fi

# Count agents
AGENT_COUNT=$(find "$AGENTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$AGENT_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No agents found in $AGENTS_DIR${NC}"
    echo "   Run: $STACK_DIR/scripts/refresh-agents.sh"
    exit 0
fi

# Find oldest and newest agent
if [[ "$OSTYPE" == "darwin"* ]]; then
    OLDEST_TIME=$(find "$AGENTS_DIR" -name "*.md" -type f -exec stat -f "%m" {} \; 2>/dev/null | sort -n | head -1)
    NEWEST_TIME=$(find "$AGENTS_DIR" -name "*.md" -type f -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
else
    OLDEST_TIME=$(find "$AGENTS_DIR" -name "*.md" -type f -printf "%T@\n" 2>/dev/null | sort -n | head -1 | cut -d'.' -f1)
    NEWEST_TIME=$(find "$AGENTS_DIR" -name "*.md" -type f -printf "%T@\n" 2>/dev/null | sort -rn | head -1 | cut -d'.' -f1)
fi

NOW=$(date +%s)

if [ -n "$OLDEST_TIME" ]; then
    OLDEST_DAYS=$(( (NOW - OLDEST_TIME) / 86400 ))
    NEWEST_DAYS=$(( (NOW - NEWEST_TIME) / 86400 ))
    
    echo -e "  Agents found:    ${GREEN}$AGENT_COUNT${NC}"
    echo -e "  Oldest updated:  ${YELLOW}$OLDEST_DAYS days ago${NC}"
    echo -e "  Newest updated:  ${GREEN}$NEWEST_DAYS days ago${NC}"
    echo ""
    
    if [ $OLDEST_DAYS -gt 30 ]; then
        echo -e "${YELLOW}⚠️  Some agents are over 30 days old${NC}"
        echo -e "   Consider running: ${BLUE}$STACK_DIR/scripts/refresh-agents.sh${NC}"
    elif [ $OLDEST_DAYS -gt 14 ]; then
        echo -e "${GREEN}✓${NC} Agents are reasonably fresh"
        echo -e "   Next recommended refresh: ${BLUE}$(( 30 - OLDEST_DAYS )) days${NC}"
    else
        echo -e "${GREEN}✓${NC} Agents are fresh!"
    fi
else
    echo -e "${RED}❌ Could not determine agent ages${NC}"
fi

echo ""

# List agents
echo -e "${BLUE}Current shared agents:${NC}"
for agent in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent" ]; then
        name=$(basename "$agent" .md)
        model=$(grep -m1 "^model:" "$agent" 2>/dev/null | cut -d':' -f2 | tr -d ' ' || echo "?")
        echo -e "  - $name ${YELLOW}($model)${NC}"
    fi
done
echo ""
FRESHNESS_SCRIPT

chmod +x "$STACK_DIR/scripts/check-freshness.sh"
echo -e "  ${GREEN}✓${NC} Created check-freshness.sh"

# -----------------------------------------------------------------------------
# Step 10: Create list-agents.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/list-agents.sh" << 'LIST_SCRIPT'
#!/bin/bash
#
# List all Claude Code agents (shared and project-specific)
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              Claude Code Agent Inventory                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to extract and print agent info
print_agent_info() {
    local file="$1"
    local name=$(basename "$file" .md)
    local model=$(grep -m1 "^model:" "$file" 2>/dev/null | cut -d':' -f2 | tr -d ' ' || echo "-")
    local tier=$(grep -m1 "^# Tier:" "$file" 2>/dev/null | cut -d':' -f2 | tr -d ' ' || echo "-")
    local desc=$(grep -m1 "^description:" "$file" 2>/dev/null | cut -d':' -f2- | sed 's/^ *//' | cut -c1-45 || echo "-")
    
    printf "  ${GREEN}%-24s${NC} ${YELLOW}%-7s${NC} ${CYAN}%-4s${NC} %s\n" "$name" "$model" "$tier" "$desc..."
}

# Shared agents
echo -e "${BLUE}Shared Agents${NC} ($STACK_DIR/agents/)"
echo -e "  ${GREEN}Name                    ${YELLOW}Model   ${CYAN}Tier ${NC}Description"
echo "  ────────────────────────────────────────────────────────────────────────"

if [ -d "$STACK_DIR/agents" ]; then
    found=0
    for agent in "$STACK_DIR/agents"/*.md; do
        if [ -f "$agent" ]; then
            print_agent_info "$agent"
            found=1
        fi
    done
    if [ $found -eq 0 ]; then
        echo -e "  ${YELLOW}No shared agents found. Run refresh-agents.sh${NC}"
    fi
else
    echo -e "  ${YELLOW}No shared agents found${NC}"
fi
echo ""

# Project-specific agents
echo -e "${BLUE}Project-Specific Agents${NC}"
echo ""

while read -r repo; do
    if [ -n "$repo" ] && [ -d "$repo" ]; then
        repo_name=$(basename "$repo")
        agents_dir="$repo/.claude/agents"
        
        if [ -d "$agents_dir" ]; then
            found=0
            for agent in "$agents_dir"/*.md; do
                if [ -f "$agent" ]; then
                    if [ $found -eq 0 ]; then
                        echo -e "${CYAN}$repo_name${NC}"
                        echo -e "  ${GREEN}Name                    ${YELLOW}Model   ${CYAN}Tier ${NC}Description"
                        echo "  ────────────────────────────────────────────────────────────────────────"
                    fi
                    print_agent_info "$agent"
                    found=1
                fi
            done
            if [ $found -eq 1 ]; then
                echo ""
            fi
        fi
    fi
done < <(get_repos)

# Deprecated agents
if [ -d "$STACK_DIR/deprecated" ]; then
    found=0
    for agent in "$STACK_DIR/deprecated"/*.md; do
        if [ -f "$agent" ]; then
            if [ $found -eq 0 ]; then
                echo -e "${YELLOW}Deprecated Agents${NC} ($STACK_DIR/deprecated/)"
            fi
            echo -e "  - $(basename "$agent" .md)"
            found=1
        fi
    done
    if [ $found -eq 1 ]; then
        echo ""
    fi
fi

# Summary
echo -e "${BLUE}Summary${NC}"
shared_count=$(find "$STACK_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
project_count=0
while read -r repo; do
    if [ -d "$repo/.claude/agents" ]; then
        count=$(find "$repo/.claude/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        project_count=$((project_count + count))
    fi
done < <(get_repos)
echo -e "  Shared agents:           ${GREEN}$shared_count${NC}"
echo -e "  Project-specific agents: ${GREEN}$project_count${NC}"
echo ""
LIST_SCRIPT

chmod +x "$STACK_DIR/scripts/list-agents.sh"
echo -e "  ${GREEN}✓${NC} Created list-agents.sh"

# -----------------------------------------------------------------------------
# Step 11: Create setup-symlinks.sh
# -----------------------------------------------------------------------------

cat > "$STACK_DIR/scripts/setup-symlinks.sh" << 'SYMLINK_SCRIPT'
#!/bin/bash
#
# Set up symlinks for shared Claude Code agents
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo -e "${BLUE}Setting up Claude Code agent symlinks...${NC}"
echo ""

# Backup existing agents if they exist and aren't a symlink
if [ -d "$USER_AGENTS" ] && [ ! -L "$USER_AGENTS" ]; then
    BACKUP_DIR="$USER_AGENTS.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing agents to $BACKUP_DIR${NC}"
    mv "$USER_AGENTS" "$BACKUP_DIR"
fi

# Remove existing symlink if present
if [ -L "$USER_AGENTS" ]; then
    echo "Removing existing symlink..."
    rm "$USER_AGENTS"
fi

# Create parent directory if needed
mkdir -p "$(dirname "$USER_AGENTS")"

# Create symlink
ln -s "$STACK_DIR/agents" "$USER_AGENTS"

echo ""
echo -e "${GREEN}✓${NC} Symlink created:"
echo -e "  ${BLUE}$USER_AGENTS${NC} -> ${BLUE}$STACK_DIR/agents${NC}"
echo ""

# Verify
if [ -L "$USER_AGENTS" ] && [ -d "$USER_AGENTS" ]; then
    AGENT_COUNT=$(find "$USER_AGENTS" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}✓${NC} Symlink verified. $AGENT_COUNT shared agent(s) available."
else
    echo -e "${RED}❌ Symlink verification failed${NC}"
    exit 1
fi
echo ""
SYMLINK_SCRIPT

chmod +x "$STACK_DIR/scripts/setup-symlinks.sh"
echo -e "  ${GREEN}✓${NC} Created setup-symlinks.sh"

# -----------------------------------------------------------------------------
# Step 12: Create templates
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[4/7]${NC} Creating templates..."

cat > "$STACK_DIR/templates/agent-template.md" << 'AGENT_TEMPLATE'
---
name: [agent-name]
description: [Clear description for automatic invocation]
model: [opus/sonnet/haiku]
tools: [Read, Write, Edit, Bash, Glob, Grep]
# Last updated: [YYYY-MM-DD]
# Source repos: [list]
# Tier: [1-4]
---

You are an expert in [domain].

## Context
[What this agent knows]

## Patterns
[Code patterns to follow]

## Conventions
[Coding conventions]

## Common Tasks
[Typical use cases]

## Anti-Patterns
[What to avoid]
AGENT_TEMPLATE

echo -e "  ${GREEN}✓${NC} Created agent-template.md"

cat > "$STACK_DIR/templates/CLAUDE.md.template" << 'CLAUDE_TEMPLATE'
# [Project Name]

## Overview
[Brief description]

## Tech Stack
- Frontend: React 18 + TypeScript + Vite
- UI: shadcn/ui + Tailwind CSS
- Backend: Supabase
- Mobile: Capacitor 6

## Project Structure
```
src/
├── components/
├── pages/
├── lib/
├── hooks/
└── types/
```

## Available Agents

### Shared
- react-shadcn-expert
- supabase-expert
- capacitor-expert

### Project-Specific
- [project]-context

## Key Commands
```bash
npm run dev
npm run build
npx cap sync
```

## Current Focus
[What's being worked on]
CLAUDE_TEMPLATE

echo -e "  ${GREEN}✓${NC} Created CLAUDE.md.template"

# -----------------------------------------------------------------------------
# Step 13: Create README
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[5/7]${NC} Creating documentation..."

cat > "$STACK_DIR/README.md" << 'README_CONTENT'
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
README_CONTENT

echo -e "  ${GREEN}✓${NC} Created README.md"

# -----------------------------------------------------------------------------
# Step 14: Set up symlink
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[6/7]${NC} Setting up symlinks..."

if [ -d "$USER_AGENTS" ] && [ ! -L "$USER_AGENTS" ]; then
    BACKUP_DIR="$USER_AGENTS.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "  ${YELLOW}!${NC} Backing up existing agents to $BACKUP_DIR"
    mv "$USER_AGENTS" "$BACKUP_DIR"
fi

if [ -L "$USER_AGENTS" ]; then
    rm "$USER_AGENTS"
fi

ln -s "$STACK_DIR/agents" "$USER_AGENTS"
echo -e "  ${GREEN}✓${NC} Symlink created: ~/.claude/agents -> $STACK_DIR/agents"

# -----------------------------------------------------------------------------
# Step 15: Final summary
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[7/7]${NC} Setup complete!"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Setup Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "  1. ${YELLOW}Add your repositories:${NC}"
echo -e "     ${BLUE}$STACK_DIR/scripts/add-repo.sh ~/git/maggie${NC}"
echo -e "     ${BLUE}$STACK_DIR/scripts/add-repo.sh /path/to/other-project${NC}"
echo ""
echo -e "  2. ${YELLOW}Save the analysis prompt to:${NC}"
echo -e "     ${BLUE}$STACK_DIR/prompts/analyze-and-update.md${NC}"
echo ""
echo -e "  3. ${YELLOW}Run the initial analysis:${NC}"
echo -e "     ${BLUE}$STACK_DIR/scripts/refresh-agents.sh${NC}"
echo ""
echo -e "  4. ${YELLOW}Check your agents:${NC}"
echo -e "     ${BLUE}$STACK_DIR/scripts/list-agents.sh${NC}"
echo ""
