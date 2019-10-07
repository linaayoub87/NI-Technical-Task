variable "name" {
  description = "The alias for the kms encryption"
}

variable "policy" {
  description = "Bucket policy"
  default     = ""
}

variable "kms_deletion_window" {
  description = "Duration in days after which the KMS key is deleted from AWS after destruction"
  default     = "7"
}

variable "kms_enable_key_rotation" {
  description = "Option whether to enable key rotation"
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default     = {}
}
