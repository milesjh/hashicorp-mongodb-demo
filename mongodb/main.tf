terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15.1"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.MONGODB_ATLAS_PUBLIC_KEY
  private_key = var.MONGODB_ATLAS_PRIVATE_KEY
}

resource "mongodbatlas_cluster" "lifetimecluster" {
  project_id                  = var.MONGODB_PROJECT_ID
  name                        = "TerraformAtLifetime"
  cluster_type                = "REPLICASET"
  provider_name               = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M10"
}
