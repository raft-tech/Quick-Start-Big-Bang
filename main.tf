module "big_bang" {
  source = "git::https://github.com/raft-tech/raft-bb-infra-tf-launcher.git?ref=tags/v0.2.0"

  big_bang_manifest_file = "bigbang/start.yaml"
  registry_credentials = [{
    registry = "registry1.dso.mil"
    username = var.registry1_username
    password = var.registry1_password
  }]
}
