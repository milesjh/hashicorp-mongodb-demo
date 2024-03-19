terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15.1"
    }

    hcp = {
      source = "hashicorp/hcp"
      version = "~> 0.83.0"
    }
  }
}

provider "hcp" {}

# Specify the app in the project (one app_name per data block)
data "hcp_vault_secrets_app" "mongodb-atlas" {
  app_name = "mongodb-atlas"
# Limit the scope to only one or more secrets in the app
# secret_name = “secret-name-1” “secret-name-2”
}

# Replace your existing secret references with
# data.hcp_vault_secrets_app.mongodb-atlas.secret-name


provider "mongodbatlas" {
  public_key  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["MONGODB_ATLAS_PUBLIC"]
  private_key = data.hcp_vault_secrets_app.mongodb-atlas.secrets["MONGODB_ATLAS_PRIVATE"]
}

resource "mongodbatlas_cluster" "lifetimecluster" {
  project_id                  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["MONGODB_PROJECT"]
  name                        = "TerraformAtLifetime"
  cluster_type                = "REPLICASET"
  provider_name               = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M10"
}
