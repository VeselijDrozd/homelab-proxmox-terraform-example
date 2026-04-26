# homelab-proxmox-terraform-example

Пример Terraform-проекта для создания ВМ в Proxmox через внешний модуль:

- модуль: [VeselijDrozd/terraform-proxmox-vm-module](https://github.com/VeselijDrozd/terraform-proxmox-vm-module)
- source в проекте: `git::https://github.com/VeselijDrozd/terraform-proxmox-vm-module.git?ref=1.0.0`

## Что делает проект

- скачивает образы в datastore Proxmox (`proxmox_download_file`)
- создает ВМ из:
  - одиночных описаний в `vms`
  - групповых описаний в `vm_groups` + `count`
- разворачивает группы в плоский список ВМ и передает каждую ВМ в модуль

## Требования

- Terraform `>= 1.3`
- доступ к Proxmox API
- провайдер `bpg/proxmox`

## Быстрый старт

1. Создайте рабочий файл переменных:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Заполните минимум:
- `endpoint`
- `proxmox_username`
- `main_password`
- `vm_pass`
- `pc_public_key_path`

3. Запуск:

```bash
terraform init
terraform plan
terraform apply
```

## Структура конфигурации

### `images`

Карта образов, которые будут загружены в Proxmox:

- `datastore_id` - куда скачивать
- `node_name` - узел Proxmox
- `url` - URL cloud image
- `file_name` - имя файла в datastore
- `content_type` - опционально (`import` по умолчанию)

Пример:

```hcl
images = {
  ubuntu_jammy = {
    datastore_id = "local"
    node_name    = "pve"
    url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    file_name    = "jammy-server-cloudimg-amd64.qcow2"
  }
}
```

### `vms` (одиночные ВМ)

`vms` — карта, где каждый ключ это отдельная ВМ с индивидуальными параметрами.

Обязательные поля:
- `image_key`, `vm_id`, `name`, `node_name`
- `disk_datastore_id`, `initialization_datastore_id`, `bridge`

Часто используемые опциональные:
- `cpu_cores`, `memory_dedicated`, `memory_floating`
- `tags`, `agent_enabled`, `ipv4_address`, `username`

Пример:

```hcl
vms = {
  monitor = {
    image_key                   = "ubuntu_jammy"
    vm_id                       = 4500
    name                        = "monitor-vm"
    node_name                   = "pve"
    cpu_cores                   = 2
    memory_dedicated            = 2048
    memory_floating             = 2048
    disk_datastore_id           = "local-zfs"
    initialization_datastore_id = "local-zfs"
    bridge                      = "vmbr0"
    tags                        = ["terraform", "monitoring"]
  }
}
```

### `vm_groups` (группы ВМ)

`vm_groups` — шаблон для создания N однотипных ВМ.

Поля группы:
- `count` - количество ВМ
- `vm_id_start` - стартовый VMID (дальше автоинкремент)
- `name_prefix` - префикс имени (`app-vm-01`, `app-vm-02`, ...)
- `config` - общие параметры ВМ (почти те же поля, что в `vms`, кроме `vm_id` и `name`)

Пример:

```hcl
vm_groups = {
  app = {
    count       = 3
    vm_id_start = 4301
    name_prefix = "app-vm"
    config = {
      image_key                   = "ubuntu_jammy"
      node_name                   = "pve"
      agent_enabled               = true
      disk_datastore_id           = "local-zfs"
      initialization_datastore_id = "local-zfs"
      bridge                      = "vmbr0"
      tags                        = ["terraform", "app"]
    }
  }
}
```

### Приоритет `vm_groups` и `vms`

Сначала разворачиваются `vm_groups`, затем мержатся с `vms`.
Если ключ совпадает, запись из `vms` перезапишет сгенерированную групповую.

## Outputs

- `vm_ids` - map VMID по ключам ВМ
- `vm_names` - map имен ВМ по ключам

## Файлы проекта

- `providers.tf` - провайдер и авторизация Proxmox
- `variables.tf` - все входные переменные и типы
- `main.tf` - загрузка образов + вызов внешнего модуля
- `outputs.tf` - итоговые значения
- `terraform.tfvars.example` - безопасный шаблон переменных

## Безопасность

- не коммитьте реальные секреты в `terraform.tfvars`
- не храните ключи/пароли в shell-скриптах в репозитории
- убедитесь, что `.gitignore` исключает `*.tfvars`, state-файлы и локальные креды
