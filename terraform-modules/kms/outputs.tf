output "name" {
  description = "The name for the kms key alias"
  value       = "${aws_kms_alias.this.id}"
}

output "id" {
  description = "The globally unique identifier for the key"
  value       = "${aws_kms_key.this.key_id}"
}

output "arn" {
  description = "The ARN for the kms encryption"
  value       = "${aws_kms_key.this.arn}"
}

output "alias_arn" {
  description = "The ARN for the kms key alias"
  value       = "${aws_kms_alias.this.arn}"
}
