resource "aws_security_group" "bamboo-securitygroup" {
  vpc_id = "${aws_vpc.main.id}"
  name = "bamboo-securitygroup"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
      from_port = 8085
      to_port = 8085
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }		   
tags {
    Name = "bamboo-securitygroup"
  }
}
resource "aws_security_group" "app-securitygroup" {
  vpc_id = "${aws_vpc.main.id}"
  name = "app-securitygroup"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  } 
tags {
    Name = "app-securitygroup"
  }
}
