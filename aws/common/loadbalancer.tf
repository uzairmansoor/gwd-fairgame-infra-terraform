##########################################
# ALB (Application Load Balancer)
##########################################

resource "aws_security_group" "lb_security_group" {
  name_prefix = "${var.project}-${terraform.workspace}-lb-security-group"
  description = "Security Group for the Load Balancer"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.project}-${terraform.workspace}-lb-tg"
  port     = var.lb_target_group_port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  health_check {
    path                = "/api/v1/bookings/62FVB3U8N57"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    matcher             = "200-299"
  }
}

resource "aws_lb" "application_load_balancer" {
  name               = "${var.project}-${terraform.workspace}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.public_subnets.ids
  security_groups    = [aws_security_group.lb_security_group.id]
  idle_timeout       =  3600
  # client_keep_alive  =  3600
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = var.lb_listener_protocol
  # certificate_arn   = aws_acm_certificate.ai_chat.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
  depends_on = [aws_lb_target_group.lb_target_group]
}