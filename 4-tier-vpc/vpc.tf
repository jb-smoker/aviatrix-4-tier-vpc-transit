module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=997cba4053bd8b4a5d2aed528073b8f02c013e93"

  name = var.name

  cidr                  = var.cidr
  secondary_cidr_blocks = [var.secondary_cidr]

  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = [
    cidrsubnet(var.cidr, 10, 0), cidrsubnet(var.cidr, 10, 1), cidrsubnet(var.cidr, 10, 2),   #public-lb-psf-subnet
    cidrsubnet(var.cidr, 10, 20), cidrsubnet(var.cidr, 10, 21), cidrsubnet(var.cidr, 10, 22) #aviatrix-spoke-subnet
  ]
  private_subnets = [
    cidrsubnet(var.secondary_cidr, 10, 4), cidrsubnet(var.secondary_cidr, 10, 5), cidrsubnet(var.secondary_cidr, 10, 6), #shared address space
    cidrsubnet(var.cidr, 10, 16), cidrsubnet(var.cidr, 10, 17), cidrsubnet(var.cidr, 10, 18)                             #internal-lb-private-subnet
  ]

  enable_ipv6 = true

  enable_nat_gateway = false
  single_nat_gateway = false

  tags = var.common_tags

  vpc_tags = merge(var.common_tags, {
    Name = var.name
  })

}

