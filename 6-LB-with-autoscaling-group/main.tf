data "aws_vpc" "default" {
  default = true
}

/*
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
*/

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

/*
output "alb_dns_name" {
  value       = aws_lb.loadbalancer.dns_name
  description = "DNS name of the load balancer"
}
*/

resource "aws_security_group" "allow-SSH-HTTP" {
  name        = "allow-SSH-HTTP"
  description = "allow ssh and http protocols"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all traffic outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ec2cluster" {
  name                   = "tf-template"
  image_id               = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow-SSH-HTTP.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "test"
    }
  }
  user_data = filebase64("${path.module}/example.sh")
}


resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg-tg.arn]
  health_check_type = "ELB"
  min_size          = 2
  max_size          = 4
  launch_template {
    id      = aws_launch_template.ec2cluster.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }
}

resource "aws_lb" "loadbalancer" {
  name               = "loadbalancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.allow-SSH-HTTP.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg-tg" {
  name     = "asg-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg-listen" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }

  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-tg.arn
  }
}
