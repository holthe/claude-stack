#!/bin/bash
#
# List all Claude Code agents (shared and project-specific)
#

set -euo pipefail

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
