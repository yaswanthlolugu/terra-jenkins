resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress {
    description = "SSH from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.envname}-bastion-sg"
  }

}

# ec2 

#key
resource "aws_key_pair" "petclinic1" {
  key_name   = "petclinic1-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxJjrxUTwDPwJ8lw0mMSftZFrxns2FlOB0uNqLfZabDPyI7ZqZgF09Y6RmGPKquHLpHNxP5I0OZgEjggz9AJIymuY+gBJzZTeu1qa8TAki3HaXFEilTcNG0XO/qNw2oiL4xfFmOKdyWn4y+24n1OuEu/GAQvYa1mrXqyqDS9VSJRqf9+CnmLflqX2PfUREOaN+sL4w7V30FLvqRw8260prnPG99AbLno2x65vvc3F22nVZ5eH/XWP2kfgWTr7j/FP82hdsVbbZ44t2VJgda2pXodl+UAM/Ytr3ldj+ZEORaADk9i0QCT9MK1gKTm0HbyeWtMjoCghbPgrZAL2ipwjZbIu/1xMwBlr5P33Iyr3Scm8X6eIFVEaHaAVhKB0M4JplyKKHyzYnPvKVCZmubmzJBKAdVIeSOMoUhE+Z9TN9P5sSk7AZdY2JEuBVAuxR/qKulERjJLvMxPzgfLxB+O0l55IwyoID3phkhtsF/X0e/ryB/yIvcqCjymovzZGn8UM= Admin@DESKTOP-TUAU5V1"
}

resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = var.type
  subnet_id              = aws_subnet.pubsubnet[0].id
  key_name               = aws_key_pair.petclinic1.id
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]


  tags = {
    Name = "${var.envname}-bastion"
  }
}
