variable "name" {
  type        = "string"
  default     = ""
  description = "The project name. If unspecified, this will be <service_name>-release-build"
}

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

variable "source_type" {
  type        = "string"
  default     = "GITHUB"
  description = "The type of repository that contains the source code to be built. See https://www.terraform.io/docs/providers/aws/r/codebuild_project.html#type-3"
}

variable "source_repository_url" {
  type        = "string"
  description = "The source repository URL"
}

variable "cache_bucket" {
  type        = "string"
  default     = ""
  description = "An S3 bucket to store build caches (in <cache_bucket>/<codebuild_project_name>/ path) to"
}

variable "appbin_bucket_name" {
  type        = "string"
  description = "An S3 bucket to store application binary and playbook"
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

variable "git_clone_depth" {
  type        = "string"
  default     = 1
  description = "The history depth with which the repository will be cloned. Setting this to 0 means full clone"
}

variable "image" {
  type        = "string"
  default     = "traveloka/codebuild-openjdk:v0.1.0"
  description = "The image that CodeBuild will use to execute the build steps"
}

variable "additional_policies" {
  type        = "list"
  default     = []
  description = "Additional policies in JSONs to be given to the build project's role"
}
