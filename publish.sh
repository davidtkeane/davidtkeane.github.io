#!/bin/bash
# publish.sh - Quick publish to GitHub Pages

set -e  # Exit on error

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m'

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
new_posts=$(git status --porcelain | grep "_posts/" | wc -l)
if [[ $new_posts -gt 0 ]]; then
    echo -e "${GREEN}[+] New/modified posts: $new_posts${NC}"
fi

# Get commit message
echo ""
echo -e "${YELLOW}Enter commit message (or press Enter for auto-message):${NC}"
read -r user_message

if [[ -z "$user_message" ]]; then
    # Auto-generate message
    if [[ $new_posts -gt 0 ]]; then
        # Get first new post title
        post_file=$(git status --porcelain | grep "_posts/" | head -1 | awk '{print $2}')
        if [[ -f "$post_file" ]]; then
            post_title=$(grep "^title:" "$post_file" | head -1 | sed 's/title: *"\(.*\)"/\1/' | sed "s/title: *'\(.*\)'/\1/")
            commit_msg="Add post: $post_title"
        else
            commit_msg="Update blog content"
        fi
    else
        commit_msg="Update blog - $(date '+%Y-%m-%d %H:%M')"
    fi
else
    commit_msg="$user_message"
fi

echo ""
echo -e "${CYAN}Commit message: ${NC}$commit_msg"
echo ""

# Confirm
echo -e "${YELLOW}Publish to GitHub? [Y/n]${NC}"
read -t 10 -n 1 confirm
echo ""

if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
    # Stage all changes
    echo -e "${CYAN}[1/3] Staging changes...${NC}"
    git add .

    # Commit
    echo -e "${CYAN}[2/3] Committing...${NC}"
    git commit -m "$commit_msg"

    # Push
    echo -e "${CYAN}[3/3] Pushing to GitHub...${NC}"
    git push

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    PUBLISHED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "GitHub Actions will now build your site."
    echo -e "Check progress: ${CYAN}https://github.com/YOUR-USERNAME/YOUR-REPO/actions${NC}"
    echo ""
    echo -e "Site will be live in ~2-3 minutes at:"
    echo -e "${CYAN}https://YOUR-USERNAME.github.io/${NC}"
else
    echo -e "${YELLOW}[!] Publish cancelled${NC}"
fi
