output "vm_ids" {
  description = "IDs of created VMs by key"
  value       = { for k, vm in module.vms : k => vm.id }
}

output "vm_names" {
  description = "Names of created VMs by key"
  value       = { for k, vm in module.vms : k => vm.name }
}
