#!/bin/bash
#
# Set up symlinks for shared Claude Code agents
#

set -euo pipefail

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
