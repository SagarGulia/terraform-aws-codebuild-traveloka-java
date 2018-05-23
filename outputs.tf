output "project_name" {
  value       = "${local.name}"
  description = "The name of the codebuild project"
}

output "buildspec" {
  value       = "${data.template_file.buildspec.rendered}"
  description = "The project's full generated buildspec"
}

output "role_arn" {
  value       = "${aws_iam_role.this.arn}"
  description = "The project's IAM role ARN"
}
