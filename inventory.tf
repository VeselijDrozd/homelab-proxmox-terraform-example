locals {
  vm_primary_ipv4 = {
    for k, vm in module.vms : k => try(
      [
        for ip in flatten(coalesce(vm.ipv4_addresses, [])) :
        ip if startswith(ip, var.vm_output_ipv4_prefix)
      ][0],
      null
    )
  }

  inventory_group_for_key = {
    for k in keys(local.vms_expanded) :
    k => coalesce(
      try(local.vms_expanded[k].ansible_group, null),
      try(regex("^(.+)-[0-9]+$", k)[0], k)
    )
  }

  inventory_group_names = sort(distinct(values(local.inventory_group_for_key)))

  inventory_groups = {
    for group_name in local.inventory_group_names :
    group_name => [
      for k in sort([
        for key, grp in local.inventory_group_for_key :
        key if grp == group_name && local.vm_primary_ipv4[key] != null
      ]) :
      {
        name         = local.vms_expanded[k].name
        ansible_host = local.vm_primary_ipv4[k]
        ansible_user = try(local.vms_expanded[k].username, "ubuntu")
      }
    ]
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.ini.tpl", {
    ssh_private_key_file = coalesce(var.ansible_ssh_private_key_file, "")
    parent_group         = coalesce(var.ansible_inventory_parent_group, "")
    group_names          = local.inventory_group_names
    groups               = local.inventory_groups
  })
  filename = var.ansible_inventory_path
}
