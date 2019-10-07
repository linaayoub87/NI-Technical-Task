/**
 * Module example:
 *
 *     module "foo" {
 *       source = "git@github.com:osn-cloud/terraform-modules.git//kms?ref=master"
 *       name   = "foo"
 *     }
 *
 */


resource "aws_kms_key" "this" {
  description             = "${var.name} KMS key"
  deletion_window_in_days = "${var.kms_deletion_window}"
  enable_key_rotation     = "${var.kms_enable_key_rotation}"
  policy                  = "${var.policy}"
  tags                    = "${merge(var.tags, map("Name", "${var.name}"))}"
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = "${aws_kms_key.this.key_id}"
}
