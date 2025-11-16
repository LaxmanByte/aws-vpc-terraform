#!/bin/bash

# ============================================================================
# VPC Deployment Script - Automated Setup
# ============================================================================
# This script automates the deployment of your AWS VPC infrastructure
# It checks prerequisites, initializes Terraform, and deploys everything
# ============================================================================

set -e  # Exit on any error

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

print_header "Step 1: Checking Prerequisites"

# Check if Terraform is installed
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version | head -n 1)
    print_success "Terraform is installed: $TERRAFORM_VERSION"
else
    print_error "Terraform is not installed!"
    echo ""
    echo "Please install Terraform first:"
    echo "  macOS:   brew install terraform"
    echo "  Linux:   https://developer.hashicorp.com/terraform/downloads"
    echo "  Windows: choco install terraform"
    exit 1
fi

# Check if AWS CLI is installed
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version)
    print_success "AWS CLI is installed: $AWS_VERSION"
else
    print_warning "AWS CLI is not installed (optional but recommended)"
    echo "  Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
fi

# Check if AWS credentials are configured
if [ -f ~/.aws/credentials ] || [ ! -z "$AWS_ACCESS_KEY_ID" ]; then
    print_success "AWS credentials found"
else
    print_error "AWS credentials not found!"
    echo ""
    echo "Please configure AWS credentials:"
    echo "  Option 1: Run 'aws configure'"
    echo "  Option 2: Set environment variables:"
    echo "    export AWS_ACCESS_KEY_ID='your-key-id'"
    echo "    export AWS_SECRET_ACCESS_KEY='your-secret-key'"
    exit 1
fi

echo ""

# ============================================================================
# CUSTOMIZATION (Optional)
# ============================================================================

print_header "Step 2: Configuration"

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    print_info "No terraform.tfvars found. Creating from template..."
    
    # Ask user if they want to customize
    read -p "Do you want to customize your VPC settings? (y/N): " CUSTOMIZE
    
    if [[ $CUSTOMIZE =~ ^[Yy]$ ]]; then
        print_info "Creating terraform.tfvars for customization..."
        
        # Prompt for region
        echo ""
        read -p "Enter AWS Region (default: us-east-1): " AWS_REGION
        AWS_REGION=${AWS_REGION:-us-east-1}
        
        # Prompt for environment
        read -p "Enter Environment (dev/staging/prod, default: dev): " ENVIRONMENT
        ENVIRONMENT=${ENVIRONMENT:-dev}
        
        # Prompt for project name
        read -p "Enter Project Name (default: clarus): " PROJECT_NAME
        PROJECT_NAME=${PROJECT_NAME:-clarus}
        
        # Create terraform.tfvars
        cat > terraform.tfvars <<EOF
# Auto-generated configuration
aws_region   = "$AWS_REGION"
environment  = "$ENVIRONMENT"
project_name = "$PROJECT_NAME"

# Using default VPC and subnet configurations
# Edit this file to customize IP ranges
EOF
        print_success "Created terraform.tfvars with your settings"
    else
        print_info "Using default values from variables.tf"
    fi
else
    print_success "Found existing terraform.tfvars"
fi

echo ""

# ============================================================================
# TERRAFORM INITIALIZATION
# ============================================================================

print_header "Step 3: Initializing Terraform"

print_info "Running: terraform init"
terraform init

if [ $? -eq 0 ]; then
    print_success "Terraform initialized successfully"
else
    print_error "Terraform initialization failed!"
    exit 1
fi

echo ""

# ============================================================================
# TERRAFORM VALIDATION
# ============================================================================

print_header "Step 4: Validating Configuration"

print_info "Running: terraform validate"
terraform validate

if [ $? -eq 0 ]; then
    print_success "Configuration is valid"
else
    print_error "Configuration validation failed!"
    exit 1
fi

echo ""

# ============================================================================
# TERRAFORM PLAN
# ============================================================================

print_header "Step 5: Planning Infrastructure"

print_info "Running: terraform plan"
terraform plan -out=tfplan

if [ $? -eq 0 ]; then
    print_success "Plan generated successfully"
else
    print_error "Planning failed!"
    exit 1
fi

echo ""

# ============================================================================
# COST ESTIMATE
# ============================================================================

