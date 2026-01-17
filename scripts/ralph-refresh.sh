#!/bin/bash
#
# Refresh agents using Ralph Wiggum loop for thorough execution
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROMPT_FILE="$STACK_DIR/prompts/analyze-and-update.md"
MAX_ITERATIONS="${1:-25}"

# Validate MAX_ITERATIONS is a positive integer
if ! validate_positive_integer "$MAX_ITERATIONS" "max-iterations"; then
    echo ""
    echo "Usage: $0 [max-iterations]"
    echo "  max-iterations: positive integer (default: 25)"
    exit 1
fi

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

# Build --add-dir arguments using array (safe for paths with spaces)
ADD_DIR_ARGS=()
while IFS= read -r repo; do
    if [ -n "$repo" ]; then
        ADD_DIR_ARGS+=("--add-dir" "$repo")
    fi
done < <(get_repos)

# Substitute {{STACK_DIR}} placeholder with actual path
# Use a temp file to avoid issues with large prompts and special characters
TEMP_PROMPT=$(mktemp)
trap 'rm -f "$TEMP_PROMPT"' EXIT

sed "s|{{STACK_DIR}}|$STACK_DIR|g" "$PROMPT_FILE" > "$TEMP_PROMPT"

# Run with Ralph loop, granting access to all configured repos
cd "$STACK_DIR" || exit 1
claude "${ADD_DIR_ARGS[@]}" -p "/ralph-loop $(cat "$TEMP_PROMPT") --max-iterations $MAX_ITERATIONS"

echo ""
echo -e "${GREEN}✓${NC} Ralph refresh complete!"
echo ""
