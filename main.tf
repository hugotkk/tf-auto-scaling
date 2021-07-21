provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "webapp" {
  name        = "webapp"
  description = "Allow TLS inbound traffic"

  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "80 from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "22 from VPC"
    from_port        = 22
    to_port          = 22 
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webapp"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_launch_template" "hugo_2" {
  name = "hugo_2"

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
      # very important
      volume_type = "gp2"
    }
  }

  vpc_security_group_ids = [aws_security_group.webapp.id]
  ebs_optimized = true
  image_id = "ami-09e67e426f25ce0d7"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = "terraform"

  monitoring {
   enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp"
    }

 }

  user_data = filebase64("${path.module}/setup.sh")
}

resource "aws_placement_group" "webapp" {
  name     = "webapp"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "webapp" {
  vpc_zone_identifier = [aws_subnet.main.id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.hugo_2.id
    version = aws_launch_template.hugo_2.latest_version
  }
  placement_group           = aws_placement_group.webapp.id

}

resource "aws_autoscaling_policy" "webapp" {
  name                   = "webapp"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webapp.name
}

/*resource "aws_autoscaling_policy" "agents-scale-up" {
    name = "agents-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.agents.name}"
}

resource "aws_autoscaling_policy" "agents-scale-down" {
    name = "agents-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.agents.name}"
}

resource "aws_cloudwatch_metric_alarm" "memory-high" {
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.agents.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
    alarm_name = "mem-util-low-agents"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.agents.name}"
    }
}
*/
/*
resource "aws_autoscaling_attachment" "webapp" {
  autoscaling_group_name = aws_autoscaling_group.webapp.id
  elb                    = aws_lb.webapp.id
}

resource "aws_lb" "webapp" {
  name               = "hugotkk"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp.id]
  subnets            = [aws_subnet.main.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "hugotkk-lb"
    enabled = true
  }

  tags = {
	name = "webapp"
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "hugotkk-lb_logs"
  acl    = "private"

  tags = {
    Name        = "lb_logs"
    Environment = "Production"
  }
}

resource "aws_default_subnet" "main_az1" {
  availability_zone = "us-west-2a"
  tags = {
    Name = "Default subnet for us-west-2a"
  }
}
*/
