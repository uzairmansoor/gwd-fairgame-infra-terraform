##########################################
# AWS Provider
##########################################

variable "account_id" {
  type        = number
  description = "AWS Account ID"
  default     = 760669228469 #355986150263 #760669228469
}

variable "project" {
  type        = string
  description = "Project Name"
  default     = "gwd-fairgame"
}

variable "location" {
  type        = string
  description = "Amazon Region Name"
  default     = "eu-west-1"
}

##########################################
# VPC
##########################################

variable "cidr" {
  type        = map(string)
  description = "Classless Inter-Domain Routing, it is the mask of the VPC network"
  default = {
    dev    = "10.3.0.0/16"
    stage  = "10.4.0.0/16"
    prod   = "10.6.0.0/16"
  }
}

variable "public_subnet_1" {
  type        = map(string)
  description = "public-1a"
  default = {
    dev    = "10.3.0.0/20"
    stage  = "10.4.0.0/20"
    prod = "10.6.1.0/24"
  }
}

variable "zone_subnet_1" {
  type        = string
  description = "zone subnet 1"
  default     = "eu-west-1a"
}

variable "public_subnet_2" {
  type        = map(string)
  description = "public-1b"
  default = {
    dev    = "10.3.16.0/20"
    stage  = "10.4.16.0/20"
    prod = "10.6.2.0/24"
  }
}

variable "zone_subnet_2" {
  type        = string
  description = "zone subnet 2"
  default     = "eu-west-1b"
}

variable "private_subnet_1" {
  type        = map(string)
  description = "private-1"
  default = {
    dev    = "10.3.128.0/20"
    stage  = "10.4.128.0/20"
    prod = "10.6.3.0/24"
  }
}

variable "private_subnet_2" {
  type        = map(string)
  description = "private-2"
  default = {
    dev    = "10.3.144.0/20"
    stage  = "10.4.144.0/20"
    prod = "10.6.4.0/24"
  }
}

##########################################
# Application Load Balancer
##########################################

variable "lb_target_group_port" {
  type        = number
  description = "Port to access the backend"
  default     = 5200
}

variable "lb_listener_protocol" {
  type        = string
  description = "Protocol to access the backend"
  default     = "HTTP"
}