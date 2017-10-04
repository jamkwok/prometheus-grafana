
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
variable "dnsApex" {
  type = "string"
}

//Mapping

provider "aws" {
  region = "${var.regionId}"
}

resource "aws_security_group" "allow_ssh_http_grafana" {
  name        = "allow_ssh_http_grafanas_${var.environment}"
  description = "Allow all inbound traffic for grafana"

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
    cidr_blocks = ["${var.myIp}"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.myIp}"]
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

resource "aws_instance" "grafana" {
  depends_on = ["aws_security_group.allow_ssh_http_grafana"]
  ami           = "ami-e2021d81"
  availability_zone = "${var.regionId}a"
  key_name = "${var.sshKey}"
  instance_type = "t2.micro"
  security_groups = [ "${aws_security_group.allow_ssh_http_grafana.name}" ]
  user_data = "${file("userdata.sh")}"
  root_block_device {
    volume_size = 20
  }

  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${var.environment}-grafana"
  }
}

data "aws_route53_zone" "selected" {
  name         = "${var.dnsApex}."
  private_zone = false
}

resource "aws_route53_record" "GrafanaDomain" {
  depends_on = ["aws_instance.grafana"]
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "prometheus-grafana.${var.dnsApex}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.grafana.public_ip}"]
}
