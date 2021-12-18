resource "kubernetes_secret" "certificate" {
  metadata {
    name      = "${var.domain}-tls"
    namespace = var.starting_ns
    annotations = {
      "cert-manager.io/certificate-name"                         = var.domain
      "cert-manager.io/common-name"                              = var.domain
      "cert-manager.io/alt-names"                                = "*.${var.domain},${var.domain}"
      "cert-manager.io/ip-sans"                                  = var.ip-sans
      "cert-manager.io/issuer-group"                             = var.issuer-group
      "cert-manager.io/issuer-kind"                              = var.issuer-kind
      "cert-manager.io/issuer-name"                              = var.issuer
      "cert-manager.io/uri-sans"                                 = var.uri-sans
      "replicator.v1.mittwald.de/replication-allowed"            = var.replication-allowed
      "replicator.v1.mittwald.de/replication-allowed-namespaces" = join(",", var.namespaces)
    }
  }
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "certificate-replicas" {
  for_each = toset(var.namespaces)
  metadata {
    name      = kubernetes_secret.certificate.metadata.0.name
    namespace = each.value
    annotations = {
      "replicator.v1.mittwald.de/replicate-from"  = join("/", [kubernetes_secret.certificate.metadata.0.namespace, kubernetes_secret.certificate.metadata.0.name])
      "replicator.v1.mittwald.de/replicated-keys" = "tls.crt,tls.key"
      "replicator.v1.mittwald.de/strip-labels"    = var.strip-labels
    }
  }
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }
  type = "kubernetes.io/tls"
  lifecycle {
    ignore_changes = [
      data,
      metadata.0.annotations["replicator.v1.mittwald.de/replicated-at"],
      metadata.0.annotations["replicator.v1.mittwald.de/replicated-from-version"],
    ]
  }
  depends_on = [kubernetes_secret.certificate]
}
