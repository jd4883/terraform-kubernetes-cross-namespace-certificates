terraform {
  required_providers {
    local      = { source = "hashicorp/local" }
    helm       = { source = "hashicorp/helm" }
    kubectl    = { source = "gavinbunney/kubectl" }
    kubernetes = { source = "hashicorp/kubernetes" }
  }
}
