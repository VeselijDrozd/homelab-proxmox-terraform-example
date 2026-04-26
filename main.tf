resource "proxmox_download_file" "images" {
  for_each = var.images

  content_type = each.value.content_type
  datastore_id = each.value.datastore_id
  node_name    = each.value.node_name
  url          = each.value.url
  file_name    = each.value.file_name
}

locals {
  # Expand grouped VM definitions (count + shared config) into concrete VM objects.
  vms_from_groups = merge([
    for group_key, group in var.vm_groups : {
      for idx in range(group.count) :
      format("%s-%02d", group_key, idx + 1) => merge(group.config, {
        vm_id = group.vm_id_start + idx
        name  = format("%s-%02d", group.name_prefix, idx + 1)
      })
    }
  ]...)

  # Explicit vms entries override generated group entries on key conflicts.
  vms_expanded = merge(local.vms_from_groups, var.vms)
}

module "vms" {
  for_each = local.vms_expanded

  source = "git::https://github.com/VeselijDrozd/terraform-proxmox-vm-module.git?ref=1.0.0"

  image_id       = proxmox_download_file.images[each.value.image_key].id
  ssh_public_key = trimspace(file(var.pc_public_key_path))
  vm_password    = var.vm_pass
  config = {
    vm_id                       = each.value.vm_id
    name                        = each.value.name
    node_name                   = each.value.node_name
    description                 = each.value.description
    tags                        = each.value.tags
    on_boot                     = each.value.on_boot
    startup_order               = each.value.startup_order
    startup_up_delay            = each.value.startup_up_delay
    startup_down_delay          = each.value.startup_down_delay
    agent_enabled               = each.value.agent_enabled
    cpu_cores                   = each.value.cpu_cores
    cpu_type                    = each.value.cpu_type
    memory_dedicated            = each.value.memory_dedicated
    memory_floating             = each.value.memory_floating
    disk_datastore_id           = each.value.disk_datastore_id
    disk_interface              = each.value.disk_interface
    initialization_datastore_id = each.value.initialization_datastore_id
    ipv4_address                = each.value.ipv4_address
    username                    = each.value.username
    bridge                      = each.value.bridge
  }
}
