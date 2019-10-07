Module example:

    module "foo" {
      source          = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
      name            = "${var.owner}"
      cidr            = "10.10.10.0/16"
      azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      private_subnets = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
      public_subnets  = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
    }

Module example with transit gateway:

    module "foo" {
      source              = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
      name                = "${var.owner}"
      cidr                = "10.10.10.0/16"
      azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      private_subnets     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
      public_subnets      = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
      transit_gateway_ids = ["tgw-1234"]
      transit_gateway_private_route = {
        gateway_id = "tgw-1234",
        cidr_block = "10.1.0.0/16,10.2.0.0/16"
      }
    }

Module example with multiple transit gateways:

    module "foo" {
      source              = "github.com/osn-cloud/terraform-modules.git//vpc?ref=master"
      name                = "${var.owner}"
      cidr                = "10.10.10.0/16"
      azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      private_subnets     = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
      public_subnets      = ["10.10.13.0/24", "10.10.14.0/24", "10.10.15.0/24"]
      transit_gateway_ids = ["tgw-1234"]
      transit_gateway_private_route = {
        gateway_id = "tgw-1234",
        cidr_block = "10.1.0.0/16,10.2.0.0/16"
      }
      transit_gateway_private_route_other = {
        gateway_id = "tgw-56789",
        cidr_block = "10.10.0.0/16,10.11.0.0/16"
      }
    }


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr | The CIDR block for the VPC | string | n/a | yes |
| name | Name to be used on all the resources as identifier | string | n/a | yes |
| ad\_route\_table\_tags | Additional tags for the active-directory route table | map | `{}` | no |
| ad\_subnet\_tags | Additional tags for the active directory subnets | map | `{}` | no |
| ad\_subnets | A list of DB subnets inside the VPC | list | `[]` | no |
| azs | A list of availability zones in the region | list | `[]` | no |
| customer\_gateway\_address | Specify the customer gateway address | string | `""` | no |
| db\_route\_table\_tags | Additional tags for the db route table | map | `{}` | no |
| db\_subnet\_tags | Additional tags for the database subnets | map | `{}` | no |
| db\_subnets | A list of DB subnets inside the VPC | list | `[]` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | string | `"false"` | no |
| enable\_vpc\_flow\_logs | Enable VPC flow log | string | `"false"` | no |
| enable\_vpn\_connection | Should be true if you want to enable VPN connection between the vpn gateway and the customer gateway | string | `"false"` | no |
| enable\_vpn\_gateway | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | string | `"false"` | no |
| enable\_vpn\_propagation\_ad\_route | Enable vpn propagation for active-directory route table | string | `"false"` | no |
| enable\_vpn\_propagation\_db\_route | Enable vpn propagation for database route table | string | `"false"` | no |
| enable\_vpn\_propagation\_private\_route | Enable vpn propagation for private route table | string | `"false"` | no |
| enable\_vpn\_propagation\_public\_route | Enable vpn propagation for public route table | string | `"false"` | no |
| map\_public\_ip\_on\_launch | Should be false if you do not want to auto-assign public IP on launch | string | `"true"` | no |
| private\_route\_table\_tags | Additional tags for the private route tables | map | `{}` | no |
| private\_subnet\_tags | Additional tags for the private subnets | map | `{}` | no |
| private\_subnets | A list of private subnets inside the VPC | list | `[]` | no |
| public\_route\_table\_tags | Additional tags for the public route tables | map | `{}` | no |
| public\_subnet\_tags | Additional tags for the public subnets | map | `{}` | no |
| public\_subnets | A list of public subnets inside the VPC | list | `[]` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | string | `"false"` | no |
| tags | A map of tags to add to all resources | map | `{}` | no |
| transit\_gateway\_ad\_route | Map of routes to add to `active directory` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}` | map | `{}` | no |
| transit\_gateway\_db\_route | Map of routes to add to `database` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}` | map | `{}` | no |
| transit\_gateway\_ids | List of transit gateway ids to create transit gateway vpc attachments | list | `[]` | no |
| transit\_gateway\_private\_route | Map of routes to add to `private` route tables with transit gateway as destination in format `{gateway_id='tgw-1234',cidr_block='10.1.0.0/16,10.2.0.0/16'}` | map | `{}` | no |
| vpc\_flow\_log\_retention | Number of days to retain the vpc flow logs | string | `"0"` | no |
| vpn\_connection\_cidr\_block | List of customer gateway CIDR addresses to add to the vpn connection route | list | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ad\_route\_table\_ids | List of IDs of ad route tables |
| ad\_subnets | List of IDs of ad subnets |
| ad\_subnets\_cidr\_blocks | List of cidr_blocks of ad subnets |
| db\_route\_table\_ids | List of IDs of db route tables |
| db\_subnets | List of IDs of db subnets |
| db\_subnets\_cidr\_blocks | List of cidr_blocks of db subnets |
| default\_network\_acl\_id | The ID of the default network ACL |
| default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| igw\_id | The ID of the Internet Gateway |
| nat\_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat\_public\_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw\_ids | List of NAT Gateway IDs |
| private\_route\_table\_ids | List of IDs of private route tables |
| private\_subnets | List of IDs of private subnets |
| private\_subnets\_cidr\_blocks | List of cidr_blocks of private subnets |
| public\_route\_table\_ids | List of IDs of public route tables |
| public\_subnets | List of IDs of public subnets |
| public\_subnets\_cidr\_blocks | List of cidr_blocks of public subnets |
| transit\_gateway\_attachment\_ids | List of the Transit Gateway Attachment ID(s) |
| vgw\_id | The ID of the VPN Gateway |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |

