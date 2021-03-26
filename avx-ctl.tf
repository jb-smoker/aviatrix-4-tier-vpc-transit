data "aws_caller_identity" "current" {
}

data "aws_vpc" "edge" {
  provider = aws.use1
  filter {
    name   = "tag:Name"
    values = ["edge"]
  }
}

data "aws_subnet" "edge" {
  provider = aws.use1
  filter {
    name   = "tag:Name"
    values = ["edge-public-us-east-1a"]
  }
}

data "aws_subnet" "edge_azb" {
  provider = aws.use1
  filter {
    name   = "tag:Name"
    values = ["edge-public-us-east-1b"]
  }
}

module "aviatrix-iam-roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git?ref=c92e3250e00c8028b99e3e5f6058f33a40d816cc/aviatrix-controller-iam-roles"
}

module "avx_ctl_build" {
  source        = "github.com/AviatrixSystems/terraform-modules.git?ref=c92e3250e00c8028b99e3e5f6058f33a40d816cc/aviatrix-controller-build"
  vpc           = data.aws_vpc.edge.id
  subnet        = data.aws_subnet.edge.id
  keypair       = "smoker"
  instance_type = "t3.large"
  ec2role       = module.aviatrix-iam-roles.aviatrix-role-ec2-name
  providers = {
    aws = aws.use1
  }
}

module "avx_ctl_initialize" {
  source              = "github.com/AviatrixSystems/terraform-modules.git?ref=c92e3250e00c8028b99e3e5f6058f33a40d816cc/aviatrix-controller-initialize"
  admin_password      = var.ctl_password
  admin_email         = "jsmoker@aviatrix.com"
  private_ip          = module.avx_ctl_build.private_ip
  public_ip           = module.avx_ctl_build.public_ip
  vpc_id              = data.aws_vpc.edge.id
  subnet_id           = data.aws_subnet.edge.id
  access_account_name = var.account_name
  aws_account_id      = data.aws_caller_identity.current.account_id
  customer_license_id = var.customer_license_id
  providers = {
    aws = aws.use1
  }
}

resource "aviatrix_gateway" "avx_vpn_gw_1" {
  cloud_type       = 1
  account_name     = var.account_name
  gw_name          = "avx-vpn-gw-1"
  vpc_id           = data.aws_vpc.edge.id
  vpc_reg          = "us-east-1"
  gw_size          = "t3.micro"
  enable_elb       = false
  enable_ldap      = false
  single_ip_snat   = false
  split_tunnel     = true
  additional_cidrs = "10.0.0.0/8"
  name_servers     = "8.8.8.8"
  saml_enabled     = false
  vpn_access       = true
  vpn_protocol     = "UDP"
  single_az_ha     = false
  subnet           = cidrsubnet(local.aws_use1_vpcs.avx_transit.cidr, 4, 5)
  max_vpn_conn     = "150"
  vpn_cidr         = "10.58.120.0/22"
  tag_list         = ["Terraform:1"]
  depends_on       = [module.avx_ctl_initialize]
}

output "avx_result" {
  value = module.avx_ctl_initialize.result
}

output "avx_ctl_private_ip" {
  value = module.avx_ctl_build.private_ip
}

output "avx_ctl_public_ip" {
  value = module.avx_ctl_build.public_ip
}
