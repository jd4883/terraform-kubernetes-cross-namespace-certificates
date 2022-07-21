module "cert-manager" {
  source               = "terraform-iaac/cert-manager/kubernetes"
  cluster_issuer_email = var.email
  cluster_issuer_name  = var.issuer_name
  namespace_name       = var.namespace
  create_namespace     = local.create_namespace
  additional_set       = local.set
  certificates         = local.certificates
  solvers              = local.solvers
}
