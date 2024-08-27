variable "environment" {
  type        = string
  description = "Name of the environment, quality, stage, nonprod, production"
}

variable "vpc_id" {
  type = string
}

variable "gateway_id" {
  type = string
}

variable "public_subnet_1" {
  type        = string
  description = "public-1a"
}

variable "public_subnet_2" {
  type        = string
  description = "public-1b"
}

variable "zone_subnet_1" {
  type        = string
  description = "zone subnet 1"
}

variable "zone_subnet_2" {
  type        = string
  description = "zone subnet 2"
}