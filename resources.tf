resource "kubectl_manifest" "cluster-issuer" {
  for_each = {
    production = "https://acme-v02.api.letsencrypt.org/directory"
    staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"
  }
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-${each.key}"
    }
    spec = {
      acme = {
        email          = var.email
        preferredChain = ""
        privateKeySecretRef = {
          key  = "private-key"
          name = "letsencrypt-${each.key}"
        }
        server        = each.value
        skipTLSVerify = true
        solvers = [
          {
            dns01 = {
              digitalocean = {
                tokenSecretRef = {
                  key  = "access-token"
                  name = "digitalocean-api-key"
                }
              }
              selector = { dnsZones = [var.domain] }
            }
          }
        ]
      }
    }
  })
  ignore_fields = [
    "metadata.managedFields",
    "spec.status",
  ]
}

resource "kubectl_manifest" "base-certificate" {
  for_each = toset(["production", "staging"])
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = var.domain
      namespace = var.starting_ns
    }
    spec = {
      dnsNames = [var.domain, "*.${var.domain}"]
      isCA     = false
      issuerRef = {
        group = "cert-manager.io"
        kind  = "ClusterIssuer"
        name  = "letsencrypt-${each.value}"
      }
      privateKey = {
        algorithm = "ECDSA"
        size      = 384
      }
      secretName = "${var.domain}-tls"
    }
  })
  ignore_fields = [
    "metadata.managedFields",
    "spec.status",
  ]
}

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
