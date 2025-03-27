variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "cluster_region" {
  description = "The region of the ECS cluster (default us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "s1_agent_image" {
  description = "The s1 agent full image path (repo:tag)"
  type        = string
  default     = "containers.sentinelone.net/cws-agent/s1agent:25.1.1-ea"
}

variable "image_pull_secret" {
  description = "Specify the name of the image pull secret (created outside this form)"
  type        = string
}

variable "task_role_arn" {
  description = "Specify the task role ARN (created outside this form)"
  type        = string
}

variable "execution_role_arn" {
  description = "Specify the execution role ARN (created outside this form)"
  type        = string
}

variable "site_token" {
  description = "Set site token to connect to the console."
  type        = string
  default     = ""
}

variable "log_level" {
  description = "agent log level - info, error, warning, debug, trace (defaults to 'info')"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["info", "error", "warning", "debug", "trace"], var.log_level)
    error_message = "Allowed values: info, error, warning, debug, trace."
  }
}

# Most users will not want to make changes below this line.

variable "debugging_enabled" {
  description = "To enable debugging, set to 'true'"
  type        = bool
  default     = false
}

variable "host_mount_path" {
  description = "Host mount path. Leave default unless host path is mounted elsewhere in your environment"
  type        = string
  default     = "/host"
}

variable "task_uid" {
  description = "User id of the default task user"
  type        = number
  default     = 1000
}

variable "task_gid" {
  description = "Group of the default task user"
  type        = number
  default     = 1000
}

variable "agent_enabled" {
  description = "To disable the agent, set to 'false'"
  type        = bool
  default     = true
}

variable "ebpf_enabled" {
  description = "To disable EBPF, set to 'false'"
  type        = bool
  default     = true
}

variable "fips_enabled" {
  description = "To disable FIPS, set to 'false'"
  type        = bool
  default     = true
}

variable "agent_task_cpu" {
  description = "Agent task cpu limitation"
  type        = number
  default     = 1024
}

variable "agent_task_memory" {
  description = "Agent task memory limitation"
  type        = number
  default     = 3072
}

variable "watchdog_healthcheck_timeout" {
  description = "Timeout for s1 agent watchdog in seconds (default 15 seconds)"
  type        = string
  default     = "15"
}

variable "parallel_cleanups" {
  description = "Number of parallel cleanups to run"
  type        = number
  default     = 1
}
