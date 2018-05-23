locals {
  name = "${format("%s-%s",var.service_name, "release-build")}"
}
