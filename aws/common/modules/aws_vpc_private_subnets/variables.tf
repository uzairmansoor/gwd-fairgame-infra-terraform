
variable "vpc_id" {
  type = string
}

variable "private_subnet_1" {
  type        = string
  description = "private-1"
}

variable "private_subnet_2" {
  type        = string
  description = "private-2"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "zone_subnet_1" {
  type        = string
  description = "zone subnet 1"
}

variable "zone_subnet_2" {
  type        = string
  description = "zone subnet 2"
}

variable "nat_gateway_id" {
  type = string
}