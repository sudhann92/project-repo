resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "${file("${var.path_public_key}")}"
}

resource "aws_instance" "example" {
  ami           = "ami-0015b9ef68c77328d"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.mykey.key_name}"

  tags {
    Name = "Apache_server"
  }

  subnet_id                   = "${var.subnet}"
  associate_public_ip_address = "${var.public_ip}"
  vpc_security_group_ids      = ["${var.security_group}"]

  user_data = <<EOF
#!/bin/bash
sleep 15
mkfs.ext4 /dev/xvdh
mkdir -p /data
echo "/dev/xvdh  /data  ext4 defaults  0  0 "  >> /etc/fstab
mount -a
EOF
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "us-east-1b"
  size              = 10
  type              = "gp2"

  tags {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attach" {
  device_name = "/dev/xvdh"
  volume_id   = "${aws_ebs_volume.ebs-volume-1.id}"
  instance_id = "${aws_instance.example.id}"
}
