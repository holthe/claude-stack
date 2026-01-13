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

# Paths
export STACK_DIR="$HOME/git/claude-stack"
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
