variable "tag_class" {
  type    = string
  default = "dsba6190"
}

variable "tag_instructor" {
  type    = string
  default = "cford33"
}


variable "tag_semester" {
  type    = string
  default = "fall2024"
}

variable "location" {
  description = "Location of Resource Group"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus"], lower(var.location))
    error_message = "Unsupported Azure Region specified."
  }
}


// Azure-Specific App Variables

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "student_name" {
  description = "Application Name"
  type        = string
  default     = "ztperk"
}

variable "class_name" {
  description = "Application Name"
  type        = string
  default     = "dsba6190"
}

variable "sql_admin_login" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "SQL Server admin password (lab only, do not reuse in real life)"
  type        = string
  sensitive   = true
  default     = "P@ssword1234!"
}
