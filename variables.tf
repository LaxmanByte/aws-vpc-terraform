# ============================================================================
# VARIABLES.TF - Your Customization Menu
# ============================================================================
# This is like the options menu where you choose sizes, colors, and features
# Want to build in a different region? Change it here!
# Want different IP ranges? Change it here!
# ============================================================================

# ----------------------------------------------------------------------------
# BASIC CONFIGURATION VARIABLES
# ----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region where you want to build your VPC (like choosing a city)"
  type        = string
  default     = "us-east-1"
  
  # Example: Change to "us-west-2" to build in Oregon instead of Virginia
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  # This helps you organize: development, testing, or production
}

variable "project_name" {
  description = "Project name used for naming resources (like your company name)"
  type        = string
  default     = "clarus"
  
  # All resources will be named: clarus-vpc-a, clarus-igw, etc.
}

# ----------------------------------------------------------------------------
# VPC CONFIGURATION
# ----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC (the size of your apartment building)"
  type        = string
  default     = "10.7.0.0/16"
  
  # Explanation:
  # - 10.7.0.0/16 means you have 65,536 IP addresses to use
  # - Think of it as: Building can hold 65,536 apartments
  # - First two numbers (10.7) are fixed, last two can vary (0.0 to 255.255)
}

# ----------------------------------------------------------------------------
# SUBNET CONFIGURATION
# ----------------------------------------------------------------------------

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (floors with balconies/internet)"
  type        = list(string)
  default = [
    "10.7.1.0/24",  # AZ1a - 256 IP addresses (251 usable, AWS reserves 5)
    "10.7.4.0/24",  # AZ1b - 256 IP addresses
    "10.7.7.0/24",  # AZ1c - 256 IP addresses
  ]
  
  # Why these numbers?
  # - /24 means last number varies (0-255) = 256 total IPs
  # - AWS reserves 5 IPs, so you get 251 usable IPs per subnet
  # - Reserved IPs:
  #   - 10.7.1.0   = Network address
  #   - 10.7.1.1   = VPC router
  #   - 10.7.1.2   = DNS server
  #   - 10.7.1.3   = Future use
  #   - 10.7.1.255 = Broadcast
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (interior floors, no internet)"
  type        = list(string)
  default = [
    "10.7.2.0/24",  # AZ1a - 256 IP addresses
    "10.7.5.0/24",  # AZ1b - 256 IP addresses
    "10.7.8.0/24",  # AZ1c - 256 IP addresses
  ]
  
  # Private subnets are for databases, backend servers
  # They can't access internet directly = more secure!
}

# ----------------------------------------------------------------------------
# AVAILABILITY ZONES
# ----------------------------------------------------------------------------

variable "azs_count" {
  description = "Number of Availability Zones to use (how many buildings to build)"
  type        = number
  default     = 3
  
  # Why 3 AZs?
  # - High availability: If one building fails, others keep running
  # - AWS best practice: Spread resources across multiple locations
  # - Think: Don't put all your eggs in one basket!
}

# ----------------------------------------------------------------------------
# OPTIONAL: ADVANCED VARIABLES
# ----------------------------------------------------------------------------

variable "enable_dns_hostnames" {
  description = "Should instances get DNS names? (like giving apartments names instead of just numbers)"
  type        = bool
  default     = true
  
  # true  = Instances get friendly names like: ec2-12-34-56-78.compute-1.amazonaws.com
  # false = You only get IP addresses like: 10.7.1.45
}

variable "enable_dns_support" {
  description = "Should DNS resolution work inside VPC?"
  type        = bool
  default     = true
  
  # Keep this true unless you have a very specific reason
}

variable "tags" {
  description = "Additional tags to apply to all resources (like labels on your buildings)"
  type        = map(string)
  default = {
    Terraform   = "true"
    Project     = "VPC-Hands-On"
    CostCenter  = "Engineering"
  }
  
  # Tags help you:
  # - Track costs (how much does this project cost?)
  # - Organize resources (show me all dev resources)
  # - Automate tasks (backup all resources tagged "Production")
}

# ============================================================================
# VARIABLE VALIDATION (SAFETY CHECKS)
# ============================================================================
# These prevent you from making common mistakes

variable "instance_tenancy" {
  description = "Tenancy option for instances (default = shared hardware, dedicated = your own hardware)"
  type        = string
  default     = "default"
  
  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Tenancy must be 'default' or 'dedicated'. (Dedicated is VERY expensive!)"
  }
  
  # "default" = Share AWS hardware with other customers (cheaper)
  # "dedicated" = Get your own physical server (expensive, for compliance)
}

# ============================================================================
# EXAMPLE: HOW TO CUSTOMIZE THESE VARIABLES
# ============================================================================
# Option 1: Change defaults above
# Option 2: Create terraform.tfvars file (see terraform.tfvars.example)
# Option 3: Pass on command line: terraform apply -var="aws_region=us-west-2"
# Option 4: Set environment variables: export TF_VAR_aws_region="us-west-2"
