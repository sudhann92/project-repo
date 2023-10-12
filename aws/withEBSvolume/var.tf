variable "aws_access_key" {}
variable "aws_sceret_key" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "subnet" {
  default = "subnet-953f8dbb"
}

variable "public_ip" {
  default = "true"
}

variable "security_group" {
  default = "sg-08222a038c4ccc92a"
}

variable "path_private_key" {
  default = "mykey"
}

variable "path_public_key" {
  default = "mykey.pub"
}

variable "instance_username" {
  default = "centos"
}
