resource "aws_key_pair" "pairkey" {
  key_name = "pairkey"
  public_key = "${file("${var.path_public_key}")}"
}

resource "aws_instance" "example" {
  ami = "ami-0015b9ef68c77328d"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.pairkey.key_name}"
tags  {

    Name = "Apache_server2"
}

   subnet_id = "${var.subnet}"
   associate_public_ip_address = "${var.public_ip}"
   vpc_security_group_ids = ["${var.security_group}"]

provisioner "file" {
    source = "scripts"
    destination = "/tmp/scripts"
  }
provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts",
      "sudo bash /tmp/scripts"
    ]
  }
  connection {
    user = "${var.instance_username}"
    private_key = "${file("${var.path_private_key}")}"
  }
}
