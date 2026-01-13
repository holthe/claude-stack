#!/bin/bash
#
# Remove a repository from the Claude Code Agent Stack
# (Does not delete the repo itself, just removes from config)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [ -z "$1" ]; then
    echo -e "${BLUE}Remove Repository from Claude Code Agent Stack${NC}"
    echo ""
    echo "Usage: $0 <repo-name-or-path>"
    echo ""
    echo "This removes the repo from the config file."
    echo "It does NOT delete the repository or its agents."
    echo ""
    
    if check_repos_configured 2>/dev/null; then
        echo ""
        print_repos
    fi
    exit 0
fi

INPUT="$1"

# Find matching path
MATCHED_PATH=""
while read -r repo; do
    if [ -n "$repo" ]; then
        name=$(basename "$repo")
        expanded_input="${INPUT/#\~/$HOME}"
        if [ "$name" == "$INPUT" ] || [ "$repo" == "$INPUT" ] || [ "$repo" == "$expanded_input" ]; then
            MATCHED_PATH="$repo"
            break
        fi
    fi
done < <(get_repos)

if [ -z "$MATCHED_PATH" ]; then
    echo -e "${RED}❌ Repository not found in config: $INPUT${NC}"
    echo ""
    echo "Configured repositories:"
    get_repos | while read -r repo; do
        if [ -n "$repo" ]; then
            echo "  - $(basename "$repo") ($repo)"
        fi
    done
    exit 1
fi

REPO_NAME=$(basename "$MATCHED_PATH")

echo -e "Removing ${CYAN}$REPO_NAME${NC} from config..."
echo -e "  Path: $MATCHED_PATH"
echo ""

# Create temp file without the matched line
grep -v "^$MATCHED_PATH$" "$REPOS_CONF" > "$REPOS_CONF.tmp" || true
mv "$REPOS_CONF.tmp" "$REPOS_CONF"

echo -e "${GREEN}✓${NC} Removed from config"
echo ""
echo -e "${YELLOW}Note:${NC} The repository and its agents were NOT deleted."
echo "To re-add later: $STACK_DIR/scripts/add-repo.sh $MATCHED_PATH"
echo ""
