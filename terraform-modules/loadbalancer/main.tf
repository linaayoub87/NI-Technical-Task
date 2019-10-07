/**
 *
 * ### Notes
 *
 * Format of the target group is:
 * 
 *     [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }] [if instance id is used]
 *     [{ name="foo", target_id="10.0.1.1", host="foo.example.com", port="80" }] [if var.target_type = ip i.e IP address is used]
 *     [{ name="foo", host="foo.example.com", port="80" }] [if var.skip_target_group_attachment = true, useful for ecs service where 'target_id' is ignored]
 *     [{ name="foo", host="foo.example.com", port="80" }, { name="bar", host="bar.example.com", port="80", health_check_path="/_healthz" }] [if target group health check path is different from var.health_check_path]
 *     [{ name="foo", host="foo.example.com", port="80" }, { name="bar", host="bar.example.com", port="80", health_status_codes="200-499" }] [if target group health status codes are different from var.health_status_codes]
 *
 * ### Module examples
 *
 * #### Basic Example:
 *
 *     module "foo" {
 *       source                     = "github.com/osn-cloud/terraform-modules.git//loadbalancer?ref=master"
 *       name                       = "foo"
 *       enable_deletion_protection = false
 *       target_groups              = [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }]
 *       subnets                    = ["subnet-12345"]
 *       vpc_id                     = "vpc-12345"
 *       cidr                       = ["0.0.0.0/0"]
 *       tags = {
 *         "osn:application-name" = "foo"
 *         "osn:owner"            = "bar"
 *       }
 *     }
 *
 * #### Logging to s3 bucket:
 *
 *     module "foo" {
 *       source                     = "github.com/osn-cloud/terraform-modules.git//loadbalancer?ref=master"
 *       name                       = "foo"
 *       enable_deletion_protection = false
 *       target_groups              = [{ name="foo", target_id="i-123456", host="foo.example.com", port="80" }]
 *       subnets                    = ["subnet-12345"]
 *       vpc_id                     = "vpc-12345"
 *       cidr                       = ["0.0.0.0/0"]
 *       bucket_name                = "foo-s3-bucket"
 *       bucket_prefix              = "foo"
 *       tags = {
 *         "osn:application-name" = "foo"
 *         "osn:owner"            = "bar"
 *       }
 *     }
 *
 *
 */

# #
# Security Group
# #

locals {
  logging_enabled = var.bucket_name != "" ? 1 : 0
  logging_config = {
    "0" = []
    "1" = [{
      "bucket"  = var.bucket_name
      "prefix"  = var.bucket_prefix
    }]
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-lb"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags,{"Name" = var.name})
}

resource "aws_security_group_rule" "http_cidr" {
  count             = length(var.cidr) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  cidr_blocks       = var.cidr
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "http_sg" {
  count                    = length(var.security_groups)
  type                     = "ingress"
  from_port                = var.http_port
  to_port                  = var.http_port
  protocol                 = "tcp"
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "https_cidr" {
  count             = length(var.cidr) > 0 && var.certificate_arn != "" ? 1 : 0
  type              = "ingress"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = var.cidr
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "https_sg" {
  count                    = length(var.security_groups) > 0 && var.certificate_arn != "" ? length(var.security_groups) : 0
  type                     = "ingress"
  from_port                = var.https_port
  to_port                  = var.https_port
  protocol                 = "tcp"
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = [aws_security_group.this.id]
  subnets                    = var.subnets
  idle_timeout               = var.idle_timeout
  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  dynamic "access_logs" {
    for_each = local.logging_config[local.logging_enabled]
    content {
      enabled = true
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
    }
  }
  tags                       = merge(var.tags,{"Name" = var.name})
}

resource "aws_lb_target_group" "this" {
  count                = length(var.target_groups)
  name                 = var.target_groups[count.index]["name"]
  port                 = var.target_groups[count.index]["port"]
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay
  health_check {
    interval            = var.health_check_interval
    path                = lookup(var.target_groups[count.index], "health_check_path", var.health_check_path)
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = lookup(var.target_groups[count.index], "health_status_codes", var.health_status_codes)
  }

  tags       = merge(var.tags,{"Name" = var.target_groups[count.index]["name"]})
}

resource "aws_lb_target_group_attachment" "this" {
  count            = var.skip_target_group_attachment ? 0 : length(var.target_groups)
  target_group_arn = element(aws_lb_target_group.this.*.arn, count.index)
  target_id        = var.target_groups[count.index]["target_id"]
  port             = var.target_groups[count.index]["port"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "http" {
  count        = var.http_action_type == "forward" ? length(var.target_groups) : 0
  listener_arn = aws_lb_listener.http.arn
  priority     = count.index * 10 + 1
  action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.this.*.arn, count.index)
  }
  condition {
    field = "path-pattern"
    values = [lookup(var.target_groups[count.index], "path_pattern", "/*")]
  }
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count        = var.http_action_type == "redirect" ? 1 : 0
  listener_arn = aws_lb_listener.http.arn
  priority     = count.index * 10 + 1
  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_lb_listener_rule" "https" {
  count        = var.certificate_arn == "" ? 0 : length(var.target_groups)
  listener_arn = aws_lb_listener.https[0].arn
  priority     = count.index * 10 + 1
  action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.this.*.arn, count.index)
  }
  condition {
    field = "path-pattern"
    values = [lookup(var.target_groups[count.index], "path_pattern", "/*")]
  }
}
