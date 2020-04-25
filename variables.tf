variable "region" {
  default = "us-east-1"
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  default = "10.0.0.0/24"
}


# variable "vpc_name" {
#   default = ""
# }

variable "amis" {
    type = map
    default = {
        "ubt-1604" = "ami-2757f631"
        "ubt-1610" = "ami-b374d5a5"
    }
}

# variable "env" {

# }