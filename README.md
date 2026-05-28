````
# terraform-aws

Terraform configuration for provisioning an AWS environment including VPC, subnets, security groups, IAM, and an EC2 instance. Uses cloud-init to bootstrap the server on first boot, including installation of the [sysinfo](https://github.com/zemation/sysinfo) CLI tool. Terraform state is stored remotely in S3 with DynamoDB state locking.

## Requirements

- Terraform >= 1.5.0
- AWS account with an IAM user and access keys configured
- AWS CLI installed and configured (`aws configure`)
- EC2 key pair created in AWS

## Project Structure

```
terraform-aws/
├── backend.tf           # S3 remote state and DynamoDB state locking
├── main.tf              # Provider, VPC, subnets, internet gateway, route tables
├── security.tf          # Security groups
├── ec2.tf               # EC2 instance and AMI lookup
├── iam.tf               # IAM role and instance profile
├── variables.tf         # Input variables
├── outputs.tf           # Instance IP, DNS, SSH command
├── cloud-init.yaml      # First boot provisioning script
├── terraform.tfvars     # Your values — never commit this
└── .gitignore
```

## Prerequisites

**1. Create S3 bucket for remote state**

```bash
aws s3api create-bucket \
  --bucket zemation-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket zemation-terraform-state \
  --versioning-configuration Status=Enabled
```

**2. Create DynamoDB table for state locking**

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**3. Create EC2 key pair**

```bash
aws ec2 create-key-pair \
  --key-name terraform-zemation \
  --key-type ed25519 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/terraform-zemation.pem

chmod 600 ~/.ssh/terraform-zemation.pem
```

## Usage

**1. Clone the repo**

```bash
git clone https://github.com/zemation/terraform-aws.git
cd terraform-aws
```

**2. Create your tfvars file**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
region          = "us-east-1"
project_name    = "zemation"
instance_type   = "t3.micro"
key_name        = "terraform-zemation"
sysinfo_version = "v1.0.0"
```

**3. Initialize**

```bash
terraform init
```

**4. Deploy**

```bash
terraform plan
terraform apply
```

**5. Connect**

After apply completes, Terraform outputs the SSH command:

```
ssh_command = "ssh -i ~/.ssh/terraform-zemation.pem ubuntu@<instance_ip>"
```

**6. Destroy**

```bash
terraform destroy
```

## What Gets Installed

On first boot cloud-init runs and installs:

| Tool | Version | Location |
|---|---|---|
| [sysinfo](https://github.com/zemation/sysinfo) | Configurable via `sysinfo_version` | `/usr/local/bin/sysinfo` |

## Variables

| Name | Description | Default |
|---|---|---|
| `region` | AWS region | `us-east-1` |
| `project_name` | Project name used for naming all resources | `zemation` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `key_name` | Name of the existing AWS key pair | required |
| `sysinfo_version` | sysinfo release tag to install | `v1.0.0` |

## Outputs

| Name | Description |
|---|---|
| `instance_id` | EC2 instance ID |
| `instance_ip` | Public IP address |
| `instance_dns` | Public DNS hostname |
| `ssh_command` | Ready-to-run SSH command |
| `vpc_id` | VPC ID |
| `subnet_id` | Public subnet ID |

## Infrastructure

| Resource | Name |
|---|---|
| VPC | `zemation-vpc` |
| Public Subnet | `zemation-public-subnet` |
| Internet Gateway | `zemation-igw` |
| Route Table | `zemation-public-rt` |
| Security Group | `zemation-sg` |
| IAM Role | `zemation-ec2-role` |
| EC2 Instance | `zemation-server` |

## Notes

- `terraform.tfvars` is gitignored — never commit your AWS credentials or token
- Default SSH user for Ubuntu AMIs on AWS is `ubuntu` not `root`
- AMI is dynamically looked up — always pulls the latest Ubuntu 24.04 LTS from Canonical
- cloud-init runs once on first boot — to re-run provisioning destroy and reapply
- S3 bucket and DynamoDB table must exist before running `terraform init`
````