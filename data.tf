data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.cache_bucket}/${var.name}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.artifact_bucket}/${var.name}/*",
    ]
  }
}

data "template_file" "buildspec" {
  template = <<EOF
version: 0.2
phases:
  pre_build:
    commands:
      - $${pre_build_commands}
  build:
    commands:
      - $${build_commands}
  post_build:
    commands:
      - $${post_build_commands}
cache:
  paths:
    - $${build_cache}
EOF

  vars {
    build_cache         = "${join("\n    - ", local.gradle_cache_dirs)}"
    pre_build_commands  = "${join("\n      - ", var.pre_build_commands)}"
    build_commands      = "${join("\n      - ", var.build_commands)}"
    post_build_commands = "${join("\n      - ", var.post_build_commands)}"
  }
}
