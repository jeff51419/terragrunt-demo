variable "region" {
  type        = string
  description = "region"
}

variable "role_numbers" {
  type        = string
  description = "role_numbers"
}

variable "alias" {
  type        = string
  description = "name"
  default     = ""
}

variable "description" {
  type        = string
  description = "description"
  default     = ""
}

variable "customer_master_key_spec" {
  type        = string
  description = " Specifies whether the key contains a symmetric key or an asymmetric key pair "
  default     = "SYMMETRIC_DEFAULT"
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "multi_region" {
  type    = bool
  default = true
}

variable "bypass_policy_lockout_safety_check" {
  type    = bool
  default = false
}