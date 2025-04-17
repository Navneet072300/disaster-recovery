# Variables
variable "primary_region" {
  description = "Primary AWS region for deployment"
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for failover"
  default     = "us-west-2"
}

variable "domain_name" {
  description = "Domain name for Route 53"
  default     = "myproject.com"
}

variable "db_password" {
  description = "Password for RDS database"
  default     = "securepassword123"
  sensitive   = true
}