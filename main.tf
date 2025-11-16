# ============================================================================
# MAIN.TF - The Heart of Your Infrastructure
# ============================================================================
# Think of this as the LEGO instruction manual that builds your AWS VPC
# Each "resource" block is like a step in the manual
# ============================================================================

# ----------------------------------------------------------------------------
# TERRAFORM CONFIGURATION
# ----------------------------------------------------------------------------
# This tells Terraform which version to use and which cloud provider (AWS)
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ----------------------------------------------------------------------------
# AWS PROVIDER CONFIGURATION
# ----------------------------------------------------------------------------
# This is like telling the builder: "We're building in the US East region"
provider "aws" {
  region = var.aws_region
  
  # Optional: Add default tags to ALL resources (like a signature on buildings)
  default_tags {
    tags = {
      Project     = "Clarus-VPC-Hands-On"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# ============================================================================
# STEP 1: BUILD THE APARTMENT BUILDING (VPC)
# ============================================================================
# This creates the main Virtual Private Cloud - your private network in AWS
resource "aws_vpc" "clarus_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Allow computers to have names (not just numbers)
  enable_dns_support   = true  # Allow name lookups
  
  tags = {
    Name = "${var.project_name}-vpc-a"
  }
}

# ============================================================================
# STEP 2: BUILD THE MAIN ENTRANCE (INTERNET GATEWAY)
# ============================================================================
# This is like the front door that connects your building to the street (internet)
resource "aws_internet_gateway" "clarus_igw" {
  vpc_id = aws_vpc.clarus_vpc.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ============================================================================
# STEP 3: BUILD THE FLOORS (SUBNETS)
# ============================================================================
# We're creating 6 subnets (floors) across 3 buildings (Availability Zones)
# 3 have balconies (public) and 3 are interior (private)

# --- BUILDING A (Availability Zone 1a) ---
resource "aws_subnet" "public_az1a" {
  vpc_id                  = aws_vpc.clarus_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]  # 10.7.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true  # Auto-assign public IPs (like giving everyone a balcony key)
  
  tags = {
    Name = "${var.project_name}-az1a-public-subnet"
    Type = "Public"
  }
}

resource "aws_subnet" "private_az1a" {
  vpc_id            = aws_vpc.clarus_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]  # 10.7.2.0/24
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name = "${var.project_name}-az1a-private-subnet"
    Type = "Private"
  }
}

# --- BUILDING B (Availability Zone 1b) ---
resource "aws_subnet" "public_az1b" {
  vpc_id                  = aws_vpc.clarus_vpc.id
  cidr_block              = var.public_subnet_cidrs[1]  # 10.7.4.0/24
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-az1b-public-subnet"
    Type = "Public"
  }
}

resource "aws_subnet" "private_az1b" {
  vpc_id            = aws_vpc.clarus_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]  # 10.7.5.0/24
  availability_zone = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name = "${var.project_name}-az1b-private-subnet"
    Type = "Private"
  }
}

# --- BUILDING C (Availability Zone 1c) ---
resource "aws_subnet" "public_az1c" {
  vpc_id                  = aws_vpc.clarus_vpc.id
  cidr_block              = var.public_subnet_cidrs[2]  # 10.7.7.0/24
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-az1c-public-subnet"
    Type = "Public"
  }
}

resource "aws_subnet" "private_az1c" {
  vpc_id            = aws_vpc.clarus_vpc.id
  cidr_block        = var.private_subnet_cidrs[2]  # 10.7.8.0/24
  availability_zone = data.aws_availability_zones.available.names[2]
  
  tags = {
    Name = "${var.project_name}-az1c-private-subnet"
    Type = "Private"
  }
}

# ============================================================================
# STEP 4: CREATE DIRECTION SIGNS (ROUTE TABLES)
# ============================================================================
# Route tables are like GPS directions telling traffic where to go

# --- PUBLIC ROUTE TABLE (Directions to the Internet) ---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.clarus_vpc.id
  
  tags = {
    Name = "${var.project_name}-public-rt"
    Type = "Public"
  }
}

# Add a route: "To reach the internet (0.0.0.0/0), use the main entrance (IGW)"
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"  # Anywhere on the internet
  gateway_id             = aws_internet_gateway.clarus_igw.id
}

# --- PRIVATE ROUTE TABLE (No Internet Access) ---
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.clarus_vpc.id
  
  tags = {
    Name = "${var.project_name}-private-rt"
    Type = "Private"
  }
  
  # Note: No route to internet gateway = no internet access (secure!)
}

# ============================================================================
# STEP 5: CONNECT FLOORS TO DIRECTION SIGNS (ROUTE TABLE ASSOCIATIONS)
# ============================================================================
# This tells each subnet which route table to use

# Connect public subnets to public route table
resource "aws_route_table_association" "public_az1a" {
  subnet_id      = aws_subnet.public_az1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_az1b" {
  subnet_id      = aws_subnet.public_az1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_az1c" {
  subnet_id      = aws_subnet.public_az1c.id
  route_table_id = aws_route_table.public_rt.id
}

# Connect private subnets to private route table
resource "aws_route_table_association" "private_az1a" {
  subnet_id      = aws_subnet.private_az1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_az1b" {
  subnet_id      = aws_subnet.private_az1b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_az1c" {
  subnet_id      = aws_subnet.private_az1c.id
  route_table_id = aws_route_table.private_rt.id
}

# ============================================================================
# DATA SOURCES
# ============================================================================
# These fetch information from AWS (like looking up the phone book)

# Get list of available Availability Zones in your region
data "aws_availability_zones" "available" {
  state = "available"
}
