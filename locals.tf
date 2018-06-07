locals {
  gradle_user_home = ".gradle"

  gradle_cache_dirs = [
    "${local.gradle_user_home}/caches/modules-2/**/*",
    "${local.gradle_user_home}/wrapper/**/*",
  ]
}
