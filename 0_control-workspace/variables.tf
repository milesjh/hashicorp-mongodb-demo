variable "tfc_organization" {
  type = string
}

variable "tfc_project_id" {
  type = string
}

variable "repo_identifier" {
  type = string
}

variable "repo_branch" {
  type = string
  default = "main"
}

variable "oauth_token_id" {
  type = string
}