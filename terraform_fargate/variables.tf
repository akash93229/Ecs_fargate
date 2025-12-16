variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}


variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "strapidb"
}

variable "db_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "strapiuser"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
  default     = "password"
}

variable "docker_image" {
  description = "Docker image for Strapi (ECR)"
  type        = string
  default     = "strapiakash"

}

variable "app_keys" {
  description = "Strapi APP_KEYS (comma-separated)"
  type        = string
  sensitive   = true
  default     = "qEgeCP+GlhE7maTjwudsLg==,ZeYDnL8QLf+PlhjShBhk5A==,nf/Zubk+slEfAXoW2yeIuw==,KL7uv8a2Xs89co9sHWqJYQ=="
}

variable "api_token_salt" {
  description = "Strapi API_TOKEN_SALT"
  type        = string
  sensitive   = true
  default     = "z9FjrDIt2gHqWFO1GKercg=="
}

variable "admin_jwt_secret" {
  description = "Strapi ADMIN_JWT_SECRET"
  type        = string
  sensitive   = true
  default     = "Lp7UJasFt1qAkWF06Tnl4g=="
}

variable "jwt_secret" {
  description = "Strapi JWT_SECRET"
  type        = string
  sensitive   = true
  default     = "2WRUGinYzPj+3gAg/eGcZg=="
}