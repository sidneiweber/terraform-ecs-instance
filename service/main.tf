resource "aws_cloudwatch_log_group" "webserver" {
  name              = "webserver"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "webserver" {
  family = "webserver"

  container_definitions = <<EOF
[
  {
    "name": "webserver",
    "image": "sidneiweber/nginx-demo:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-group": "webserver",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "webserver" {
  name            = "webserver"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.webserver.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
