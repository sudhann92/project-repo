provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_sceret_key}"
  region     = "${var.aws_region}"
}
