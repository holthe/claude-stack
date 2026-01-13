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
