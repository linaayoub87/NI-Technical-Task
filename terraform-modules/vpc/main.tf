/**
 * Module example:
 *
 *     module "foo" {
 *       source          = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
 *       name            = "${var.owner}"
 *       cidr            = "10.10.10.0/16"
 *       azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
 *       private_subnets = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
 *       public_subnets  = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
 *     }
 *
 * Module example with transit gateway:
 *
 *     module "foo" {
 *       source              = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
 *       name                = "${var.owner}"
 *       cidr                = "10.10.10.0/16"
 *       azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
 *       private_subnets     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
 *       public_subnets      = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
 *       transit_gateway_ids = ["tgw-1234"]
 *       transit_gateway_private_route = {
 *         gateway_id = "tgw-1234",
 *         cidr_block = "10.1.0.0/16,10.2.0.0/16"
 *       }
 *     }
 *
 * Module example with transit gateway:
 *
 *     module "foo" {
 *       source              = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
 *       name                = "${var.owner}"
 *       cidr                = "10.10.10.0/16"
 *       azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
 *       private_subnets     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
 *       public_subnets      = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
 *       transit_gateway_ids = ["tgw-1234"]
 *       transit_gateway_private_route = {
 *         gateway_id = "tgw-1234",
 *         cidr_block = "10.1.0.0/16,10.2.0.0/16"
 *       }
 *       transit_gateway_private_route_other = {
 *         gateway_id = "tgw-56789",
 *         cidr_block = "10.10.0.0/16,10.11.0.0/16"
 *       }
 *     }
 *
 */

# This avoids multiple route tables when we have single NAT gateway
# Value will be 1 if single_nat_gaetway is enabled else, count of the private subnets
locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.ad_subnets),
    length(var.db_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : local.max_subnet_length
}

data "aws_region" "current" {
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "${data.aws_region.current.name}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      "Name" = format("%s-public", var.name)
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = var.single_nat_gateway ? "${var.name}-private" : format("%s-private-%s", var.name, element(var.azs, count.index))
    },
  )
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      "Name" = format("%s-public-%s", var.name, element(var.azs, count.index))
    },
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      "Name" = format("%s-private-%s", var.name, element(var.azs, count.index))
    },
  )
}

#################
# Database Private subnet
#################
resource "aws_subnet" "db_subnet" {
  count = length(var.db_subnets) > 0 ? length(var.db_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    var.db_subnet_tags,
    {
      "Name" = format("%s-db-%s", var.name, element(var.azs, count.index))
    },
  )
}

resource "aws_route_table" "db" {
  count = length(var.db_subnets) > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.db_route_table_tags,
    {
      "Name" = var.single_nat_gateway ? "${var.name}-db" : format("%s-db-%s", var.name, element(var.azs, count.index))
    },
  )
}

################################
# ActiveDirectory Private Subnet
################################

resource "aws_subnet" "ad_subnet" {
  count = length(var.ad_subnets) > 0 ? length(var.ad_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.ad_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    var.tags,
    var.ad_subnet_tags,
    {
      "Name" = format("%s-ad-%s", var.name, element(var.azs, count.index))
    },
  )
}

resource "aws_route_table" "ad" {
  count = length(var.ad_subnets) > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.ad_route_table_tags,
    {
      "Name" = var.single_nat_gateway ? "${var.name}-ad" : format("%s-ad-%s", var.name, element(var.azs, count.index))
    },
  )
}

##############
# NAT Gateway
##############
resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? local.nat_gateway_count : local.max_subnet_length

  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
  )
}

resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? local.nat_gateway_count : local.max_subnet_length

  allocation_id = element(aws_eip.nat.*.id, var.single_nat_gateway ? 0 : count.index)
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    var.tags,
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = var.single_nat_gateway ? local.nat_gateway_count : local.max_subnet_length

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

