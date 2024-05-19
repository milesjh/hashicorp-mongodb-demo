terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15.1"
    }

    hcp = {
      source  = "hashicorp/hcp"
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
  public_key  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_public"]
  private_key = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_private"]
}

resource "mongodbatlas_cluster" "lifetimecluster" {
  project_id                  = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_project"]
  name                        = "TerraformAtLifetime"
  cluster_type                = "REPLICASET"
  provider_name               = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M10"
}

import {
  id = "6241fc75cc1e8a0eb24198f1-terraformUser-admin"
  to = mongodbatlas_database_user.user1
}

resource "mongodbatlas_database_user" "user1" {
  username           = "terraformUser"
  password           = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_user_password"]
  project_id         = data.hcp_vault_secrets_app.mongodb-atlas.secrets["mongodb_atlas_project"]
  auth_database_name = "admin"

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }

  labels {
    key   = "Name"
    value = "DB User1"
  }

  scopes {
    name = mongodbatlas_cluster.lifetimecluster.name
    type = "CLUSTER"
  }
}
