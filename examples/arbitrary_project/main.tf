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

module "codebuild" {
  source         = "../../"
  name           = "backend-my_repo-experiment"
  service_name   = "my_repo"
  product_domain = "bei"
  description    = "Try building my_repo in AWS CodeBuild"
  cache_bucket   = "${aws_s3_bucket.cache.id}"

  build_commands = [
    "./gradlew build",
  ]

  additional_policies = [
    "${data.aws_iam_policy_document.assume_custom_role_example.json}",
  ]

  source_repository_url = "https://github.com/traveloka/backend-my_repo.git"
}
