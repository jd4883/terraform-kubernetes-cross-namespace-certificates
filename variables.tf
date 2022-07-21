variable "email" { type = string }
variable "excluded_ns" { type = list(string) }

variable "solver" {
  type = object({
    type     = string
    provider = string
    name     = string
    key      = string
  })
}

variable "cryptography" {
  type = object({
    algorithm = string
    key_size  = number
  })
  default = {
    algorithm = "ECDSA"
    key_size  = 384
  }
}

variable "domain" {
  type    = string
  default = "example.com"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "issuer_name" {
  type    = string
  default = "letsencrypt-production"
}

variable "dns_servers" {
  type = list(string)
  default = [
    "8.8.8.8",
    "8.8.4.4",
  ]
}
