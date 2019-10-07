
### Notes

Format of the target group is:

    [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }] [if instance id is used]
    [{ name="foo", target_id="10.0.1.1", host="foo.example.com", port="80" }] [if var.target_type = ip i.e IP address is used]
    [{ name="foo", host="foo.example.com", port="80" }] [if var.skip_target_group_attachment = true, useful for ecs service where 'target_id' is ignored]
    [{ name="foo", host="foo.example.com", port="80" }, { name="bar", host="bar.example.com", port="80", health_check_path="/_healthz" }] [if target group health check path is different from var.health_check_path]
    [{ name="foo", host="foo.example.com", port="80" }, { name="bar", host="bar.example.com", port="80", health_status_codes="200-499" }] [if target group health status codes are different from var.health_status_codes]

### Module examples

#### Basic Example:

    module "foo" {
      source                     = "github.com/osn-cloud/terraform-modules.git//loadbalancer?ref=master"
      name                       = "foo"
      enable_deletion_protection = false
      target_groups              = [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }]
      subnets                    = ["subnet-12345"]
      vpc_id                     = "vpc-12345"
      cidr                       = ["0.0.0.0/0"]
      tags = {
        "osn:application-name" = "foo"
        "osn:owner"            = "bar"
      }
    }

#### Logging to s3 bucket:

    module "foo" {
      source                     = "github.com/osn-cloud/terraform-modules.git//loadbalancer?ref=master"
      name                       = "foo"
      enable_deletion_protection = false
      target_groups              = [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }]
      subnets                    = ["subnet-12345"]
      vpc_id                     = "vpc-12345"
      cidr                       = ["0.0.0.0/0"]
      bucket_name                = "foo-s3-bucket"
      bucket_prefix              = "foo"
      tags = {
        "osn:application-name" = "foo"
        "osn:owner"            = "bar"
      }
    }

  Because of current limitation with terraform `if switching` in configuration, to enable access log on on already created loadbalancer, please do

    terraform state mv module.foo.aws_lb.this module.foo.aws_lb.log

  To disable access log on on already created loadbalancer, please do

    terraform state mv module.foo.aws_lb.log module.foo.aws_lb.this

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | The name of the application loadbalancer | string | n/a | yes |
| vpc\_id | VPC id to create the security group | string | n/a | yes |
| bucket\_name | The S3 bucket name to store the logs. Valid for application logs only | string | `""` | no |
| bucket\_prefix | The S3 bucket prefix (without trailing slash i.e `foo` or `foo/bar`). Valid for application logs only | string | `""` | no |
| certificate\_arn | Loadbalancer listener SSL ceritifcate ARN | string | `""` | no |
| cidr | List of CIDR to allow in the loadbalancer security group | list | `[]` | no |
| deregistration\_delay | The amount of time to drain connections before removing the backend | string | `"60"` | no |
| enable\_deletion\_protection | Option whether the application loadbalancer should be protected from being deleted through API | string | `"true"` | no |
| health\_check\_interval | The amount of time between health checks of an individual target | string | `"30"` | no |
| health\_check\_path | The destination for the health check request | string | `"/"` | no |
| health\_check\_timeout | The amount of time during which no response means a failed health check, must be less than `var.health_check_interval` | string | `"5"` | no |
| health\_status\_codes | HTTP codes to use when checking for a successful response from a target | string | `"200"` | no |
| healthy\_threshold | Number of consecutive health checks successes required before considering an unhealthy target healthy | string | `"3"` | no |
| http\_action\_type | Listener action type for HTTP request, either `forward` or `redirect` | string | `"forward"` | no |
| http\_port | Loadbalancer http listener port | string | `"80"` | no |
| https\_port | Loadbalancer https listener port | string | `"443"` | no |
| idle\_timeout | Idle timeout of the loadbalancer | string | `"60"` | no |
| internal | Option whether the application loadbalancer should be external or internal | string | `"false"` | no |
| ip\_address\_type | loadbalancer address type ipv4 or dualstack | string | `"ipv4"` | no |
| load\_balancer\_type | The type of load balancer to create. Possible values are `application` or `network` | string | `"application"` | no |
| protocol | Loadbalancer listener protocol | string | `"HTTP"` | no |
| security\_groups | List of Security Groups to allow in the loadbalancer security group | string | `""` | no |
| skip\_target\_group\_attachment | Skip target attachment if the attachment would be done in ECS, you can pass a random string as the target_id | string | `"false"` | no |
| ssl\_policy | Loadbalancer listener SSL policy | string | `"ELBSecurityPolicy-2016-08"` | no |
| subnets | Subnets to create the loadbalancer | list | `[]` | no |
| tags | A map of tags to add to all resources | map | `{}` | no |
| target\_groups | List of map of target groups in format `{name='foo',target_id='i-1234',host='foo.example.com',port='80'}` or  `{name='foo',target_id='i-1234',host='foo.example.com',port='80',health_check_path='/'}` (be careful about the order) | list | `[]` | no |
| target\_type | The type of target when registering targets with this target group, can be either instance or ip (for containers) | string | `"instance"` | no |
| unhealthy\_threshold | Number of consecutive health check failures required before considering the target unhealthy | string | `"3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain\_name | The DNS name for the loadbalancer |
| hosted\_zone\_id | The hosted zone id for the loadbalancer |
| https\_listener\_arn | The arn for the https listener |
| https\_listener\_rule\_priorities | The priority of the https listener rules |
| lb\_arn | The arn for the loadbalancer |
| security\_group\_id | The security group id for the loadbalancer |
| security\_group\_name | The security group name for the loadbalancer |
| target\_groups\_arn | The arn for the target groups |

