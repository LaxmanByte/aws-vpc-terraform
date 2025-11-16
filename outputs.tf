# ============================================================================
# OUTPUTS.TF - Your Receipt After Building
# ============================================================================
# After Terraform builds everything, these outputs show you important info
# Think of this as the receipt you get after construction is complete
# ============================================================================

# ----------------------------------------------------------------------------
# VPC OUTPUTS (Building Information)
# ----------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of your VPC (like your building's unique identification number)"
  value       = aws_vpc.clarus_vpc.id
  
  # Example output: vpc-0123456789abcdef0
  # Use this when you need to reference your VPC in other projects
}

output "vpc_cidr_block" {
  description = "The CIDR block of your VPC (your building's address range)"
  value       = aws_vpc.clarus_vpc.cidr_block
  
  # Example output: 10.7.0.0/16
  # This shows the IP address range your VPC uses
}

output "vpc_arn" {
  description = "The ARN of your VPC (Amazon Resource Name - full AWS address)"
  value       = aws_vpc.clarus_vpc.arn
  
  # Example: arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0
  # Like the full mailing address of your building
}

# ----------------------------------------------------------------------------
# INTERNET GATEWAY OUTPUTS
# ----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway (your building's main entrance ID)"
  value       = aws_internet_gateway.clarus_igw.id
  
  # Example: igw-0123456789abcdef0
}

# ----------------------------------------------------------------------------
# PUBLIC SUBNET OUTPUTS (Floors with Balconies)
# ----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs (all floors with internet access)"
  value = [
    aws_subnet.public_az1a.id,
    aws_subnet.public_az1b.id,
    aws_subnet.public_az1c.id,
  ]
  
  # Example output: ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
  # Use these when launching web servers, load balancers, etc.
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value = [
    aws_subnet.public_az1a.cidr_block,
    aws_subnet.public_az1b.cidr_block,
    aws_subnet.public_az1c.cidr_block,
  ]
  
  # Example: ["10.7.1.0/24", "10.7.4.0/24", "10.7.7.0/24"]
}

output "public_subnet_azs" {
  description = "Availability Zones where public subnets are located"
  value = [
    aws_subnet.public_az1a.availability_zone,
    aws_subnet.public_az1b.availability_zone,
    aws_subnet.public_az1c.availability_zone,
  ]
  
  # Example: ["us-east-1a", "us-east-1b", "us-east-1c"]
  # Shows which data centers your subnets are in
}

# ----------------------------------------------------------------------------
# PRIVATE SUBNET OUTPUTS (Interior Floors, No Internet)
# ----------------------------------------------------------------------------

output "private_subnet_ids" {
  description = "List of private subnet IDs (floors without direct internet access)"
  value = [
    aws_subnet.private_az1a.id,
    aws_subnet.private_az1b.id,
    aws_subnet.private_az1c.id,
  ]
  
  # Use these for databases, backend servers, internal services
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value = [
    aws_subnet.private_az1a.cidr_block,
    aws_subnet.private_az1b.cidr_block,
    aws_subnet.private_az1c.cidr_block,
  ]
  
  # Example: ["10.7.2.0/24", "10.7.5.0/24", "10.7.8.0/24"]
}

output "private_subnet_azs" {
  description = "Availability Zones where private subnets are located"
  value = [
    aws_subnet.private_az1a.availability_zone,
    aws_subnet.private_az1b.availability_zone,
    aws_subnet.private_az1c.availability_zone,
  ]
}

# ----------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS (Direction Signs)
# ----------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table (directions to internet)"
  value       = aws_route_table.public_rt.id
  
  # This route table has a route to the Internet Gateway
}

output "private_route_table_id" {
  description = "ID of the private route table (internal-only directions)"
  value       = aws_route_table.private_rt.id
  
  # This route table has NO route to internet = secure
}

# ----------------------------------------------------------------------------
# REGION AND AVAILABILITY ZONE INFORMATION
# ----------------------------------------------------------------------------

output "aws_region" {
  description = "AWS region where infrastructure was created"
  value       = var.aws_region
  
  # Example: "us-east-1"
}

output "availability_zones" {
  description = "List of Availability Zones used"
  value       = data.aws_availability_zones.available.names
  
  # Shows all available AZs in your region
}

# ----------------------------------------------------------------------------
# SUMMARY OUTPUT (Everything at a Glance)
# ----------------------------------------------------------------------------

output "vpc_summary" {
  description = "Complete summary of your VPC setup"
  value = {
    vpc_id     = aws_vpc.clarus_vpc.id
    vpc_cidr   = aws_vpc.clarus_vpc.cidr_block
    region     = var.aws_region
    
    public_subnets = {
      count = length([aws_subnet.public_az1a.id, aws_subnet.public_az1b.id, aws_subnet.public_az1c.id])
      ids   = [aws_subnet.public_az1a.id, aws_subnet.public_az1b.id, aws_subnet.public_az1c.id]
    }
    
    private_subnets = {
      count = length([aws_subnet.private_az1a.id, aws_subnet.private_az1b.id, aws_subnet.private_az1c.id])
      ids   = [aws_subnet.private_az1a.id, aws_subnet.private_az1b.id, aws_subnet.private_az1c.id]
    }
    
    internet_gateway = aws_internet_gateway.clarus_igw.id
  }
  
  # This gives you EVERYTHING in one organized view!
}

# ============================================================================
# HOW TO USE THESE OUTPUTS
# ============================================================================
# After running 'terraform apply', you'll see all these outputs
# 
# Example:
# 
# Outputs:
# 
# vpc_id = "vpc-0a1b2c3d4e5f6g7h8"
# public_subnet_ids = [
#   "subnet-abc123",
#   "subnet-def456", 
#   "subnet-ghi789"
# ]
# 
# You can use these in other Terraform projects:
# data "terraform_remote_state" "vpc" {
#   backend = "local"
#   config = {
#     path = "../aws-vpc-clarus/terraform.tfstate"
#   }
# }
# 
# resource "aws_instance" "web" {
#   subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
# }
# 
# Or reference them in scripts:
# VPC_ID=$(terraform output -raw vpc_id)
# aws ec2 describe-vpcs --vpc-ids $VPC_ID
# ============================================================================
