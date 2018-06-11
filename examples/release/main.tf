provider "aws" {
  region = "ap-southeast-1"
}

data "aws_iam_policy_document" "write_to_artifact_bucket" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.artifact.id}/beisvc2/*",
    ]
  }
}

module "codebuild" {
  source         = "../../"
  name           = "beisvc2-release-build"
  service_name   = "beisvc2"
  product_domain = "bei"
  description    = "build project for backend service 2 release"
  cache_bucket   = "${aws_s3_bucket.cache.id}"

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
    "${data.aws_iam_policy_document.write_to_artifact_bucket.json}",
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
    Environment   = "special"
  }
}

resource "aws_s3_bucket" "artifact" {
  bucket = "abc"
  acl    = "private"
  region = "${data.aws_region.current.name}"

  tags {
    Name          = "abc"
    Service       = "${var.service_name}"
    ProductDomain = "${var.product_domain}"
    Description   = "Artifact bucket for ${var.product_domain} CodeBuild projects"
    Environment   = "special"
  }
}
