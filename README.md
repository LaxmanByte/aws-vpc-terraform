# 🏗️ AWS VPC Infrastructure with Terraform



I automated AWS VPC deployment using Infrastructure as Code, reducing infrastructure setup you run set up time under 1 hour andeverything built automatically!

### 🎯 what I built 
I automated the entire VPC setup using Terraform, achieving:

⚡ 95% faster deployment - under 1 hour
✔️ Zero configuration errors - Automated and validated
🔄 100% reproducible - Same setup every time
🤝 Team-ready - Version controlled and documented

```I built 16 AWS resources deployed automatically
✅ 1 VPC (Virtual Private Cloud)
✅ 3 Public Subnets (with internet access)
✅ 3 Private Subnets (secure, no direct internet)
✅ 1 Internet Gateway
✅ 2 Route Tables (public & private)
✅ Proper subnet associations
✅ High availability across 3 Availability Zones
```

---

## 🎨 Architecture Diagram

```
                           ┌─────────────────────┐
                           │   clarus-vpc-a      │
                           │   10.7.0.0/16       │
                           └──────────┬──────────┘
                                      │
                          ┌───────────┴───────────┐
                          │  Internet Gateway     │
                          │    (clarus-igw)       │
                          └───────────┬───────────┘
                                      │
                ┌─────────────────────┼─────────────────────┐
                │                     │                     │
         ┌──────┴──────┐      ┌──────┴──────┐      ┌──────┴──────┐
         │    AZ-1a    │      │    AZ-1b    │      │    AZ-1c    │
         │             │      │             │      │             │
    ┌────┴─────┬──────┐  ┌───┴──────┬──────┐  ┌───┴──────┬──────┐
    │  Public  │Private│  │  Public  │Private│  │  Public  │Private│
    │10.7.1.0/24│10.7.2.0/24│ │10.7.4.0/24│10.7.5.0/24│ │10.7.7.0/24│10.7.8.0/24│
    └──────────┴──────┘  └──────────┴──────┘  └──────────┴──────┘
       (251 IPs each)       (251 IPs each)       (251 IPs each)
```

---

##  Start Guide

### Prerequisites


