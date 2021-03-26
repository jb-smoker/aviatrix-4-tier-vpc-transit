module "aws_usw2_vpcs" {
  for_each       = local.aws_usw2_vpcs
  source         = "./4-tier-vpc/"
  name           = each.key
  cidr           = each.value.cidr
  secondary_cidr = each.value.secondary_cidr
  region         = "us-west-2"
  common_tags    = local.common_tags
}

module "aws_use1_vpcs" {
  for_each = local.aws_use1_vpcs
  source   = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=997cba4053bd8b4a5d2aed528073b8f02c013e93"
  name     = each.key
  cidr     = each.value.cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = [cidrsubnet(each.value.cidr, 4, 3), cidrsubnet(each.value.cidr, 4, 4), cidrsubnet(each.value.cidr, 4, 5)]
  private_subnets = [cidrsubnet(each.value.cidr, 4, 0), cidrsubnet(each.value.cidr, 4, 1), cidrsubnet(each.value.cidr, 4, 2)]

  enable_ipv6        = true
  enable_nat_gateway = false
  single_nat_gateway = false

  tags = local.common_tags

  vpc_tags = merge(local.common_tags, {
    Name = each.key
  })

  providers = {
    aws = aws.use1
  }
}
