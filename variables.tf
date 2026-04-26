variable "endpoint" {
  description = "Hostname or IP of Proxmox server"
  type        = string
}

variable "proxmox_username" {
  description = "User for Proxmox API"
  type        = string
}

variable "main_password" {
  description = "Password for Proxmox API"
  type        = string
  sensitive   = true
}

variable "vm_pass" {
  description = "Default password for VM user account"
  type        = string
  sensitive   = true
}

variable "pc_public_key_path" {
  description = "Path to SSH public key file for VM user"
  type        = string
}

variable "images" {
  description = "Image definitions to download to Proxmox datastore"
  type = map(object({
    content_type = optional(string, "import")
    datastore_id = string
    node_name    = string
    url          = string
    file_name    = string
  }))
}

variable "vms" {
  description = "VM definitions keyed by logical name"
  type = map(object({
    image_key                   = string
    vm_id                       = number
    name                        = string
    node_name                   = string
    description                 = optional(string, "Managed by Terraform")
    tags                        = optional(list(string), [])
    on_boot                     = optional(bool, true)
    startup_order               = optional(string, "3")
    startup_up_delay            = optional(string, "60")
    startup_down_delay          = optional(string, "60")
    agent_enabled               = optional(bool, true)
    cpu_cores                   = optional(number, 2)
    cpu_type                    = optional(string, "x86-64-v2-AES")
    memory_dedicated            = optional(number, 2048)
    memory_floating             = optional(number, 2048)
    disk_datastore_id           = string
    disk_interface              = optional(string, "scsi0")
    initialization_datastore_id = string
    ipv4_address                = optional(string, "dhcp")
    username                    = optional(string, "ubuntu")
    bridge                      = string
  }))
  default = {}
}

variable "vm_groups" {
  description = "VM groups with count and shared configuration"
  type = map(object({
    count       = number
    vm_id_start = number
    name_prefix = string
    config = object({
      image_key                   = string
      node_name                   = string
      description                 = optional(string, "Managed by Terraform")
      tags                        = optional(list(string), [])
      on_boot                     = optional(bool, true)
      startup_order               = optional(string, "3")
      startup_up_delay            = optional(string, "60")
      startup_down_delay          = optional(string, "60")
      agent_enabled               = optional(bool, true)
      cpu_cores                   = optional(number, 2)
      cpu_type                    = optional(string, "x86-64-v2-AES")
      memory_dedicated            = optional(number, 2048)
      memory_floating             = optional(number, 2048)
      disk_datastore_id           = string
      disk_interface              = optional(string, "scsi0")
      initialization_datastore_id = string
      ipv4_address                = optional(string, "dhcp")
      username                    = optional(string, "ubuntu")
      bridge                      = string
    })
  }))
  default = {}
}