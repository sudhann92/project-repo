resource "aws_instance" "example_instance" {
   ami = "ami-0b6158cfa2ae7b493"
   instance_type = "t2.micro"
tags {

    Name = "windows_server"
  }

  key_name = "${var.key_value}"
  subnet_id = "${var.subnet}"
  associate_public_ip_address = "${var.public_ip}"
  vpc_security_group_ids = ["${var.security_group}"]
   provisioner "local-exec" {
    command = "echo ${aws_instance.example_instance.private_ip} >> private.txt"
  }

  user_data = <<EOF
<powershell>
net user ${var.instance_username} ${var.instance_password} /add
net localgroup administrators ${var.instance_username} /add
set-executionpolicy -executionpolicy remotesigned
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
</powershell>
EOF
}

output "ip" {
  value = "${aws_instance.example_instance.public_ip}"
}

