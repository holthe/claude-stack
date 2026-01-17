#!/bin/bash
#
# Claude Code Agent Stack - Initial Setup
#
# This script creates the initial directory structure and symlinks
# for managing shared Claude Code agents across projects.
#
# Usage: ./setup-claude-stack.sh
#
# Note: This script is typically only run once when cloning the repo.
# The actual scripts in scripts/ are the source of truth.
#

set -euo pipefail

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
echo -e "${YELLOW}[1/4]${NC} Creating directory structure..."

mkdir -p "$STACK_DIR"/{agents,deprecated,analysis,scripts,prompts,templates,config}
mkdir -p "$HOME/.claude"

echo -e "  ${GREEN}✓${NC} Created $STACK_DIR/"
echo -e "  ${GREEN}✓${NC} Created subdirectories: agents, deprecated, analysis, scripts, prompts, templates, config"

# -----------------------------------------------------------------------------
# Step 2: Create config files if they don't exist
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/4]${NC} Creating configuration..."

if [ ! -f "$STACK_DIR/config/repos.conf" ]; then
    cat > "$STACK_DIR/config/repos.conf" << 'REPOS_CONF'
# Claude Code Agent Stack - Repository Configuration
#
# List absolute paths to repositories to include in agent analysis.
# One path per line. Lines starting with # are comments.
#
# Examples:
#   /home/user/git/my-project
#   /home/user/work/client-project
#   ~/Projects/side-project
#
# After editing, run: ./scripts/refresh-agents.sh (from claude-stack directory)
#

# Add your repositories below:

REPOS_CONF
    echo -e "  ${GREEN}✓${NC} Created config/repos.conf"
else
    echo -e "  ${YELLOW}○${NC} config/repos.conf already exists (skipped)"
fi

if [ ! -f "$STACK_DIR/config/settings.conf" ]; then
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
else
    echo -e "  ${YELLOW}○${NC} config/settings.conf already exists (skipped)"
fi

# Create .claude/settings.local.json with minimal, safe permissions
mkdir -p "$STACK_DIR/.claude"
if [ ! -f "$STACK_DIR/.claude/settings.local.json" ]; then
    cat > "$STACK_DIR/.claude/settings.local.json" << 'SETTINGS_JSON'
{
  "permissions": {
    "allow": [
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Bash(tree:*)",
      "Bash(find:*)",
      "Bash(head:*)",
      "Bash(wc:*)",
      "Bash(mkdir:*)"
    ]
  }
}
SETTINGS_JSON
    echo -e "  ${GREEN}✓${NC} Created .claude/settings.local.json"
else
    echo -e "  ${YELLOW}○${NC} .claude/settings.local.json already exists (skipped)"
fi

# -----------------------------------------------------------------------------
# Step 3: Set up symlink
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/4]${NC} Setting up symlinks..."

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
# Step 4: Make scripts executable
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[4/4]${NC} Making scripts executable..."

chmod +x "$STACK_DIR/scripts/"*.sh 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Scripts are executable"

# -----------------------------------------------------------------------------
# Final summary
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Setup Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "  1. ${YELLOW}Add your repositories:${NC}"
echo -e "     ${BLUE}$STACK_DIR/scripts/add-repo.sh ~/git/my-project${NC}"
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
