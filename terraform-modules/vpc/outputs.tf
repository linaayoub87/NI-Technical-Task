# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.this.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.this.default_network_acl_id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private.*.cidr_block
}

output "db_subnets" {
  description = "List of IDs of db subnets"
  value       = aws_subnet.db_subnet.*.id
}

output "ad_subnets" {
  description = "List of IDs of ad subnets"
  value       = aws_subnet.ad_subnet.*.id
}

output "db_subnets_cidr_blocks" {
  description = "List of cidr_blocks of db subnets"
  value       = aws_subnet.db_subnet.*.cidr_block
}

output "ad_subnets_cidr_blocks" {
  description = "List of cidr_blocks of ad subnets"
  value       = aws_subnet.ad_subnet.*.cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public.*.cidr_block
}

# Route tables
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private.*.id
}

output "ad_route_table_ids" {
  description = "List of IDs of ad route tables"
  value       = aws_route_table.ad.*.id
}

output "db_route_table_ids" {
  description = "List of IDs of db route tables"
  value       = aws_route_table.db.*.id
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this.*.id
}

output "transit_gateway_attachment_ids" {
  description = "List of the Transit Gateway Attachment ID(s)"
  value       = concat(aws_ec2_transit_gateway_vpc_attachment.this.*.id, [])
}

# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = element(concat(aws_internet_gateway.this.*.id, [""]), 0)
}

# VPN Gateway
output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = element(concat(aws_vpn_gateway.this.*.id, [""]), 0)
}

