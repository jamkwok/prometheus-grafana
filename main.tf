
//Variables
variable "sshKey" {
  type = "string"
}
variable "environment" {
  type = "string"
}
variable "regionId" {
  type = "string"
}
variable "myIp" {
  type = "string"
}

//Mapping

provider "aws" {
  region = "${var.regionId}"
}

resource "aws_security_group" "allow_ssh_http_graphana" {
  name        = "allow_ssh_http_graphanas_${var.environment}"
  description = "Allow all inbound traffic for graphana"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIp}"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  //Required to allow outbound internet connection for user_data
  egress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh_http_${var.environment}"
  }
}

resource "aws_instance" "graphana" {
  depends_on = ["aws_security_group.allow_ssh_http_graphana"]
  ami           = "ami-e2021d81"
  availability_zone = "${var.regionId}a"
  key_name = "${var.sshKey}"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.allow_ssh_http_graphana.name}" ]
  user_data = "${file("userdata.sh")}"
  root_block_device {
    volume_size = 20
  }
  /*
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get upgrade",
      "echo $(date) > /tmp/flag"
    ]
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("/Users/jameskwok/.ssh/JamesKwok.pem")}"
    }
  }
  */
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${var.environment}-graphana"
  }
}
