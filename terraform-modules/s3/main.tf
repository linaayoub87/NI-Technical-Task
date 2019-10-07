/**
 * Module example:
 *
 *     module "foo" {
 *       source = "git@github.com:osn-cloud/terraform-modules.git//s3?ref=master"
 *       name   = "foo"
 *     }
 *
 *
 * Lifecycle rule can be configured as below:
 *
 *     module "foo" {
 *       source = "git@github.com:osn-cloud/terraform-modules.git//s3?ref=master"
 *       name   = "foo"
 *       lifecycle_rule = [{
 *         id = "default",
 *         enabled = true,
 *         abort_incomplete_multipart_upload_days = 7,
 *         transition = [{ days = 30, storage_class = "STANDARD_IA" }],
 *         transition = [{ days = 30, storage_class = "ONEZONE_IA" }],
 *         transition = [{ days = 90, storage_class = "GLACIER" }],
 *         expiration = [{ days = 365, expired_object_delete_marker = true }],
 *         noncurrent_version_expiration = [{ days = 60 }]
 *       }]
 *     }
 *
 * Read more about this in [terraform doc](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html) and [lifecycle examples](https://docs.aws.amazon.com/AmazonS3/latest/dev/lifecycle-configuration-examples.html).
 */

locals {
  encrypted_bucket = var.encrypted_bucket ? 1 : 0
  encrypted_bucket_config = {
    "0" = []
    "1" = [{
      rule = [{
        apply_server_side_encryption_by_default = [{
          kms_master_key_id = var.kms_arn
          sse_algorithm     = "aws:kms"
        }]
      }]
    }]
  }
}

resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = false
  acl           = "private"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  dynamic "server_side_encryption_configuration" {
    for_each = local.encrypted_bucket_config[local.encrypted_bucket]
    content {
      dynamic "rule" {
        for_each = lookup(server_side_encryption_configuration.value, "rule", [])
        content {
          dynamic "apply_server_side_encryption_by_default" {
            for_each = lookup(rule.value, "apply_server_side_encryption_by_default", [])
            content {
              kms_master_key_id  = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
              sse_algorithm  = lookup(apply_server_side_encryption_by_default.value, "sse_algorithm", null)
            }
          }
        }
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
    content {
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)

      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", [])
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.policy != "" ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.policy
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

