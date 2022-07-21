terraform {
  required_version = ">=1.0.0"
  required_providers {
    helm       = { source = "hashicorp/helm" }
    kubectl    = { source = "gavinbunney/kubectl" }
    kubernetes = { source = "hashicorp/kubernetes" }
    local      = { source = "hashicorp/local" }
    template   = { source = "hashicorp/template" }
    time       = { source = "hashicorp/time" }
  }
}
