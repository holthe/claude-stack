#!/bin/bash
#
# Refresh Claude Code agents based on current repository state
# Run monthly or after major project changes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROMPT_FILE="$STACK_DIR/prompts/analyze-and-update.md"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Claude Code Agent Refresh                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check repos configured
if ! check_repos_configured; then
    exit 1
fi

# Check prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}❌ Prompt file not found: $PROMPT_FILE${NC}"
    echo ""
    echo "Please save the analyze-and-update.md prompt to:"
    echo "  $PROMPT_FILE"
    exit 1
fi

# Check Claude Code is available
if ! command -v claude &> /dev/null; then
    echo -e "${RED}❌ Claude Code CLI not found${NC}"
    echo ""
    echo "Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Show configuration
echo -e "  Prompt file: ${GREEN}$PROMPT_FILE${NC}"
echo ""
print_repos
echo ""

# Confirm before running
echo -e "${YELLOW}This will analyze all configured repositories${NC}"
echo -e "${YELLOW}and update/create agents as needed.${NC}"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BLUE}Starting analysis...${NC}"
echo ""

# Build --add-dir arguments for each configured repo
ADD_DIR_ARGS=""
while IFS= read -r repo; do
    if [ -n "$repo" ]; then
        ADD_DIR_ARGS="$ADD_DIR_ARGS --add-dir $repo"
    fi
done < <(get_repos)

# Run Claude with the prompt, granting access to all configured repos
cd "$STACK_DIR"
claude $ADD_DIR_ARGS -p "$(cat "$PROMPT_FILE")"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Agent refresh complete!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Analysis reports: ${BLUE}$STACK_DIR/analysis/${NC}"
echo -e "  Shared agents:    ${BLUE}$STACK_DIR/agents/${NC}"
echo ""
