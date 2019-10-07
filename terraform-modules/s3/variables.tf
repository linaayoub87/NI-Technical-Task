variable "name" {
  description = "Name of the s3 bucket"
}

variable "policy" {
  description = "Bucket policy"
  default     = ""
}

variable "lifecycle_rule" {
  description = "List of map of lifecycle_rules `{enabled=true,transition=[{days=15,storage_class='GLACIER'}]}`"
  type = list(object({
    enabled           = bool
    abort_incomplete_multipart_upload_days = number
    transition = list(object({
      days            = string
      storage_class   = string
    }))
    noncurrent_version_transition = list(object({
      days            = string
      storage_class   = string
    }))
    expiration = list(object({
      expired_object_delete_marker   = bool
    }))
    noncurrent_version_expiration = list(object({
      days   = string
    }))
  }))
  default     = []
}

variable "encrypted_bucket" {
  description = "Option whether to enable default server side bucket encryption"
  default     = false
}

variable "kms_arn" {
  description = "KMS arn to use as default bucket encryption"
  default     = "aws/s3"
}

variable "block_public_acls" {
  description = "Option whether S3 should block public ACLs for this bucket, PUT Bucket acl and PUT Object acl calls with public access will fail if enabled"
  default     = true
}

variable "block_public_policy" {
  description = "Option whether S3 should block public bucket policies, PUT Bucket policy with public access will fail if enabled"
  default     = true
}

variable "ignore_public_acls" {
  description = "Option whether should ignore public ACLs for this bucket, public ACLs on bucket is ignored if enabled"
  default     = true
}

variable "restrict_public_buckets" {
  description = "Option whether should restrict public bucket policies for this bucket, only the bucket owner and AWS Services can access this buckets if it has a public policy when enabled"
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

