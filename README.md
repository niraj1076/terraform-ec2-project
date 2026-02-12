Perfect ✅
Below is your **clean, copy-paste ready README.md**.
No emojis. No images. Fully structured. Recruiter-ready.

You can paste this directly into your `README.md`.

---

# Terraform EC2 Deployment on AWS

## Project Overview

This project demonstrates how to provision an EC2 instance on AWS using Terraform.

It includes:

* AWS authentication using Access Keys
* Dynamic Ubuntu 22.04 AMI lookup
* Security Group configuration (SSH and HTTP)
* Automated Nginx installation using user_data
* Output of public IP
* Infrastructure lifecycle management (apply and destroy)

---

# Architecture Flow

User → Internet → Security Group → EC2 (Ubuntu 22.04) → Nginx Web Server

---

# Project Structure

```
terraform-ec2-project/
│
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── .gitignore
```

---

# Prerequisites

Before starting, ensure you have:

* AWS Account
* IAM User with programmatic access
* Access Key and Secret Key
* Terraform installed
* AWS CLI installed

---

# Step 1: Create IAM User for Terraform

1. Login to AWS Console
2. Navigate to IAM
3. Click Users → Create User
4. Username: terraform-user
5. Select: Programmatic access
6. Attach policy: AdministratorAccess (for learning purpose)
7. Create user
8. Download Access Key ID and Secret Access Key

Store credentials securely.

---

# Step 2: Configure AWS CLI

Run:

```bash
aws configure
```

Enter:

```
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: ap-south-1  <- (here use the region name you are using)
Default output format: json
```

Verify configuration:

```bash
aws sts get-caller-identity
```

If successful, your AWS account details will be displayed.

---

# Step 3: Install Terraform (Linux Example)

```bash
sudo apt update
sudo apt install unzip -y
wget https://releases.hashicorp.com/terraform/<latest-version>/terraform_<latest-version>_linux_amd64.zip
unzip terraform_<latest-version>_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Verify:

```bash
terraform -v
```

---

# Step 4: Terraform Configuration Files

## provider.tf

```hcl
provider "aws" {
  region = var.region
}
```

---

## variables.tf

```hcl
variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name"
}
```

---

## main.tf

Replace YOUR_PUBLIC_IP with your public IP in CIDR format (example: 103.25.45.12/32).

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "ec2_sg" {
  name = "terraform-ec2-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "terraform-ec2"
  }
}
```

---

## terraform.tfvars

Replace with your existing AWS key pair name:

```hcl
key_name = "dev-key"
```

---

## outputs.tf

```hcl
output "public_ip" {
  value = aws_instance.ec2.public_ip
}
```

---

## .gitignore

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

---

# Step 5: Initialize Terraform

```bash
terraform init
```

---

# Step 6: Validate Configuration

```bash
terraform validate
```

---

# Step 7: Review Execution Plan

```bash
terraform plan
```

---

# Step 8: Deploy Infrastructure

```bash
terraform apply
```

Type:

```
yes
```

After successful deployment, Terraform will output:

```
public_ip = xx.xx.xx.xx
```

---

# Step 9: Verify Deployment

Open browser:

```
http://<public-ip>
```

You should see:

```
Welcome to nginx!
```

---

# Step 10: SSH into Instance

```bash
ssh -i dev-key.pem ubuntu@<public-ip>
```

---

# Step 11: Destroy Infrastructure

To avoid unnecessary AWS charges:

```bash
terraform destroy
```

Type:

```
yes
```

---
