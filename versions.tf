terraform {
  required_providers {
    local      = { source = "hashicorp/local" }
    helm       = { source = "hashicorp/helm" }
    kubernetes = { source = "hashicorp/kubernetes" }
  }
}
