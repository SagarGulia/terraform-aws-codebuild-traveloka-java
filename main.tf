resource "aws_codebuild_project" "this" {
  name          = "${local.name}"
  description   = "${var.description}"
  service_role  = "${aws_iam_role.this.name}"
  build_timeout = "${var.timeout}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.cache.bucket}/${local.name}"
  }

  environment {
    compute_type = "${var.compute_type}"
    image        = "aws/codebuild/java:openjdk-8"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "GITHUB"
    location  = "${var.github_repository_url}"
    buildspec = "${data.template_file.buildspec.rendered}"
  }

  tags {
    "Service"       = "${var.service_name}"
    "ProductDomain" = "${var.product_domain}"
    "Environment"   = "management"
  }
}

module "role_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.0"

  name_prefix   = "ServiceRoleForCodeBuild_${var.service_name}"
  resource_type = "iam_role"
  keepers       = {}
}

resource "aws_iam_role" "this" {
  name                  = "${module.role_name.name}"
  assume_role_policy    = "${data.aws_iam_policy_document.codebuild_assume.json}"
  force_detach_policies = true
}

resource "aws_iam_role_policy" "main" {
  name   = "${module.role_name.name}-main"
  role   = "${aws_iam_role.this.id}"
  policy = "${data.aws_iam_policy_document.this.json}"
}

resource "aws_iam_role_policy" "additional" {
  name_prefix = "${module.role_name.name}-additional-"
  role        = "${aws_iam_role.this.id}"
  policy      = "${var.additional_policies[count.index]}"
  count       = "${length(var.additional_policies)}"
}

module "cache_bucket_name" {
  source = "github.com/traveloka/terraform-aws-resource-naming?ref=v0.7.0"

  name_prefix   = "${var.service_name}-codebuild-cache-"
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
      days                         = 7
      expired_object_delete_marker = true
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
