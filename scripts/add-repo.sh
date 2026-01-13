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
