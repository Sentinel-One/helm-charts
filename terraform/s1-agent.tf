provider "aws" {
  region = var.cluster_region
}

# ECS Task Definition
resource "aws_ecs_task_definition" "s1_agent_task_definition" {
  family                   = "s1-agent-task-definition"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([{
    name = "s1-agent"
    image = var.s1_agent_image
    repositoryCredentials = {
      "credentialsParameter": var.image_pull_secret
    }
    essential = true
    command = [
      "/opt/deployment.sh"
    ]
    environment = [
      {
        "name": "S1_AGENT_HOST_MOUNT_PATH",
        "value": var.host_mount_path
      },
      {
        "name": "SITE_TOKEN",
        "value": var.site_token
      },
      {
        "name": "S1_LOG_LEVEL",
        "value": var.log_level
      },
      {
        "name": "S1_AGENT_TYPE",
        "value": "ecs_ec2"
      },
      {
        "name": "S1_WATCHDOG_HEALTHCHECK_TIMEOUT",
        "value": var.watchdog_healthcheck_timeout
      },
      {
        "name": "S1_CONTAINER_NAME",
        "value": "s1-agent"
      },
      {
        "name": "S1_PERSISTENT_DIR",
        "value": "/var/lib/sentinelone"
      },
      {
        "name": "S1_AGENT_ENABLED",
        "value": tostring(var.agent_enabled)
      },
      {
        "name": "S1_FIPS_ENABLED",
        "value": tostring(var.fips_enabled)
      },
      {
        "name": "S1_EBPF_ENABLED",
        "value": tostring(var.ebpf_enabled)
      }
    ]
    mountPoints = [
      {
        "sourceVolume": "host",
        "containerPath": var.host_mount_path,
        "readOnly": false
      },
      {
        "sourceVolume": "docker",
        "containerPath": "/var/run/docker.sock",
        "readOnly": false
      }
    ]
    linuxParameters = {
      capabilities = {
        add = [
          "DAC_OVERRIDE",
          "DAC_READ_SEARCH",
          "FOWNER",
          "SETGID",
          "SETUID",
          "SYS_ADMIN",
          "SYS_PTRACE",
          "SYS_RESOURCE",
          "SYSLOG",
          "SYS_CHROOT",
          "CHOWN",
          "SYS_MODULE",
          "KILL",
          "NET_ADMIN",
          "NET_RAW"
        ]
        drop = []
      }
      initProcessEnabled = true
    }
    user = "${var.task_uid}:${var.task_gid}"

    logConfiguration = var.debugging_enabled ? {
      logDriver = "awslogs"
      options = {
        awslogs-group = "/ecs/s1-service-logs"
        awslogs-region = var.cluster_region
        awslogs-stream-prefix = "s1-agent"
      }
    } : null
  }])
  task_role_arn = var.task_role_arn
  execution_role_arn = var.execution_role_arn
  network_mode = "host"
  volume {
    name = "host"
    host_path = "/"
  }
  volume {
    name = "docker"
    host_path = "/var/run/docker.sock"
  }
  cpu = var.agent_task_cpu
  memory = var.agent_task_memory
  pid_mode = "host"
}

# ECS Service
resource "aws_ecs_service" "s1_agent_daemon_service" {
  name            = "s1-agent-daemon-service"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.s1_agent_task_definition.arn
  launch_type     = "EC2"
  scheduling_strategy = "DAEMON"
  enable_execute_command = var.debugging_enabled
}
