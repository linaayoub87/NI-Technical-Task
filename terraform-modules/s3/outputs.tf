output "name" {
  description = "The s3 bucket name"
  value       = aws_s3_bucket.this.id
}

output "domain_name" {
  description = "The s3 Bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "arn" {
  description = "The s3 Bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_arn" {
  description = "The s3 Bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "hosted_zone_id" {
  description = "The route53 zone id for the s3 bucket"
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "website_domain" {
  description = "The s3 Bucket website domain if configured as a website"
  value = "s3-website-${aws_s3_bucket.this.region}.amazonaws.com"
}

output "website_endpoint" {
  description = "The s3 Bucket website endpoint if bucket is configured as a website"
  value = "${aws_s3_bucket.this.id}.s3-website-${aws_s3_bucket.this.region}.amazonaws.com"
}

