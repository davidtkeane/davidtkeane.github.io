#!/bin/bash
# publish.sh - Quick publish to GitHub Pages
#
# USAGE:
#   ./publish.sh                      # Interactive mode
#   ./publish.sh "Commit message"     # Quick publish with message
#   ./publish.sh -y                   # Auto-confirm with auto-message
#   ./publish.sh -y "Commit message"  # Auto-confirm with custom message
#   ./publish.sh --help               # Show this help
#
# WHAT IT DOES:
#   1. Checks for uncommitted changes (exits if none)
#   2. Shows preview of what will be published
#   3. Counts new/modified posts in _posts/
#   4. Prompts for commit message (or auto-generates from post title)
#   5. Asks for confirmation (Y/n) with 10 second timeout
#   6. Stages, commits, and pushes to GitHub
#
# AUTO-COMMIT MESSAGES:
#   - New post detected: "Add post: [Title from front matter]"
#   - Other changes: "Update blog - YYYY-MM-DD HH:MM"
#   - Custom message: Type your own when prompted
#
# EXAMPLES:
#   ./publish.sh                       # Interactive publish
#   ./publish.sh "Fix typo in post"    # Quick publish
#   ./publish.sh -y                    # Full auto mode
#   [Press Enter]                      # Use auto-generated message
#   [Type message]                     # Use custom commit message
#   [Press Y or Enter]                 # Confirm and publish
#   [Press N]                          # Cancel publish
#
# REQUIREMENTS:
#   - Must be run from blog root directory
#   - Git repository must be initialized
#   - Remote 'origin' must be configured
#
# NOTES:
#   - GitHub Actions will build the site automatically
#   - Site goes live in ~2-3 minutes after push
#   - Check build status: https://github.com/davidtkeane/davidtkeane.github.io/actions

set -e  # Exit on error

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

# Parse arguments
AUTO_CONFIRM=false
COMMIT_MSG=""

show_help() {
    echo "Usage: ./publish.sh [OPTIONS] [COMMIT MESSAGE]"
    echo ""
    echo "Options:"
    echo "  -y, --yes      Auto-confirm (no prompts)"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./publish.sh                        # Interactive mode"
    echo "  ./publish.sh \"Add new blog post\"    # Quick publish with message"
    echo "  ./publish.sh -y                     # Full auto mode"
    echo "  ./publish.sh -y \"Quick fix\"         # Auto with custom message"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            COMMIT_MSG="$1"
            shift
            ;;
    esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    CHIRPY BLOG PUBLISHER${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check for uncommitted changes
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${YELLOW}[!] No changes to publish${NC}"
    exit 0
fi

# Show what's changed
echo -e "${CYAN}Changes to publish:${NC}"
echo ""
git status --short
echo ""

# Count new posts
new_posts=$(git status --porcelain | grep "_posts/" | wc -l | tr -d ' ')
if [[ $new_posts -gt 0 ]]; then
    echo -e "${GREEN}[+] New/modified posts: $new_posts${NC}"
fi

# Get commit message if not provided via argument
if [[ -z "$COMMIT_MSG" ]]; then
    if [[ "$AUTO_CONFIRM" == "false" ]]; then
        echo ""
        echo -e "${YELLOW}Enter commit message (or press Enter for auto-message):${NC}"
        read -r user_message
        COMMIT_MSG="$user_message"
    fi
fi

# Auto-generate message if still empty
if [[ -z "$COMMIT_MSG" ]]; then
    if [[ $new_posts -gt 0 ]]; then
        # Get first new post title
        post_file=$(git status --porcelain | grep "_posts/" | head -1 | awk '{print $2}')
        if [[ -f "$post_file" ]]; then
            post_title=$(grep "^title:" "$post_file" | head -1 | sed 's/title: *"\(.*\)"/\1/' | sed "s/title: *'\(.*\)'/\1/")
            COMMIT_MSG="Add post: $post_title"
        else
            COMMIT_MSG="Update blog content"
        fi
    else
        COMMIT_MSG="Update blog - $(date '+%Y-%m-%d %H:%M')"
    fi
fi

echo ""
echo -e "${CYAN}Commit message: ${NC}$COMMIT_MSG"
echo ""

# Confirm (skip if auto-confirm)
if [[ "$AUTO_CONFIRM" == "false" ]]; then
    echo -e "${YELLOW}Publish to GitHub? [Y/n]${NC}"
    read -t 10 -n 1 confirm || confirm="y"
    echo ""

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}[!] Publish cancelled${NC}"
        exit 0
    fi
fi

# Stage all changes
echo -e "${CYAN}[1/3] Staging changes...${NC}"
git add .

# Commit
echo -e "${CYAN}[2/3] Committing...${NC}"
git commit -m "$COMMIT_MSG"

# Push
echo -e "${CYAN}[3/3] Pushing to GitHub...${NC}"
git push

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}    PUBLISHED SUCCESSFULLY!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "GitHub Actions will now build your site."
echo -e "Check progress: ${CYAN}https://github.com/davidtkeane/davidtkeane.github.io/actions${NC}"
echo ""
echo -e "Site will be live in ~2-3 minutes at:"
echo -e "${CYAN}https://davidtkeane.github.io/${NC}"
