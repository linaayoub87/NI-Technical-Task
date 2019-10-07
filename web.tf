resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web instance"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Web"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [module.lb.security_group_id]
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description      = "All protocols"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(local.tags, {"Name"="web-sg"})
}

data "aws_ami" "web" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20190823.1-x86_64-gp2"]
  }
  most_recent = true
  owners      = ["amazon"]
}

resource "aws_launch_template" "this" {
  name_prefix = "tech-task-node-"
  network_interfaces {
    security_groups = [aws_security_group.web.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.web_instance_profile.name
  }
  image_id      = data.aws_ami.web.id
  instance_type = "t2.micro"
  key_name      = "default"
  block_device_mappings {
    device_name = data.aws_ami.web.root_device_name
    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted = true
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.tags,
      {
        "Name" = "tech-task-node"
      },
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.tags,
      {
        "Name" = "tech-task-node"
      },
    )
  }
  tags = merge(
    local.tags,
    {
      "Name" = "tech-task-node"
    },
  )
  lifecycle {
    create_before_destroy = true
  }
  user_data = "${base64encode(data.template_file.this.rendered)}"
}

resource "aws_autoscaling_group" "this" {
  name             = "tech-task-node"
  desired_capacity = 3
  max_size         = 12
  min_size         = 3
  force_delete     = true
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  vpc_zone_identifier  = module.vpc.private_subnets
  target_group_arns    = module.lb.target_groups_arn
  protect_from_scale_in = "false"
  tag {
    key                 = "Name"
    value               = "tech-task-node"
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
