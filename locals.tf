locals {
  namespaces       = setsubtract(data.kubernetes_all_namespaces.allns.namespaces, var.excluded_ns)
  create_namespace = contains(local.namespaces, var.namespace) ? false : true
  certificates = {
    (var.domain) = {
      dns_names             = ["*.${var.domain}"]
      private_key_algorithm = var.cryptography.algorithm
      private_key_size      = var.cryptography.key_size
      secret_annotations = {
        "replicator.v1.mittwald.de/replication-allowed"            = "true"
        "replicator.v1.mittwald.de/replication-allowed-namespaces" = join(",", setsubtract(local.namespaces, [var.namespace]))
      }
    }
  }
  solvers = [
    {
      dns01 = {
        (var.solver.provider) = {
          email = var.email
          tokenSecretRef = {
            name = var.solver.name
            key  = var.solver.key
          }
        }
        selector = { dnsZones = [var.domain] }
      }
    }
  ]
  set = [for s in var.dns_servers : {
    name  = "podDnsConfig.nameservers[${index(var.dns_servers, s)}]"
    value = s
    }
  ]
}
