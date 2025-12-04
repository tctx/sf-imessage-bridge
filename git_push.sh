#!/bin/bash
# Helper script to commit and push changes to GitHub

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}📦 Git Commit & Push Helper${NC}"
echo ""

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    exit 0
fi

# Show status
echo -e "${GREEN}📋 Current changes:${NC}"
git status --short
echo ""

# Get commit message from argument or prompt
if [ -z "$1" ]; then
    echo -e "${YELLOW}Enter commit message (or press Enter for default):${NC}"
    read -r commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="Update: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
else
    commit_msg="$1"
fi

# Add all changes
echo -e "${GREEN}➕ Adding changes...${NC}"
git add .

# Commit
echo -e "${GREEN}💾 Committing changes...${NC}"
git commit -m "$commit_msg"

# Push
echo -e "${GREEN}🚀 Pushing to GitHub...${NC}"
if git push origin main; then
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
else
    echo -e "${RED}❌ Push failed. You may need to authenticate.${NC}"
    echo -e "${YELLOW}Try running: git push origin main${NC}"
    exit 1
fi