1. **AWS Account** - [Sign up for free](https://aws.amazon.com/free/)
2. **AWS CLI installed** - [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. **Terraform installed** - [Installation guide](https://developer.hashicorp.com/terraform/downloads)

### Step 1: Install Terraform

**MacOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows:**
```bash
choco install terraform
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

Verify installation:
```bash
terraform --version
# Should show: Terraform v1.x.x
```

###  Configure AWS Credentials

```bash
aws configure
```

Enter your credentials:
```
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: us-east-1
Default output format: json
```



### Initialize Terraform

This downloads the AWS provider plugin (like installing the app):

```bash
terraform init
```

successful:
```
Terraform has been successfully initialized!
```

### Preview  Built

This shows you EXACTLY what Terraform will create (like a blueprint review):

```bash
terraform plan
```

You'll see:
```
Plan: 16 to add, 0 to change, 0 to destroy
```

This means Terraform will create 16 AWS resources!

### Step 6: Build Infrastructure! 🎉

```bash
terraform apply
```

Typed `yes` when prompted.



done,
```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:

vpc_id = "vpc-0a1b2c3d4e5f6g7h8"
public_subnet_ids = [
  "subnet-abc123",
  "subnet-def456",
  "subnet-ghi789",
]
...
```

###  Verify in AWS Console

Go to AWS Console → VPC Dashboard

You should see:
- Your VPC: `clarus-vpc-a`
- 6 Subnets (3 public, 3 private)
- 1 Internet Gateway: `clarus-igw`
- 2 Route Tables

---

## 🔧 Customization

### I can Change Region

Edit `variables.tf` or create `terraform.tfvars`:

```hcl
# terraform.tfvars
aws_region = "us-west-2"  # Change to your preferred region
```

### Here I can Change IP Ranges

```hcl
# terraform.tfvars
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24",
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24",
]
```

### Here I can Change Project Name

```hcl
# terraform.tfvars
project_name = "mycompany"  # All resources will be named mycompany-*
```

---

## 🗑️ Cleanup (Destroy Everything)

**WARNING:** This deletes ALL resources created by this project!

```bash
terraform destroy
```

Type `yes` when prompted.

---

## 📁This is my  Project Structure ed

```
aws-vpc-clarus/
│
├── main.tf              # 📘 Main infrastructure code
│                        #    (VPC, subnets, gateways, routes)
│
├── variables.tf         # 🎨 Customization options
│                        #    (region, CIDR blocks, names)
│
├── outputs.tf           # 📦 Information shown after building
│                        #    (VPC ID, subnet IDs, etc.)
│
├── README.md            # 📖 This file - instructions for humans
│
├── .gitignore           # 🔒 Files NOT to share on GitHub
│                        #    (secrets, state files)
│
└── terraform.tfvars     # ⚙️ Your custom values (optional)
                         #    (Create this file for customization)
```

### Why This Structure?

| File | Analogy | Purpose |
|------|---------|---------|
| `main.tf` | LEGO instructions | Step-by-step building guide |
| `variables.tf` | Order form | Choose sizes, colors, options |
| `outputs.tf` | Receipt | Shows what you got |
| `README.md` | User manual | Instructions for humans |
| `.gitignore` | Privacy lock | Don't share secrets |

---

## 🎓 Learning Resources

### Understanding Key Concepts

**What is a VPC?**
- Like your own private data center in AWS
- Isolated network where you control everything

**What is a Subnet?**
- Section of your VPC
- Public subnet = has internet access
- Private subnet = no direct internet (more secure)

**What is CIDR (10.7.0.0/16)?**
- Way to specify IP address ranges
- `/16` = 65,536 IP addresses
- `/24` = 256 IP addresses (251 usable)

**Why 3 Availability Zones?**
- High availability
- If one data center fails, others keep running
- AWS best practice

### Terraform Commands Cheat Sheet

```bash
# Initialize project (download providers)
terraform init

# Format code nicely
terraform fmt

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy everything
terraform destroy

# Show current state
terraform show

# List all resources
terraform state list

# Show specific output
terraform output vpc_id
```

---

## 🐛 Troubleshooting

### Issue: "Error: No valid credential sources found"

**Solution:** Configure AWS credentials:
```bash
aws configure
```

### Issue: "Error: error creating VPC: VpcLimitExceeded"

**Solution:** You've reached your VPC limit (default is 5 per region)
- Delete unused VPCs in AWS Console
- Or request a limit increase

### Issue: "Error: Provider produced inconsistent result after apply"

**Solution:** Run again:
```bash
terraform plan
terraform apply
```

### Issue: Can't access EC2 instances in public subnet

**Solution:** Check:
1. Security group allows your IP
2. Instance is in a PUBLIC subnet
3. Route table has route to Internet Gateway
4. Instance has public IP assigned

---

## 💡 Next Steps

After building  VPC, I will build or just update some changes to Iac :

1. **Launch EC2 Instances**
   ```bash
   # Launch in public subnet (gets public IP)
   # Launch in private subnet (no internet, secure)
   ```

2. **Add a NAT Gateway**
   - Allows private subnets to download updates
   - Keeps them secure (no inbound internet access)

3. **Add Security Groups**
   - Control inbound/outbound traffic
   - Like firewalls for your instances

4. **Add Load Balancers**
   - Distribute traffic across multiple servers
   - High availability

5. **Add Auto Scaling**
   - Automatically add/remove servers based on load

---

## 🤝 Contributing

Found a bug? Want to improve this?

1. Fork this repository
2. Make your changes
3. Submit a pull request

---

## 📜 License

This project is free to use for learning purposes!

---

successfully I learned and build vpc and its components with Iac
---

## 🎉 !

You've successfully learned Infrastructure as Code! 

**What you've accomplished:**
- ✅ Built a production-ready VPC
- ✅ Used Terraform to automate AWS
- ✅ Learned about networking concepts
- ✅ Can now replicate this in ANY AWS account

**Before (Manual):** 30+ minutes of clicking  
**Now (IaC):** 2 minutes with one command! 🚀

---

Made with ❤️ for DevOps learners
