# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

provider "aviatrix" {
  username      = "admin"
  controller_ip = "tbd"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 2.18.0"
    }
  }
}
