output "domain_name" {
  description = "The DNS name for the loadbalancer"
  value       = aws_lb.this.dns_name
}

output "lb_arn" {
  description = "The arn for the loadbalancer"
  value       = aws_lb.this.arn
}

output "https_listener_arn" {
  description = "The arn for the https listener"
  value       = element(concat(aws_lb_listener.https.*.arn, [""]), 0)
}

output "https_listener_rule_priorities" {
  description = "The priority of the https listener rules"
  value       = concat(aws_lb_listener_rule.https.*.priority, [""])
}

output "target_groups_arn" {
  description = "The arn for the target groups"
  value       = aws_lb_target_group.this.*.arn
  depends_on  = ["aws_lb_target_group_attachment.this"]
}

output "hosted_zone_id" {
  description = "The hosted zone id for the loadbalancer"
  value       = aws_lb.this.zone_id
}

output "security_group_name" {
  description = "The security group name for the loadbalancer"
  value       = aws_security_group.this.name
}

output "security_group_id" {
  description = "The security group id for the loadbalancer"
  value       = aws_security_group.this.id
}
