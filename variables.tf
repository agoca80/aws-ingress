variable "availability_zones" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "listeners" {
  type = map(any)
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "zone_name" {
  type = string
}
