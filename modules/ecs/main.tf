resource "aws_ecs_cluster" "filedgr-ipfs-ecs-cluster" {
  name = "ipfs-gateway-cluster"
}

resource "aws_ecs_service" "filedgr-ipfs-ecs-service" {
  name            = "ipfs-gateway-service"
  cluster         = aws_ecs_cluster.filedgr-ipfs-ecs-cluster.id
  task_definition = aws_ecs_task_definition.filedgr-ipfs-gateway-task.arn

  desired_count = 1
  launch_type   = "FARGATE"
  network_configuration {
    subnets         = [var.ipfs_subnet]
    security_groups = [var.securityGroupId]
  }

  load_balancer {
    container_name   = "ipfs-container"
    container_port   = 8080
    target_group_arn = var.webTargetGroup
  }
  load_balancer {
    container_name   = "ipfs-container"
    container_port   = 4001
    target_group_arn = var.ipfsTargetGroup
  }
  #    load_balancer {
  #    container_name   = "ipfs-container"
  #    container_port   = 5001
  #    target_group_arn = var.apiTargetGroup
  #  }
}

resource "aws_ecs_cluster_capacity_providers" "filedgr-fargate-capacity-provider" {
  cluster_name       = aws_ecs_cluster.filedgr-ipfs-ecs-cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "filedgr-ipfs-gateway-task" {
  family                = "service"
  container_definitions = jsonencode([
    {
      name = "ipfs-container"
      environment : [
#        { name = "IPFS_SWARM_KEY", value = "/key/swarm/psk/1.0.0/\n/base16/\nf14e252ab6d0523c4d4a1651fb4828edcbce42e1837f2acbe715c7b73da52bcb" },
#        { name = "IPFS_PROFILE", value = "server"},
        { name = "LIBP2P_FORCE_PNET", value = "1"}
      ],
      image        = var.ecr_ipfs_image
      cpu          = 2
      memory       = 4096
      essential    = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        },
        {
          containerPort = 5001
          hostPort      = 5001
        },
        {
          containerPort = 4001
          hostPort      = 4001
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = aws_cloudwatch_log_group.ipfs-logs.name
          awslogs-region = "eu-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  execution_role_arn       = aws_iam_role.filedgr-ipfs-ecs-task-execution.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  network_mode             = "awsvpc"
}


data "aws_iam_policy_document" "ecs_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ecs_execution_policy" {
  statement {
    sid     = "ECSTaskExecutionRole"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_cloudwatch_log_group" "ipfs-logs" {
    name = "ipfs-logs"

  tags = {
    Environment = "dev"
    Application = "ipfs-filedgr"
  }
}

resource "aws_iam_role" "filedgr-ipfs-ecs-task-execution" {
  name               = "filedgr-ipfs-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_trust_policy.json
}

resource "aws_iam_policy" "filedgr-ipfs-ecs-policy" {
  policy = data.aws_iam_policy_document.ecs_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.filedgr-ipfs-ecs-task-execution.name
  policy_arn = aws_iam_policy.filedgr-ipfs-ecs-policy.arn
}