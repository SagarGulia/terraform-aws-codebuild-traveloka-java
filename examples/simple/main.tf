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
  service_name    = "beisvc2"
  product_domain  = "bei"
  description     = "build project for backend service 2 release"
  artifact_bucket = "abc"

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
