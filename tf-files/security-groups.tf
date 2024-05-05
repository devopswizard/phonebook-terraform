# This block creates the RDS Security Group
resource "aws_security_group" "db-sg" {
  name        = "RDSSecuritygroup"
  description = "Allow traffic from 3306"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "RDS Security Group"
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    # cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [ aws_security_group.server-sg.id ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

# This block creates the EC2 Security Group
resource "aws_security_group" "server-sg" {
  name        = "ServerSecuritygroup"
  description = "Allow traffic from HTTP"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "Server Security Group"
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    # cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [ aws_security_group.lb-sg.id ]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

# This block creates the Load Balancer Security Group
resource "aws_security_group" "lb-sg" {
  name        = "LoadBalancerSecuritygroup"
  description = "Allow traffic from HTTP"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "Server Security Group"
  }

  ingress {
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
  }

}