variable "namespace" {
  type = string
}

variable "secret" {
  type = string
}

variable "value" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
