# homelab-proxmox-terraform-example

Example Terraform project for creating multiple Proxmox VMs using the published module:
`VeselijDrozd/terraform-proxmox-vm-module` (`1.0.0`).

## What this project does

- Downloads cloud images to a Proxmox datastore (`proxmox_download_file`)
- Expands VM groups into concrete VM definitions
- Creates VMs via external module source:
  - `git::https://github.com/VeselijDrozd/terraform-proxmox-vm-module.git?ref=1.0.0`

## Requirements

- Terraform >= 1.3
- Proxmox VE API access
- `bpg/proxmox` provider

## Quick start

1. Copy example vars:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Fill secrets and environment-specific values in `terraform.tfvars`:
   - `endpoint`
   - `proxmox_username`
   - `main_password`
   - `vm_pass`
   - `pc_public_key_path`

3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Repository structure

- `providers.tf` - provider configuration
- `variables.tf` - input variables
- `main.tf` - image downloads + module invocation
- `outputs.tf` - resulting VM ids and names
- `terraform.tfvars.example` - safe configuration example

## Security notes

- Real credentials must never be committed.
- `terraform.tfvars`, state files, and local credential scripts are ignored by `.gitignore`.
