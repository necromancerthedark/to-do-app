variable "rules" {
  type = list(object({
    port       = number
    proto      = string
    cidr_block = list(string)
  }))

  default = [
    {
      port       = 80
      proto      = "tcp"
      cidr_block = ["27.0.168.33/32", "49.36.210.219/32", "171.76.153.147/32"]
    },
    {
      port       = 22
      proto      = "tcp"
      cidr_block = ["27.0.168.33/32", "49.36.210.219/32", "171.76.153.147/32"]
  }]
}



variable "subnet_id" {
  type    = string
  default = "subnet-039d7bd1c43f973cc"
}

variable "second_subnet_id" {
  type = string
  default = "subnet-0639992b937e38085"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0f82992e109fea8f9"
}