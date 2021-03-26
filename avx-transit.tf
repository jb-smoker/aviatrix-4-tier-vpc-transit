data "aws_subnet" "client_aza" {
  provider = aws.use1
  filter {
    name   = "tag:Name"
    values = ["east_client_1-public-us-east-1a"]
  }
}

data "aws_subnet" "client_azb" {
  provider = aws.use1
  filter {
    name   = "tag:Name"
    values = ["east_client_1-public-us-east-1b"]
  }
}

# Create an Aviatrix AWS Transit Network
resource "aviatrix_transit_gateway" "east_edge_avx_tgw" {
  cloud_type   = 1
  account_name = var.account_name
  gw_name      = "avx-transit-east-edge"
  vpc_id       = data.aws_vpc.edge.id
  vpc_reg      = local.aws_use1_vpcs.edge.region
  gw_size      = "t2.micro"
  subnet       = data.aws_subnet.edge.cidr_block
  ha_subnet    = data.aws_subnet.edge_azb.cidr_block
  ha_gw_size   = "t2.micro"
  tag_list = [
    "name:value",
    "name1:value1",
    "name2:value2",
  ]
  enable_active_mesh       = true
  enable_hybrid_connection = true
  connected_transit        = true
}

resource "aviatrix_spoke_gateway" "east_spoke" {
  cloud_type                        = 1
  account_name                      = var.account_name
  gw_name                           = "avx-spoke-east-client"
  vpc_id                            = module.aws_use1_vpcs["east_client_1"].vpc_id
  vpc_reg                           = local.aws_use1_vpcs.edge.region
  gw_size                           = "t2.micro"
  subnet                            = data.aws_subnet.client_aza.cidr_block
  ha_subnet                         = data.aws_subnet.client_azb.cidr_block
  ha_gw_size                        = "t2.micro"
  single_ip_snat                    = true #should be false after you figure out how to terraform snat
  enable_active_mesh                = true
  manage_transit_gateway_attachment = false
  tag_list = [
    "k1:v1",
    "k2:v2",
  ]
}

resource "aviatrix_spoke_transit_attachment" "east_attachment" {
  spoke_gw_name   = aviatrix_spoke_gateway.east_spoke.gw_name
  transit_gw_name = aviatrix_transit_gateway.east_edge_avx_tgw.gw_name
}

resource "aviatrix_spoke_gateway" "west_spoke" {
  cloud_type                        = 1
  account_name                      = var.account_name
  gw_name                           = "avx-spoke-west-compute"
  vpc_id                            = module.aws_usw2_vpcs["west_compute_1"].vpc_id
  vpc_reg                           = local.aws_usw2_vpcs.west_compute_1.region
  gw_size                           = "t2.micro"
  subnet                            = "10.3.5.0/26"
  ha_subnet                         = "10.3.5.64/26"
  ha_gw_size                        = "t2.micro"
  single_ip_snat                    = false
  enable_active_mesh                = true
  manage_transit_gateway_attachment = false
  tag_list = [
    "k1:v1",
    "k2:v2",
  ]
}

resource "aviatrix_gateway_snat" "west_spoke_snat" {
  gw_name   = aviatrix_spoke_gateway.west_spoke.gw_name
  snat_mode = "customized_snat"

  dynamic "snat_policy" {
    for_each = local.snat_policy

    content {
      src_cidr   = "100.64.0.0/16"
      dst_cidr   = snat_policy.value
      connection = aviatrix_transit_gateway.east_edge_avx_tgw.gw_name
      snat_ips   = aviatrix_spoke_gateway.west_spoke.private_ip
    }
  }

  snat_policy {
    src_cidr   = "100.64.0.0/16"
    dst_cidr   = "0.0.0.0/0"
    interface  = "eth0"
    connection = "None"
    snat_ips   = aviatrix_spoke_gateway.west_spoke.private_ip
  }
}

resource "aviatrix_spoke_transit_attachment" "west_attachment" {
  spoke_gw_name   = aviatrix_spoke_gateway.west_spoke.gw_name
  transit_gw_name = aviatrix_transit_gateway.east_edge_avx_tgw.gw_name
}
