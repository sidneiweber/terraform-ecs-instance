variable "environment" {
  description = "Environment"
  type        = string
}

variable "name" {
  description = "Stack name"
  type        = string
}

variable "cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "keypair" {
  description = "Key pair name"
  type        = string
}

variable "private_subnets" {
  description = "CIDR for Private Subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR for Private Subnets"
  type        = list(string)
}