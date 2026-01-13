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
