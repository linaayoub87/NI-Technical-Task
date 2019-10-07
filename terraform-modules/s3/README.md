Module example:

    module "foo" {
      source = "git@github.com:osn-cloud/terraform-modules.git//s3?ref=master"
      name   = "foo"
    }


Lifecycle rule can be configured as below:

    module "foo" {
      source = "git@github.com:osn-cloud/terraform-modules.git//s3?ref=master"
      name   = "foo"
      lifecycle_rule = [{
        id = "default",
        enabled = true,
        abort_incomplete_multipart_upload_days = 7,
        transition = [{ days = 30, storage_class = "STANDARD_IA" }],
        transition = [{ days = 30, storage_class = "ONEZONE_IA" }],
        transition = [{ days = 90, storage_class = "GLACIER" }],
        expiration = [{ days = 365, expired_object_delete_marker = true }],
        noncurrent_version_expiration = [{ days = 60 }]
      }]
    }

Read more about this in [terraform doc](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html) and [lifecycle examples](https://docs.aws.amazon.com/AmazonS3/latest/dev/lifecycle-configuration-examples.html).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Name of the s3 bucket | string | n/a | yes |
| block\_public\_acls | Option whether S3 should block public ACLs for this bucket, PUT Bucket acl and PUT Object acl calls with public access will fail if enabled | string | `"true"` | no |
| block\_public\_policy | Option whether S3 should block public bucket policies, PUT Bucket policy with public access will fail if enabled | string | `"true"` | no |
| encrypted\_bucket | Option whether to enable default server side bucket encryption | string | `"false"` | no |
| ignore\_public\_acls | Option whether should ignore public ACLs for this bucket, public ACLs on bucket is ignored if enabled | string | `"true"` | no |
| kms\_arn | KMS arn to use as default bucket encryption | string | `"aws/s3"` | no |
| lifecycle\_rule | List of map of lifecycle_rules `{enabled=true,transition=[{days=15,storage_class='GLACIER'}]}` | list | `[]` | no |
| policy | Bucket policy | string | `""` | no |
| restrict\_public\_buckets | Option whether should restrict public bucket policies for this bucket, only the bucket owner and AWS Services can access this buckets if it has a public policy when enabled | string | `"true"` | no |
| tags | A map of tags to add to all resources | map | `{}` | no |
| website | A list of map of website attributes, Ref: https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#website | list | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The s3 Bucket ARN |
| bucket\_arn | The s3 Bucket ARN |
| bucket\_domain\_name | The s3 Bucket domain name |
| domain\_name | The s3 Bucket domain name |
| hosted\_zone\_id | The route53 zone id for the s3 bucket |
| name | The s3 bucket name |
| website\_domain | The s3 Bucket website domain if configured as a website |
| website\_endpoint | The s3 Bucket website endpoint if bucket is configured as a website |

