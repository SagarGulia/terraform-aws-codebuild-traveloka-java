provider "aws" {
  region = "ap-southeast-1"
}

data "aws_iam_policy_document" "assume_custom_role_example" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::123456789012:role/my-custom-role",
    ]
  }
}

module "codebuild" {
  source          = "../../"
  name            = "beisvc2-release-build"
  service_name    = "beisvc2"
  product_domain  = "bei"
  description     = "build project for backend service 2 release"
  artifact_bucket = "abc"
  cache_bucket    = "${aws_s3_bucket.cache.id}"

  pre_build_commands = [
    "echo \"Starting build for commit $${CODEBUILD_SOURCE_VERSION}\"",
  ]

  build_commands = [
    "./gradlew jar",
    "./gradlew uploadDistTar",
  ]

  post_build_commands = [
    "echo \"$${CODEBUILD_BUILD_SUCCEEDING}\"",
  ]

  additional_policies = [
    "${data.aws_iam_policy_document.assume_custom_role_example.json}",
  ]

  source_repository_url = "https://github.com/traveloka/backend-beisvc2.git"
}

resource "aws_s3_bucket" "cache" {
  bucket        = "def"
  acl           = "private"
  force_destroy = true
  region        = "${data.aws_region.current.name}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
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
    Name          = "def"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Description   = "Cache bucket for ${var.product_domain} CodeBuild projects"
    Environment   = "management"
  }
}
