# variables.tf
variable "tenant_id" {
  description = "Entra ID tenant ID"
  type        = string
}

variable "domain" {
  description = "Tenant domain, e.g. yourname2026.onmicrosoft.com"
  type        = string
}

variable "initial_password" {
  description = "Temporary password for users"
  type        = string
  sensitive   = true
}