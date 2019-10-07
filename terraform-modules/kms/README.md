Module example:

    module "foo" {
      source = "git@github.com:osn-cloud/terraform-modules.git//kms?ref=master"
      name   = "foo"
    }



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| kms_deletion_window | Duration in days after which the KMS key is deleted from AWS after destruction | string | `7` | no |
| kms_enable_key_rotation | Option whether to enable key rotation | string | `true` | no |
| name | The alias for the kms encryption | string | - | yes |
| policy | Bucket policy | string | `` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN for the kms encryption |
| id | The globally unique identifier for the key |
| name | The name for the kms key alias |

