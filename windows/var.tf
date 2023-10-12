variable "AWS_ACCESS_KEY" {
  default = "give the acess key "
}
variable "AWS_SECRET_KEY" {
   default = "give the secret key"
}
variable "AWS_REGION" {
   default ="us-east-1"
}
variable "key_value" {
    default = "keypair"
}
variable "subnet" {
   default = "subnet-953f8dbb"
}
variable "public_ip" {
   default = "true"
}
variable "security_group" {
   default = "sg-0090b0517e36c0966"
}
variable "instance_username" {
    default = "admin"
}

variable "instance_password" {
    default = "Give complex password" #example:kRc7$-sjF87
}
