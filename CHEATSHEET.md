# 🚀 Quick Reference Cheat Sheet

## ⚡ 5-Minute Quick Start

```bash
# 1. Install Terraform
brew install terraform  # macOS
# or download from: https://developer.hashicorp.com/terraform/downloads

# 2. Configure AWS
aws configure

# 3. Deploy everything
./deploy.sh

# 4. When done, cleanup
./cleanup.sh
```

---

## 📋 Essential Terraform Commands

### Initialization & Setup
```bash
terraform init              # Download providers (first time setup)
terraform fmt               # Format code nicely
terraform validate          # Check for errors
```

### Planning & Deploying
```bash
terraform plan              # Preview what will be created
terraform plan -out=tfplan  # Save plan to file
terraform apply             # Deploy infrastructure
terraform apply tfplan      # Deploy using saved plan
terraform apply -auto-approve  # Deploy without confirmation
```

### Viewing Information
```bash
terraform show              # Show current state
terraform state list        # List all resources
terraform output            # Show all outputs
terraform output vpc_id     # Show specific output
```

### Making Changes
```bash
# Edit your .tf files, then:
terraform plan              # See what will change
terraform apply             # Apply changes
```

### Destroying
```bash
terraform destroy           # Delete everything
terraform destroy -auto-approve  # Delete without confirmation
```

---

## 🗺️ File Structure Reference

```
aws-vpc-clarus/
│
├── main.tf                 # 🏗️  Infrastructure code
├── variables.tf            # ⚙️  Customization options
├── outputs.tf              # 📊 Results/outputs
├── terraform.tfvars        # 🔐 YOUR values (not in git)
├── README.md               # 📖 Main documentation
├── BEGINNERS-GUIDE.md      # 🎓 Learning guide
├── ARCHITECTURE.md         # 🏛️  Architecture details
├── deploy.sh               # 🚀 Auto-deploy script
├── cleanup.sh              # 🗑️  Cleanup script
└── .gitignore              # 🔒 Privacy protection
```

---

## 🏗️ VPC Architecture Quick Facts

### IP Ranges
```
VPC:            10.7.0.0/16      (65,536 IPs)

Public Subnets:
├── AZ-1a:      10.7.1.0/24      (251 usable IPs)
├── AZ-1b:      10.7.4.0/24      (251 usable IPs)
└── AZ-1c:      10.7.7.0/24      (251 usable IPs)

Private Subnets:
├── AZ-1a:      10.7.2.0/24      (251 usable IPs)
├── AZ-1b:      10.7.5.0/24      (251 usable IPs)
└── AZ-1c:      10.7.8.0/24      (251 usable IPs)
```

### Resources Created
```
✓ 1  VPC
✓ 1  Internet Gateway
✓ 3  Public Subnets
✓ 3  Private Subnets
✓ 2  Route Tables
✓ 6  Route Table Associations
─────────────────────────
  16 Total Resources
```

---

## 🎯 Common Customizations

### Change Region
```hcl
# terraform.tfvars
aws_region = "us-west-2"  # Change from us-east-1
```

### Change IP Ranges
```hcl
# terraform.tfvars
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24",
]
```

### Change Project Name
```hcl
# terraform.tfvars
project_name = "mycompany"
```

---

## 🔍 Troubleshooting

### Issue: "No valid credential sources found"
```bash
# Solution 1: Configure AWS CLI
aws configure

# Solution 2: Set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

### Issue: "VpcLimitExceeded"
```bash
# Check VPC limit
aws ec2 describe-vpcs --region us-east-1

# Delete unused VPCs or request limit increase
```

### Issue: "Error locking state"
```bash
# If using remote state, someone else might be working
# Wait or force unlock (dangerous!):
terraform force-unlock LOCK_ID
```

### Issue: Can't destroy - resources in use
```bash
# 1. Check for manual resources (EC2, RDS, etc.)
# 2. Delete them first
# 3. Then run terraform destroy
```

---

## 📊 Understanding CIDR Notation

```
10.7.0.0/16
│  │ │ │ │
│  │ │ │ └── Network size (16 bits = 65,536 IPs)
│  │ │ └──── Last octet (variable)
│  │ └────── Third octet (variable)
│  └──────── Fixed (10.7)
└──────────── Private IP space

