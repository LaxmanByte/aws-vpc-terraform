#!/bin/bash

# ============================================================================
# VPC Cleanup Script - Destroy Infrastructure
# ============================================================================
# This script safely destroys all AWS resources created by Terraform
# Use this when you're done learning to avoid AWS charges
# ============================================================================

set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "============================================================================"
    echo "  $1"
    echo "============================================================================"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============================================================================
# WARNING
# ============================================================================

print_header "VPC Infrastructure Cleanup"

echo ""
print_warning "WARNING: This will PERMANENTLY DELETE the following resources:"
echo ""
echo "  • VPC and all subnets"
echo "  • Internet Gateway"
echo "  • Route Tables"
echo "  • All associations"
echo ""
print_error "This action CANNOT be undone!"
echo ""

# ============================================================================
# SAFETY CHECKS
# ============================================================================

# Check if terraform state exists
if [ ! -f terraform.tfstate ]; then
    print_error "No terraform.tfstate found!"
    echo "Either:"
    echo "  1. You haven't deployed anything yet"
    echo "  2. You're in the wrong directory"
    exit 1
fi

# Show what will be destroyed
print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_info "Resources that will be destroyed:"
echo ""
terraform state list
echo ""

# ============================================================================
# CONFIRMATION
# ============================================================================

echo ""
read -p "Type 'destroy' to confirm deletion: " CONFIRM

if [[ ! $CONFIRM == "destroy" ]]; then
    print_warning "Cleanup cancelled by user"
    echo "No resources were deleted."
    exit 0
fi

echo ""

# Double confirmation
read -p "Are you ABSOLUTELY sure? (yes/no): " DOUBLE_CONFIRM

if [[ ! $DOUBLE_CONFIRM == "yes" ]]; then
    print_warning "Cleanup cancelled by user"
    echo "No resources were deleted."
    exit 0
fi

echo ""

# ============================================================================
# DESTROY
# ============================================================================

print_header "Destroying Infrastructure"

print_info "Running: terraform destroy"
echo ""

terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    echo ""
    print_success "All infrastructure has been destroyed! 🗑️"
    echo ""
    
    # Clean up local files
    print_info "Cleaning up local files..."
    
    if [ -f tfplan ]; then
        rm tfplan
        print_success "Removed tfplan"
    fi
    
    if [ -f deployment-info.txt ]; then
        rm deployment-info.txt
        print_success "Removed deployment-info.txt"
    fi
    
    echo ""
    print_header "Cleanup Complete"
    echo ""
    echo "Your AWS account is now clean!"
    echo ""
    echo "To deploy again:"
    echo "  ./deploy.sh"
    echo ""
    
else
    echo ""
    print_error "Destroy failed!"
    echo ""
    echo "Common issues:"
    echo "  1. Resources are still in use (EC2 instances, etc.)"
    echo "  2. Manual changes in AWS Console"
    echo "  3. Permission issues"
    echo ""
    echo "Try:"
    echo "  1. Check AWS Console for manual resources"
    echo "  2. Run: terraform destroy (and review errors)"
    echo "  3. Manually delete resources in AWS Console"
    exit 1
fi
