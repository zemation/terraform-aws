terraform {
  backend "s3" {
    bucket       = "zemation-terraform-state"
    key          = "aws/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
