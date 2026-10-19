# Single-line comment style (Lecture 88)
// Alternative comment style (Lecture 88)
/*
  Multi-line block comment
  covering settings and local testing resources.
*/

terraform {
  # Lecture 84: Terraform Settings block
  required_version = ">= 1.4.0"
}

locals {
  server_names = ["web-stage", "api-prod", "db-prod"]
  server_roles = ["frontend", "backend", "database"]
}

# Creates 3 test resources to simulate multiple servers
resource "terraform_data" "servers" {
  count = 3

  input = {
    id   = count.index + 1
    name = local.server_names[count.index]
  }
}

# Standalone resource to test resource targeting and dependency ordering
resource "terraform_data" "database" {
  input = "postgresql-v16"
}

# Lecture 80 & 83: Splat expression and Outputs
output "all_server_ids" {
  value = terraform_data.servers[*].id
}

# Lecture 87: Zipmap function merging two lists into a key-value map
output "server_role_mapping" {
  value = zipmap(local.server_names, local.server_roles)
}