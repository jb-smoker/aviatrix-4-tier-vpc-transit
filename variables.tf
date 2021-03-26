locals {
  aws_use1_vpcs = {
    client_spoke = {
      cidr = "10.1.0.0/16"
    }
    avx_transit = {
      cidr = "10.2.0.0/16"
    }
  }
  aws_usw2_vpcs = {
    compute_spoke = {
      cidr           = "10.3.0.0/16"
      secondary_cidr = "100.64.0.0/16"
    }
  }
  common_tags = {
    Env        = "stage"
    Repository = "aviatrix-4-tier-vpc-transit"
    Team       = "solutions architecture"
    Terraform  = true
  }
  common_tags_list = [
    "Env:stage",
    "Repository:aviatrix-4-tier-vpc-transit",
    "Team:solutions architecture",
    "Terraform:1",
  ]

  snat_policy = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

variable "ctl_password" {
  description = "Password for the avx controller"
  sensitive   = true
}

variable "customer_license_id" {
  description = "License for the avx controller"
  sensitive   = true
}

variable "account_name" {
  description = "Name of the avx account for the resource"
  default     = "controller"
}
