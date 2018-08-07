resource "aws_codebuild_project" "this" {
  name          = "${var.name}"
  description   = "${var.description}"
  service_role  = "${module.codebuild_role.role_arn}"
  build_timeout = "${var.timeout}"

  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "${var.cache_bucket == "" ? "NO_CACHE" : "S3"}"
    location = "${var.cache_bucket}/${var.name}"
  }

  environment {
    compute_type = "${var.compute_type}"
    image        = "${var.image}"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "GRADLE_USER_HOME"
      "value" = "${local.gradle_user_home}"
    }
  }

  source {
    type                = "${var.source_type}"
    location            = "${var.source_repository_url}"
    buildspec           = "${data.template_file.buildspec.rendered}"
    git_clone_depth     = "${var.git_clone_depth}"
    report_build_status = true
  }

  tags {
    "Service"       = "${var.service_name}"
    "ProductDomain" = "${var.product_domain}"
    "Environment"   = "management"
  }
}

module "codebuild_role" {
  source                     = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v0.4.3"
  role_identifier            = "${var.name}"
  role_description           = "Service Role for ${var.name}"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codebuild.amazonaws.com"
}

resource "aws_iam_role_policy" "main" {
  name   = "${module.codebuild_role.role_name}-main"
  role   = "${module.codebuild_role.role_name}"
  policy = "${data.aws_iam_policy_document.this.json}"
}

resource "aws_iam_role_policy" "additional" {
  name_prefix = "${module.codebuild_role.role_name}-additional-"
  role        = "${module.codebuild_role.role_name}"
  policy      = "${var.additional_policies[count.index]}"
  count       = "${length(var.additional_policies)}"
}
