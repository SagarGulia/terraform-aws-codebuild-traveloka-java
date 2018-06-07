output "project_name" {
  value       = "${var.name}"
  description = "The name of the codebuild project"
}

output "project_arn" {
  value       = "${aws_codebuild_project.this.id}"
  description = "The ARN of the codebuild project"
}

output "buildspec" {
  value       = "${data.template_file.buildspec.rendered}"
  description = "The project's full generated buildspec"
}

output "role_arn" {
  value       = "${module.codebuild_role.role_arn}"
  description = "The project's IAM role ARN"
}
