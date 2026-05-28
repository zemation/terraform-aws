variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "zemation"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing AWS key pair to use for SSH access"
  type        = string
}

variable "sysinfo_version" {
  description = "sysinfo GitHub release version to install"
  type        = string
  default     = "v1.0.0"
}
