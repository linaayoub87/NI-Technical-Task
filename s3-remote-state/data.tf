data "aws_caller_identity" "current" {}

variable "bucket_name" {
  default = "tech-task-terraform"
}
