##########################################
# AWS Autoscaling Group
##########################################

resource "aws_security_group" "asg_security_group" {
  name        = "${var.project}-${terraform.workspace}-lb-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.vpc.id
  tags = {
      Name = "${var.project}-${terraform.workspace}asg-security-group"
    }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_vpc_security_group_ingress_rule" "asg_sg_ssh" {
#   security_group_id = aws_security_group.asg_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 22
#   ip_protocol       = "tcp"
#   to_port           = 22
# }
# resource "aws_vpc_security_group_ingress_rule" "asg_sg_app" {
#   security_group_id = aws_security_group.asg_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 3000
#   ip_protocol       = "tcp"
#   to_port           = 3000
# }
# resource "aws_vpc_security_group_ingress_rule" "asg_sg_http" {
#   security_group_id = aws_security_group.asg_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }
# resource "aws_vpc_security_group_ingress_rule" "asg_sg_https" {
#   security_group_id = aws_security_group.asg_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }
# resource "aws_vpc_security_group_egress_rule" "asg_security_group_egress" {
#   security_group_id = aws_security_group.asg_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }
resource "aws_launch_template" "launch_template" {
  name = "${var.project}-${terraform.workspace}-launch-template"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }
  image_id = "ami-01ec84b284795cbc7"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  iam_instance_profile {
    name = "gwd-fairgame-dev-manual-ec2-role"
  }
  key_name = "${var.project}-${terraform.workspace}-${var.location}-${var.account_id}"
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.asg_security_group.id]
  }
  placement {
    availability_zone = var.zone_subnet_1
  }
  user_data = filebase64("ec2_user_data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-${terraform.workspace}-launch-template"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
    name                      = "${var.project}-${terraform.workspace}-autoscaling-group"
    max_size                  = 1
    min_size                  = 1
    health_check_grace_period = 300
    desired_capacity          = 1
    force_delete              = true
    vpc_zone_identifier       = module.public_subnets.ids  # Assuming these are your subnet IDs
    target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
    warm_pool {
    pool_state                  = "Stopped"
    min_size                    = 0
    max_group_prepared_capacity = 0
    instance_reuse_policy {
      reuse_on_scale_in = true
    }
  }
    launch_template {
        id           =   aws_launch_template.launch_template.id
        version      =   "$Latest"
    }
    tag {
        key                 = "Name"
        value               = "${var.project}-${terraform.workspace}-autoscaling-group"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                      = "${var.project}-${terraform.workspace}-scale-out-policy"
  policy_type               = "StepScaling"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.autoscaling_group.name
  estimated_instance_warmup = 60
  step_adjustment {
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 30
    scaling_adjustment          = 2
  }
  step_adjustment {
    metric_interval_lower_bound = 30
    metric_interval_upper_bound = 80
    scaling_adjustment          = 4
  }
  step_adjustment {
    metric_interval_lower_bound = 80
    scaling_adjustment          = 8
  }
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                      = "${var.project}-${terraform.workspace}-scale-in-policy"
  policy_type               = "StepScaling"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.autoscaling_group.name
  estimated_instance_warmup = 60
  step_adjustment {
    metric_interval_lower_bound = -50
    metric_interval_upper_bound = 0
    scaling_adjustment          = -4
  }
  step_adjustment {
    metric_interval_lower_bound = -80
    metric_interval_upper_bound = -50
    scaling_adjustment          = -2
  }
  step_adjustment {
    metric_interval_upper_bound = -80
    scaling_adjustment          = -1
  }
}