variable "domain" { type = string }
variable "issuer" { type = string }
variable "namespaces" { type = list(string) }


variable "starting_ns" {
  type    = string
  default = "kube-system"
}

variable "ip-sans" {
  type    = string
  default = ""
}
variable "issuer-group" {
  type    = string
  default = "cert-manager.io"
}
variable "issuer-kind" {
  type    = string
  default = "ClusterIssuer"
}
variable "uri-sans" {
  type    = string
  default = ""
}

variable "strip-labels" {
  type    = string
  default = "true"
}

variable "replication-allowed" {
  type    = string
  default = "true"
}

variable "email" { type = string }
