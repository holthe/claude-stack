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

# Build repo list
REPO_LIST=""
while read -r repo; do
    if [ -n "$repo" ]; then
        if [ -n "$REPO_LIST" ]; then
            REPO_LIST="$REPO_LIST
- $repo"
        else
            REPO_LIST="- $repo"
        fi
    fi
done < <(get_repos)

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

# Create modified prompt
MODIFIED_PROMPT=$(sed "s|Scan all repositories in ~/git/ and analyze each one.|Analyze the following repositories:\n$REPO_LIST|g" "$PROMPT_FILE")

# Run with Ralph loop
cd "$STACK_DIR"
claude -p "/ralph-loop \"$MODIFIED_PROMPT\" --max-iterations $MAX_ITERATIONS"

echo ""
echo -e "${GREEN}✓${NC} Ralph refresh complete!"
echo ""
