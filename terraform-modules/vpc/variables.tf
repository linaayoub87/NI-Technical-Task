variable "name" {
  description = "Name to be used on all the resources as identifier"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "db_subnets" {
  description = "A list of DB subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "ad_subnets" {
  description = "A list of DB subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow log"
  default     = false
}

variable "vpc_flow_log_retention" {
  description = "Number of days to retain the vpc flow logs"
  default     = "0"
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "customer_gateway_address" {
  description = "Specify the customer gateway address"
  default     = ""
}

variable "enable_vpn_connection" {
  description = "Should be true if you want to enable VPN connection between the vpn gateway and the customer gateway"
  default     = false
}

variable "vpn_connection_cidr_block" {
  description = "List of customer gateway CIDR addresses to add to the vpn connection route"
  type        = list(string)
  default     = []
}

variable "enable_vpn_propagation_private_route" {
  description = "Enable vpn propagation for private route table"
  default     = false
}

variable "enable_vpn_propagation_public_route" {
  description = "Enable vpn propagation for public route table"
  default     = false
}

variable "enable_vpn_propagation_ad_route" {
  description = "Enable vpn propagation for active-directory route table"
  default     = false
}

variable "enable_vpn_propagation_db_route" {
  description = "Enable vpn propagation for database route table"
  default     = false
}

variable "transit_gateway_default_route_table" {
  description = "Option to enable default route table association/propagation for transit gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_ids" {
  description = "List of transit gateway ids to create transit gateway vpc attachments"
  type        = list(string)
  default     = []
}

variable "transit_gateway_private_route" {
  description = "Map of routes to add to `private` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}`"
  type        = map(string)
  default     = {}
}

variable "transit_gateway_private_route_other" {
  description = "Map of additional routes to add to `private` route tables with additional transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}`"
  type        = map(string)
  default     = {}
}

variable "transit_gateway_ad_route" {
  description = "Map of routes to add to `active directory` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}`"
  type        = map(string)
  default     = {}
}

variable "transit_gateway_db_route" {
  description = "Map of routes to add to `database` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}`"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "ad_subnet_tags" {
  description = "Additional tags for the active directory subnets"
  type        = map(string)
  default     = {}
}

variable "db_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}

variable "ad_route_table_tags" {
  description = "Additional tags for the active-directory route table"
  type        = map(string)
  default     = {}
}

variable "db_route_table_tags" {
  description = "Additional tags for the db route table"
  type        = map(string)
  default     = {}
}

