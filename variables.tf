variable "service_name" {
  type        = "string"
  description = "The service name that will be released"
}

variable "product_domain" {
  type        = "string"
  description = "The owner of the service"
}

variable "description" {
  type        = "string"
  description = "Description for this build project"
}

variable "pre_build_commands" {
  type        = "list"
  default     = []
  description = "Commands for the pre_build phase"
}

variable "build_commands" {
  type        = "list"
  description = "Commands for the build phase"
}

variable "post_build_commands" {
  type        = "list"
  default     = []
  description = "Commands for the post_build phase"
}

variable "github_repository_url" {
  type        = "string"
  description = "The GitHub repository URL"
}

variable "additional_policies" {
  type        = "list"
  default     = []
  description = "Additional policies in JSONs to be given to the build project's role"
}

variable "compute_type" {
  type        = "string"
  default     = "BUILD_GENERAL1_LARGE"
  description = "The builder instance class"
}

variable "timeout" {
  type        = "string"
  default     = 60
  description = "The build timeout after which project will be stopped and considered to be failed"
}