resource "aws_route" "ad_nat_gateway" {
  count = length(var.ad_subnets) > 0 ? var.single_nat_gateway ? local.nat_gateway_count : local.max_subnet_length : 0

  route_table_id         = element(aws_route_table.ad.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

resource "aws_route" "db_nat_gateway" {
  count = length(var.db_subnets) > 0 ? var.single_nat_gateway ? local.nat_gateway_count : local.max_subnet_length : 0

  route_table_id         = element(aws_route_table.db.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.enable_s3_endpoint ? 1 : null

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : null

  vpc_id       = aws_vpc.this.id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "db_s3" {
  count = var.enable_s3_endpoint ? length(var.db_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.db.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "ad_s3" {
  count = var.enable_s3_endpoint ? length(var.ad_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.ad.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.enable_s3_endpoint ? length(var.public_subnets) : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public.id
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "db_private" {
  count = length(var.db_subnets) > 0 ? length(var.db_subnets) : 0

  subnet_id = element(aws_subnet.db_subnet.*.id, count.index)
  route_table_id = element(
    aws_route_table.db.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "ad_private" {
  count = length(var.ad_subnets) > 0 ? length(var.ad_subnets) : 0

  subnet_id = element(aws_subnet.ad_subnet.*.id, count.index)
  route_table_id = element(
    aws_route_table.ad.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

#################################
# Transit Gateway VPC Attachments
#################################
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count                                           = length(var.transit_gateway_ids)
  subnet_ids                                      = aws_subnet.private.*.id
  transit_gateway_id                              = var.transit_gateway_ids[count.index]
  vpc_id                                          = aws_vpc.this.id
  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_route" "private_transit_route" {
  count = length(var.private_subnets) > 0 && length(var.transit_gateway_ids) > 0 && length(var.transit_gateway_private_route) > 0 ? length(
    split(
      ",",
      lookup(var.transit_gateway_private_route, "cidr_block", ""),
    ),
  ) * local.nat_gateway_count : 0

  route_table_id = element(aws_route_table.private.*.id, ceil(count.index/length(split(",", var.transit_gateway_private_route["cidr_block"]))))
  destination_cidr_block = element(
    split(",", var.transit_gateway_private_route["cidr_block"]),
    count.index % length(split(",", var.transit_gateway_private_route["cidr_block"])),
  )
  transit_gateway_id = var.transit_gateway_private_route["gateway_id"]
}

resource "aws_route" "private_transit_route_other" {
  count = length(var.private_subnets) > 0 && length(var.transit_gateway_ids) > 0 && length(var.transit_gateway_private_route_other) > 0 ? length(
    split(
      ",",
      lookup(var.transit_gateway_private_route_other, "cidr_block", ""),
    ),
  ) * local.nat_gateway_count : 0

  route_table_id = element(aws_route_table.private.*.id, ceil(count.index/length(split(",", var.transit_gateway_private_route_other["cidr_block"]))))
  destination_cidr_block = element(
    split(",", var.transit_gateway_private_route_other["cidr_block"]),
    count.index % length(split(",", var.transit_gateway_private_route_other["cidr_block"])),
  )
  transit_gateway_id = var.transit_gateway_private_route_other["gateway_id"]
}


resource "aws_route" "ad_transit_route" {
  count = length(var.ad_subnets) > 0 && length(var.transit_gateway_ids) > 0 && length(var.transit_gateway_ad_route) > 0 ? length(
    split(",", lookup(var.transit_gateway_ad_route, "cidr_block", "")),
  ) * local.nat_gateway_count : 0

  route_table_id = element(aws_route_table.ad.*.id, ceil(count.index/length(split(",", var.transit_gateway_ad_route["cidr_block"]))))
  destination_cidr_block = element(
    split(",", var.transit_gateway_ad_route["cidr_block"]),
    count.index % length(split(",", var.transit_gateway_ad_route["cidr_block"])),
  )
  transit_gateway_id = var.transit_gateway_ad_route["gateway_id"]
}

resource "aws_route" "db_transit_route" {
  count = length(var.db_subnets) > 0 && length(var.transit_gateway_ids) > 0 && length(var.transit_gateway_db_route) > 0 ? length(
    split(",", lookup(var.transit_gateway_db_route, "cidr_block", "")),
  ) * local.nat_gateway_count : 0

  route_table_id = element(aws_route_table.db.*.id, ceil(count.index/length(split(",", var.transit_gateway_db_route["cidr_block"]))))
  destination_cidr_block = element(
    split(",", var.transit_gateway_db_route["cidr_block"]),
    count.index % length(split(",", var.transit_gateway_db_route["cidr_block"])),
  )
  transit_gateway_id = var.transit_gateway_db_route["gateway_id"]
}

##############
# VPC Flow Log
##############
resource "aws_iam_role" "this" {
  count              = var.enable_vpc_flow_logs ? 1 : 0
  name               = "${var.name}-vpc-flow-logs-svc"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "this" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  name   = element(aws_iam_role.this.*.id, count.index)
  role   = element(aws_iam_role.this.*.id, count.index)
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc/flow-logs/${var.name}"
  retention_in_days = var.vpc_flow_log_retention
  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}

resource "aws_flow_log" "this" {
  count           = var.enable_vpc_flow_logs ? 1 : 0
  log_destination = element(aws_cloudwatch_log_group.this.*.arn, count.index)
  iam_role_arn    = element(aws_iam_role.this.*.arn, count.index)
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
}

##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_customer_gateway" "this" {
  count = var.customer_gateway_address != "" ? 1 : 0

  bgp_asn    = 65000
  ip_address = var.customer_gateway_address
  type       = "ipsec.1"

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_vpn_connection" "this" {
  count = var.enable_vpn_connection ? 1 : 0

  vpn_gateway_id      = element(aws_vpn_gateway.this.*.id, count.index)
  customer_gateway_id = element(aws_customer_gateway.this.*.id, count.index)
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_vpn_connection_route" "this" {
  count                  = var.enable_vpn_connection ? length(var.vpn_connection_cidr_block) : 0
  destination_cidr_block = element(var.vpn_connection_cidr_block, count.index)
  vpn_connection_id      = element(aws_vpn_connection.this.*.id, count.index)
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.enable_vpn_gateway && var.enable_vpn_propagation_public_route ? local.nat_gateway_count : 0

  vpn_gateway_id = element(aws_vpn_gateway.this.*.id, 0)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.enable_vpn_gateway && var.enable_vpn_propagation_private_route ? local.nat_gateway_count : 0

  vpn_gateway_id = element(aws_vpn_gateway.this.*.id, 0)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpn_gateway_route_propagation" "ad" {
  count = var.enable_vpn_gateway && var.enable_vpn_propagation_ad_route ? local.nat_gateway_count : 0

  vpn_gateway_id = element(aws_vpn_gateway.this.*.id, 0)
  route_table_id = element(aws_route_table.ad.*.id, count.index)
}

resource "aws_vpn_gateway_route_propagation" "db" {
  count = var.enable_vpn_gateway && var.enable_vpn_propagation_db_route ? local.nat_gateway_count : 0

  vpn_gateway_id = element(aws_vpn_gateway.this.*.id, 0)
  route_table_id = element(aws_route_table.db.*.id, count.index)
}

