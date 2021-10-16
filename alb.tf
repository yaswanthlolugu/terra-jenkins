resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow alb inbound traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress {
    description      = "alb from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.envname}-alb-sg"
  }
  
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.pubsubnet.*.id

 

   tags = {
    Name = "${var.envname}-alb"
   }

}  





