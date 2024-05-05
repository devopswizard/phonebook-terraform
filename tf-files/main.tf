# Launch Template for ASG
resource "aws_launch_template" "asg-lt" {
  name = "phonebook-app-lt"
  image_id = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  key_name = var.key-name
  vpc_security_group_ids = [ aws_security_group.server-sg.id ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web Server of Phonebook App"
    }
  }

  user_data              = base64encode(templatefile("user-data.sh", { db-endpoint = aws_db_instance.db-server.address, user-data-git-token = data.aws_ssm_parameter.github-token.value, user-data-git-name = var.git-name }))
}

# This block creates the Load Balancer
resource "aws_lb" "pb-lb" {
  name               = "pb-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = data.aws_subnets.phonebook-app-subnets.ids
}


# This block creates the Listener for the ALB
resource "aws_lb_listener" "pb-listener" {
  load_balancer_arn = aws_lb.pb-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pb-tg.arn
  }
}

# This block creates the Target Group
resource "aws_lb_target_group" "pb-tg" {
  name     = "tf-pb-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
  target_type = "instance"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }

}

# This block creates the AutoScalingGroup
resource "aws_autoscaling_group" "pb-asg" {
  vpc_zone_identifier = aws_lb.pb-lb.subnets
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns = [ aws_lb_target_group.pb-tg.arn ]
  name = "phonebook-asg"

  launch_template {
    id      = aws_launch_template.asg-lt.id
    version = "$Latest"
  }
}

# This block creates the RDS
resource "aws_db_instance" "db-server" {
  allocated_storage    = 20
  db_name              = "phonebook"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Oliver_1"
  skip_final_snapshot  = true
  vpc_security_group_ids = [ aws_security_group.db-sg.id ]
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  backup_retention_period = 0
  identifier = "phonebook-app-db"
  monitoring_interval = 0
  port = 3306
  publicly_accessible = false
  multi_az = false
}

# This block selects the HostedZone Id
data "aws_route53_zone" "selected" {
  name         = var.hosted-zone
  private_zone = false
}

# This block creates the R53 Record
resource "aws_route53_record" "phonebook-record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "phonebook.${var.hosted-zone}"
  type    = "A"

  alias {
    name                   = aws_lb.pb-lb.dns_name
    zone_id                = aws_lb.pb-lb.zone_id
    evaluate_target_health = true
  }
}