print_header "Step 6: Cost Estimate"

print_info "Estimated Monthly Cost:"
echo ""
echo "  VPC:                    $0.00  (Free)"
echo "  Internet Gateway:       $0.00  (Free)"
echo "  Subnets (6):            $0.00  (Free)"
echo "  Route Tables (2):       $0.00  (Free)"
echo "  ────────────────────────────────────"
echo "  Total Infrastructure:   $0.00  ✓ FREE!"
echo ""
print_warning "Note: EC2 instances you launch later will incur charges"
echo ""

# ============================================================================
# DEPLOYMENT CONFIRMATION
# ============================================================================

print_header "Step 7: Ready to Deploy"

echo "This will create the following resources in AWS:"
echo ""
echo "  ✓ 1 VPC (10.7.0.0/16)"
echo "  ✓ 1 Internet Gateway"
echo "  ✓ 3 Public Subnets (with internet access)"
echo "  ✓ 3 Private Subnets (secure, no internet)"
echo "  ✓ 2 Route Tables (public & private)"
echo "  ✓ 6 Route Table Associations"
echo ""

read -p "Do you want to proceed with deployment? (yes/no): " CONFIRM

if [[ ! $CONFIRM == "yes" ]]; then
    print_warning "Deployment cancelled by user"
    print_info "To deploy later, run: terraform apply tfplan"
    exit 0
fi

echo ""

# ============================================================================
# TERRAFORM APPLY
# ============================================================================

print_header "Step 8: Deploying Infrastructure"

print_info "Deploying to AWS... (this takes ~2-3 minutes)"
terraform apply tfplan

if [ $? -eq 0 ]; then
    print_success "Infrastructure deployed successfully! 🎉"
else
    print_error "Deployment failed!"
    exit 1
fi

echo ""

# ============================================================================
# DISPLAY OUTPUTS
# ============================================================================

print_header "Step 9: Deployment Summary"

echo ""
print_success "Your VPC is ready!"
echo ""

# Get outputs
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "N/A")
REGION=$(terraform output -raw aws_region 2>/dev/null || echo "N/A")

echo "┌────────────────────────────────────────────────────────────┐"
echo "│                    DEPLOYMENT DETAILS                      │"
echo "├────────────────────────────────────────────────────────────┤"
echo "│ VPC ID:      $VPC_ID"
echo "│ Region:      $REGION"
echo "│ Status:      ✓ Active"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

print_info "View full outputs: terraform output"
echo ""

# ============================================================================
# NEXT STEPS
# ============================================================================

print_header "Next Steps"

echo "Your VPC infrastructure is now ready! Here's what you can do next:"
echo ""
echo "1️⃣  View your VPC in AWS Console:"
echo "    https://console.aws.amazon.com/vpc/home?region=$REGION"
echo ""
echo "2️⃣  Launch EC2 instances in your subnets:"
echo "    • Public subnet = gets public IP, internet access"
echo "    • Private subnet = no public IP, more secure"
echo ""
echo "3️⃣  Add more infrastructure:"
echo "    • NAT Gateway (for private subnet internet access)"
echo "    • Load Balancer (distribute traffic)"
echo "    • Auto Scaling (scale automatically)"
echo ""
echo "4️⃣  View all resources created:"
echo "    terraform state list"
echo ""
echo "5️⃣  To destroy everything later:"
echo "    terraform destroy"
echo ""

print_warning "Important: Remember to destroy resources when done learning to avoid charges!"

echo ""
print_header "Deployment Complete! 🚀"

# ============================================================================
# SAVE DEPLOYMENT INFO
# ============================================================================

# Create a deployment info file
cat > deployment-info.txt <<EOF
VPC Deployment Information
==========================
Deployed: $(date)
VPC ID: $VPC_ID
Region: $REGION

Commands:
---------
View outputs:     terraform output
Show resources:   terraform state list
Plan changes:     terraform plan
Apply changes:    terraform apply
Destroy all:      terraform destroy

AWS Console:
-----------
VPC Dashboard: https://console.aws.amazon.com/vpc/home?region=$REGION
EC2 Dashboard: https://console.aws.amazon.com/ec2/home?region=$REGION
EOF

print_success "Deployment info saved to: deployment-info.txt"
echo ""
