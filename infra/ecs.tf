module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "producao"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_ecs_task_definition" "Django-API" {
  family                   = "Django-API"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions = jsonencode(
    [
      {
        "name"      = "producao"
        "image"     = "539638198221.dkr.ecr.us-east-1.amazonaws.com/producao:v1"
        "cpu"       = 1024
        "memory"    = 2048
        "essential" = true
        "portMappings" = [
          {
            "containerPort" = 8000
            "hostPort"      = 8000
          }
        ]
      }
    ]
  )
}


resource "aws_ecs_service" "Django-API" {
  name            = "Django-API"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.Django-API.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "producao"
    container_port   = 8000
  }

  network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
      capacity_provider = "FARGATE"
      weight = 1
  }
}