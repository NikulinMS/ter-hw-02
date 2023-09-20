variable "vm_web_family" {
  type = string
  default = "ubuntu-2004-lts"
}

#variable "vm_web_name" {
#  type = string
#  default = "netology-develop-platform-web"
#}

variable "vm_web_platform_id" {
  type = string
  default = "standard-v1"
}

#variable "vm_web_cores" {
#  type = number
#  default = 2
#}
#
#variable "vm_web_memory" {
#  type = number
#  default = 1
#}
#
#variable "vm_web_core_fraction" {
#  type = number
#  default = 5
#}
#
#variable "vm_db_name" {
#  type = string
#  default = "netology-develop-platform-db"
#}

variable "vm_db_platform_id" {
  type = string
  default = "standard-v1"
}

#variable "vm_db_cores" {
#  type = number
#  default = 2
#}
#
#variable "vm_db_memory" {
#  type = number
#  default = 2
#}
#
#variable "vm_db_core_fraction" {
#  type = number
#  default = 20
#}

variable "vms_resources" {
  type = map(object({
    cores = number
    memory = number
    core_fraction = number
  }))
  default = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    vm_db_resources = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "vms_metadata" {
  type = map
  default = {
    serial-port-enable = 1
    ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2kpc8hkCtD5uVQdw0wUeGlNp/rKarSrCKoifhuRtCF shakal@Razer"
  }
}