Common sizes:
/8  = 16,777,216 IPs (huge)
/16 = 65,536 IPs     (large - VPCs)
/24 = 256 IPs        (medium - subnets)
/32 = 1 IP           (single host)
```

---

## 🌐 AWS Reserved IPs (per subnet)

```
Example: 10.7.1.0/24 (256 total IPs)

Reserved by AWS:
├── 10.7.1.0     Network address
├── 10.7.1.1     VPC router
├── 10.7.1.2     DNS server
├── 10.7.1.3     Future use
└── 10.7.1.255   Broadcast

Usable: 10.7.1.4 → 10.7.1.254 (251 IPs)
```

---

## 🔐 Security Best Practices

```
✅ DO:
├── Use private subnets for databases
├── Use public subnets only when needed
├── Rotate AWS credentials regularly
├── Enable MFA on AWS account
├── Use .tfvars for secrets (in .gitignore)
└── Review terraform plan before apply

❌ DON'T:
├── Put databases in public subnets
├── Commit .tfvars to git
├── Share AWS credentials
├── Skip terraform plan
└── Run as root user
```

---

## 💰 Cost Information

### This VPC Setup
```
VPC:                 $0.00  ✓ FREE
Internet Gateway:    $0.00  ✓ FREE
Subnets:             $0.00  ✓ FREE
Route Tables:        $0.00  ✓ FREE
──────────────────────────
Total:               $0.00  ✓ FREE
```

### Typical Add-ons (Costs Money!)
```
EC2 t2.micro:        ~$8/month   (free tier: 750hrs/month)
NAT Gateway:         ~$32/month  (NOT free)
Load Balancer:       ~$16/month  (NOT free)
RDS db.t3.micro:     ~$12/month  (free tier: 750hrs/month)
```

---

## 🎓 Learn More

### Official Docs
```
Terraform:  https://developer.hashicorp.com/terraform
AWS VPC:    https://docs.aws.amazon.com/vpc/
AWS CLI:    https://docs.aws.amazon.com/cli/
```

### Helpful Commands
```bash
# Terraform
terraform --help
terraform plan --help

# AWS CLI
aws ec2 describe-vpcs
aws ec2 describe-subnets
aws ec2 describe-route-tables

# Check what's running
aws ec2 describe-instances --region us-east-1
```

---

## 🚀 Next Steps After VPC

### 1. Launch EC2 Instances
```bash
# In public subnet (gets public IP)
subnet_id = "subnet-xxx"  # public subnet
associate_public_ip = true

# In private subnet (no public IP)
subnet_id = "subnet-yyy"  # private subnet
```

### 2. Add NAT Gateway
```hcl
resource "aws_nat_gateway" "main" {
  subnet_id     = aws_subnet.public_az1a.id
  allocation_id = aws_eip.nat.id
}
```

### 3. Add Load Balancer
```hcl
resource "aws_lb" "main" {
  subnets = [
    aws_subnet.public_az1a.id,
    aws_subnet.public_az1b.id,
  ]
}
```

### 4. Add Auto Scaling
```hcl
resource "aws_autoscaling_group" "main" {
  min_size = 2
  max_size = 10
  vpc_zone_identifier = [
    aws_subnet.private_az1a.id,
    aws_subnet.private_az1b.id,
  ]
}
```

---

## 📞 Getting Help

### Common Resources
- Stack Overflow: `[terraform] [amazon-vpc]`
- AWS Forums: https://forums.aws.amazon.com
- Terraform Community: https://discuss.hashicorp.com

### Check Status
```bash
# AWS Service Health
https://status.aws.amazon.com

# Your AWS Resources
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

---

## ⚡ Power User Tips

### Format All Files
```bash
terraform fmt -recursive
```

### Generate Documentation
```bash
terraform show -json | jq
```

### View Graph
```bash
terraform graph | dot -Tpng > graph.png
```

### Import Existing Resources
```bash
terraform import aws_vpc.main vpc-12345678
```

### Targeted Apply/Destroy
```bash
terraform apply -target=aws_subnet.public_az1a
terraform destroy -target=aws_subnet.public_az1a
```

---

## 🎉 You're Ready!

**You now have:**
- ✅ Complete VPC infrastructure
- ✅ High availability across 3 AZs
- ✅ Public & private subnets
- ✅ Reusable, version-controlled code
- ✅ Professional Terraform skills

**Happy building!** 🚀
