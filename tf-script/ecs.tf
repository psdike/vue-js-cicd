provider "aws" {
  region = "us-east-1"  
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn        = aws_iam_role.ecs_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "vuejs-container"
      image = "psdike/vuejs:latest"  # Replace with the actual Docker image
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_ecs_service" "my_service" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 2  

  network_configuration {
    subnets = [aws_subnet.my_subnet.id]  
    security_groups = [aws_security_group.my_security_group.id]  
  }
}

resource "aws_lb" "my_load_balancer" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_subnet.id]  

  enable_deletion_protection = false

  enable_http2 = true
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

resource "aws_security_group" "my_security_group" {
  name_prefix = "my-app-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "my_subnet" {
  count = 2 

  availability_zone = "us-east-1a"  
  cidr_block        = "10.0.1.0/24" 
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.my_vpc.id  
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  
}
