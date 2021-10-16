resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow jenkins inbound traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress {
    description     = "jenkins from VPC"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]

  }

  ingress {
    description     = "jenkins from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.envname}-jenkins-sg"
  }

}


data "template_file" "user_data" {
  template = file("jenkins.sh")

}

resource "aws_instance" "jenkins" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.privatesubnet[0].id
  key_name               = aws_key_pair.petclinic1.id
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  user_data              = data.template_file.user_data.rendered


  tags = {
    Name = "${var.envname}-jenkins"
  }
}
