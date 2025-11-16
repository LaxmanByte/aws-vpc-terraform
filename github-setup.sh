#!/bin/bash

# Colors for terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   AWS VPC Terraform - GitHub Setup Assistant              ║"
echo "║   Running on Windows with Git Bash                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed!${NC}"
    exit 1
fi

echo -e "${YELLOW}��� Step 1: Your Information${NC}"
read -p "GitHub Username: " github_username
read -p "GitHub Email: " github_email
read -p "Repository Name (default: aws-vpc-terraform): " repo_name
repo_name=${repo_name:-aws-vpc-terraform}

echo ""
echo -e "${YELLOW}��� Summary:${NC}"
echo "  Username: $github_username"
echo "  Email: $github_email"
echo "  Repo: $repo_name"
read -p "Correct? (yes/no): " confirm
if [[ ! "$confirm" == "yes" ]]; then
    echo "Cancelled."
    exit 1
fi

# Configure git
echo ""
echo -e "${BLUE}��� Step 2: Configuring Git${NC}"
git config --global user.name "$github_username"
git config --global user.email "$github_email"
echo "✓ Git configured"

# Initialize git repo
if [ ! -d .git ]; then
    echo -e "${BLUE}��� Step 3: Initializing Git Repository${NC}"
    git init
    git branch -M main
    echo "✓ Git initialized"
else
    echo -e "${YELLOW}✓ Git already initialized${NC}"
fi

# Create .gitignore
echo -e "${BLUE}��� Step 4: Creating .gitignore${NC}"
cat > .gitignore << 'GITIGNORE'
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
.terraform.lock.hcl
*.tfplan
.DS_Store
Thumbs.db
.vscode/
.idea/
*.log
*.swp
GITIGNORE
echo "✓ .gitignore created"

# Create LICENSE
echo -e "${BLUE}��� Step 5: Creating MIT License${NC}"
cat > LICENSE << 'LICENSEFILE'
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software.
LICENSEFILE
echo "✓ LICENSE created"

# Stage files
echo ""
echo -e "${BLUE}��� Step 6: Staging Files${NC}"
git add .
file_count=$(git diff --cached --name-only | wc -l)
echo "✓ Files staged: $file_count files"

# Commit
echo -e "${BLUE}��� Step 7: Creating Initial Commit${NC}"
git commit -m "Initial commit: AWS VPC Terraform Infrastructure

- Production-ready VPC with 6 subnets across 3 AZs
- Infrastructure as Code using Terraform
- Complete documentation included"
echo "✓ Commit created"

# Instructions for GitHub
echo ""
echo -e "${GREEN}✨ LOCAL SETUP COMPLETE!${NC}"
echo ""
echo -e "${YELLOW}��� Next: Create Repository on GitHub${NC}"
echo ""
echo "1. Go to: https://github.com/new"
echo "2. Repository name: $repo_name"
echo "3. Description: AWS VPC infrastructure with Terraform"
echo "4. Choose: Public"
echo "5. Click 'Create repository'"
echo ""

read -p "Press Enter after creating the repository on GitHub..."

# Push to GitHub
echo ""
echo -e "${BLUE}��� Step 8: Pushing to GitHub${NC}"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$github_username/$repo_name.git"
git push -u origin main

echo ""
echo -e "${GREEN}✅ SUCCESS!${NC}"
echo "Repository: https://github.com/$github_username/$repo_name"
