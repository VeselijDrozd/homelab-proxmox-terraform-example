output "vm_ids" {
  description = "IDs of created VMs by key"
  value       = { for k, vm in module.vms : k => vm.id }
}

output "vm_names" {
  description = "Names of created VMs by key"
  value       = { for k, vm in module.vms : k => vm.name }
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses from QEMU guest agent per VM (nested list: one inner list per NIC)"
  value       = { for k, vm in module.vms : k => vm.ipv4_addresses }
}

output "vm_ipv4_primary" {
  description = "First IPv4 from guest agent per VM key (null until agent reports or if none)"
  value = {
    for k, vm in module.vms : k => (
      length(flatten(coalesce(vm.ipv4_addresses, []))) > 0
      ? flatten(vm.ipv4_addresses)[0]
      : null
    )
  }
}
