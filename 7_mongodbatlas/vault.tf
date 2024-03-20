variable "tfc_organization" {}

data "terraform_remote_state" "nomad_cluster" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = "5_nomad-cluster"
    }
  }
}

provider "vault" {}

data "vault_kv_secret_v2" "bootstrap" {
  mount = data.terraform_remote_state.nomad_cluster.outputs.bootstrap_kv
  name  = "nomad_bootstrap/SecretID"
}



resource "vault_database_secret_backend_connection" "mongodbatlas" {
  backend       = "database"
  name          = "mongodbatlas"
  allowed_roles = ["*"]

  mongodbatlas {
    public_key  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_public"]
    private_key = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_private"]
    project_id  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_project"]
  }
}

resource "vault_database_secret_backend_role" "mdba-role" {
  backend             = "database"
  name                = "atlas-dev"
  db_name             = vault_database_secret_backend_connection.mongodbatlas.name
  creation_statements = ["{'database_name': 'admin','roles': [{'databaseName':'admin','roleName':'atlasAdmin'}]}"]
}