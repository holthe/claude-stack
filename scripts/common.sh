#!/bin/bash
#
# Common functions for Claude Code Agent Stack scripts
#

# Safer shell options (scripts sourcing this should also use these)
# Note: We don't set these here as it affects the sourcing script
# Each script should use: set -euo pipefail

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# Paths - derive STACK_DIR from this script's location
# common.sh is in scripts/, so STACK_DIR is one level up
COMMON_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STACK_DIR="$(cd "$COMMON_SCRIPT_DIR/.." && pwd)"
export USER_AGENTS="$HOME/.claude/agents"
export REPOS_CONF="$STACK_DIR/config/repos.conf"

# Validate a path for safety (no control characters, reasonable length)
# Returns 0 if valid, 1 if invalid
validate_path() {
    local path="$1"

    # Check for control characters (including null bytes)
    if [[ "$path" =~ [[:cntrl:]] ]]; then
        echo "WARNING: Path contains control characters, skipping: $path" >&2
        return 1
    fi

    # Check for reasonable length (max 4096 characters - Linux PATH_MAX)
    if [ "${#path}" -gt 4096 ]; then
        echo "WARNING: Path too long, skipping: ${path:0:50}..." >&2
        return 1
    fi

    # Check for empty path
    if [ -z "$path" ]; then
        return 1
    fi

    return 0
}

# Get list of configured repositories (with validation)
get_repos() {
    if [ ! -f "$REPOS_CONF" ]; then
        return
    fi

    # Read non-empty, non-comment lines
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue

        # Expand ~ to $HOME
        local expanded="${line/#\~/$HOME}"

        # Validate the path
        if ! validate_path "$expanded"; then
            continue
        fi

        # Check if directory exists
        if [ -d "$expanded" ]; then
            echo "$expanded"
        fi
    done < "$REPOS_CONF"
}

# Check if repos are configured
check_repos_configured() {
    local repos
    repos=$(get_repos)
    if [ -z "$repos" ]; then
        echo -e "${YELLOW}⚠️  No repositories configured${NC}"
        echo ""
        echo "Add repository paths to: $REPOS_CONF"
        echo ""
        echo "Example:"
        echo "  echo '\$HOME/git/maggie' >> $REPOS_CONF"
        echo "  echo '\$HOME/git/two-socks' >> $REPOS_CONF"
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
    while IFS= read -r repo; do
        if [ -n "$repo" ]; then
            local name
            name=$(basename "$repo")
            echo -e "  ${GREEN}✓${NC} $name ($repo)"
        fi
    done < <(get_repos)
}

# Validate that a value is a positive integer
validate_positive_integer() {
    local value="$1"
    local name="${2:-value}"

    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: $name must be a positive integer, got: $value${NC}" >&2
        return 1
    fi

    if [ "$value" -eq 0 ]; then
        echo -e "${RED}Error: $name must be greater than 0${NC}" >&2
        return 1
    fi

    return 0
}

# Sanitize a string for use in filenames (alphanumeric, dash, underscore only)
sanitize_filename() {
    local input="$1"
    echo "$input" | tr -cd 'a-zA-Z0-9_-'
}
