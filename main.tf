resource "aws_codebuild_project" "this" {
  name          = "${local.name}"
  description   = "${var.description}"
  service_role  = "${module.codebuild_role.role_arn}"
  build_timeout = "${var.timeout}"

  artifacts {
    type           = "S3"
    location       = "${var.artifact_bucket}"
    path           = "${local.name}"
    namespace_type = "BUILD_ID"
    packaging      = "NONE"
  }

  cache {
    type     = "NO_CACHE"
    location = "${module.cache_bucket_name.name}/${local.name}"
  }

  environment {
    compute_type = "${var.compute_type}"
    image        = "${var.image}"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "GRADLE_USER_HOME"
      "value" = ".gradle"
    }
  }

  source {
    type            = "${var.source_type}"
    location        = "${var.source_repository_url}"
    buildspec       = "${data.template_file.buildspec.rendered}"
    git_clone_depth = "${var.git_clone_depth}"
  }

  tags {
    "Service"       = "${var.service_name}"
    "ProductDomain" = "${var.product_domain}"
    "Environment"   = "management"
  }
}

module "codebuild_role" {
  source                     = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v0.4.3"
  role_identifier            = "${local.name}"
  role_description           = "Service Role for ${local.name}"
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

module "cache_bucket_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.1"

  name_prefix   = "${var.service_name}-codebuild-cache-${data.aws_caller_identity.current.account_id}-"
  resource_type = "s3_bucket"
}

resource "aws_s3_bucket" "cache" {
  bucket        = "${module.cache_bucket_name.name}"
  acl           = "private"
  force_destroy = true
  region        = "${data.aws_region.current.name}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix                                 = "${local.name}"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 7
    }
  }

  tags {
    Name          = "${module.cache_bucket_name.name}"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Description   = "Cache bucket for ${local.name} project"
    Environment   = "management"
  }
}
