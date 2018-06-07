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
  source         = "../../"
  name           = "backend-my_repo-experiment"
  service_name   = "my_repo"
  product_domain = "bei"
  description    = "Try building my_repo in AWS CodeBuild"

  build_commands = [
    "./gradlew build",
  ]

  additional_policies = [
    "${data.aws_iam_policy_document.assume_custom_role_example.json}",
  ]

  source_repository_url = "https://github.com/traveloka/backend-my_repo.git"
}
