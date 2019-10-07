## Remote State
##
locals {
  bucket_name = "tech-task-terraform"
  tags        = {
    "owner"            = "${var.owner}"
  }
}

module "s3_remote_state" {
  source           = "../terraform-modules/s3"
  name             = "${local.bucket_name}"
  encrypted_bucket = true
  kms_arn          = "${module.kms_remote_state.arn}"
  tags             = "${local.tags}"
}

module "kms_remote_state" {
  source = "../terraform-modules/kms"
  name   = "terraform"
  tags   = "${local.tags}"
}

output "remote_state_kms_arn" {
  value = "${module.kms_remote_state.arn}"
}
