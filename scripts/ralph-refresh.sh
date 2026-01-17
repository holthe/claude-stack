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

# Build --add-dir arguments for each configured repo
ADD_DIR_ARGS=""
while IFS= read -r repo; do
    if [ -n "$repo" ]; then
        ADD_DIR_ARGS="$ADD_DIR_ARGS --add-dir $repo"
    fi
done < <(get_repos)

# Run with Ralph loop, granting access to all configured repos
# Substitute {{STACK_DIR}} placeholder with actual path
cd "$STACK_DIR"
PROMPT_CONTENT=$(cat "$PROMPT_FILE" | sed "s|{{STACK_DIR}}|$STACK_DIR|g")
claude $ADD_DIR_ARGS -p "/ralph-loop \"$PROMPT_CONTENT\" --max-iterations $MAX_ITERATIONS"

echo ""
echo -e "${GREEN}✓${NC} Ralph refresh complete!"
echo ""
