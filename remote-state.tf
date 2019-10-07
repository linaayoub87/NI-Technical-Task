terraform {
  backend "s3" {
    bucket     = "tech-task-terraform"
    kms_key_id = " arn:aws:kms:eu-west-1:204995418749:key/c7643a26-067b-438d-9380-2914c1f6326a"
    key        = "tfstate"
    encrypt    = true
    region     = "eu-west-1"
  }
}
