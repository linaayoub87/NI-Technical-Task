variable "name" {
  description = "The name of the application loadbalancer"
}

variable "internal" {
  description = "Option whether the application loadbalancer should be external or internal"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are `application` or `network`"
  default     = "application"
}

variable "bucket_name" {
  description = "The S3 bucket name to store the logs. Valid for application logs only"
  default     = ""
}

variable "bucket_prefix" {
  description = "The S3 bucket prefix (without trailing slash i.e `foo` or `foo/bar`)"
  default     = ""
}

variable "ip_address_type" {
  description = "loadbalancer address type ipv4 or dualstack"
  default     = "ipv4"
}

variable "idle_timeout" {
  description = "Idle timeout of the loadbalancer"
  default     = "60"
}

variable "http_port" {
  description = "Loadbalancer http listener port"
  default     = "80"
}

variable "https_port" {
  description = "Loadbalancer https listener port"
  default     = "443"
}

variable "protocol" {
  description = "Loadbalancer listener protocol"
  default     = "HTTP"
}

variable "ssl_policy" {
  description = "Loadbalancer listener SSL policy"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "certificate_arn" {
  description = "Loadbalancer listener SSL ceritifcate ARN"
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Option whether the application loadbalancer should be protected from being deleted through API"
  default     = true
}

variable "target_groups" {
  description = "List of map of target groups in format `{name='foo',target_id='i-1234',host='foo.example.com',port='80'}` or  `{name='foo',target_id='i-1234',host='foo.example.com',port='80',health_check_path='/'}` (be careful about the order)"
  type        = list(map(any))
  default     = []
}

variable "target_type" {
  description = "The type of target when registering targets with this target group, can be either instance or ip (for containers)"
  default     = "instance"
}

variable "http_action_type" {
  description = "Listener action type for HTTP request, either `forward` or `redirect`"
  default     = "forward"
}

variable "skip_target_group_attachment" {
  description = "Skip target attachment if the attachment would be done in ECS, you can pass a random string as the target_id"
  default     = false
}

variable "health_check_interval" {
  description = "The amount of time between health checks of an individual target"
  default     = "30"
}

variable "health_check_path" {
  description = "The destination for the health check request"
  default     = "/"
}

variable "health_check_timeout" {
  description = "The amount of time during which no response means a failed health check, must be less than `var.health_check_interval`"
  default     = "5"
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy"
  default     = "3"
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering the target unhealthy"
  default     = "3"
}

variable "health_status_codes" {
  description = "HTTP codes to use when checking for a successful response from a target"
  default     = "200"
}

variable "deregistration_delay" {
  description = "The amount of time to drain connections before removing the backend"
  default     = "60"
}

variable "subnets" {
  description = "Subnets to create the loadbalancer"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC id to create the security group"
}

variable "cidr" {
  description = "List of CIDR to allow in the loadbalancer security group"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "List of security groups to allow"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
