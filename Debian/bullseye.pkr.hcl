variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "disk_size" {
  type    = string
  default = "50000"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:e482910626b30f9a7de9b0cc142c3d4a079fbfa96110083be1d0b473671ce08d"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
}

variable "memsize" {
  type    = string
  default = "1024"
}

variable "numvcpus" {
  type    = string
  default = "1"
}

variable "ssh_password" {
  type    = string
  default = "packer"
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "vm_name" {
  type    = string
  default = "bullseye"
}

variable "vm_version" {
  type    = string
  default = "0.1"
}

source "qemu" "bullseye" {
  accelerator            = "kvm"
  boot_command           = ["<esc><wait1>auto preseed/url=http://{{ .HTTPIP  }}:{{ .HTTPPort  }}/preseed.cfg<enter>"]
  boot_wait              = "3s"
  disk_cache             = "none"
  disk_compression       = true
  disk_discard           = "ignore"
  disk_interface         = "virtio"
  disk_size              = var.disk_size
  format                 = "qcow2"
  headless               = true
  host_port_max          = 2229
  host_port_min          = 2222
  http_directory         = "http"
  http_port_max          = 10089
  http_port_min          = 10082
  iso_checksum           = var.iso_checksum
  iso_url                = var.iso_url
  net_device             = "virtio-net"
  output_directory       = "qemu-artifacts/${var.vm_name}_${var.vm_version}"
  qemu_binary            = "/usr/bin/qemu-system-x86_64"
  qemuargs               = [["-m", "${var.memsize}M"], ["-smp", "${var.numvcpus}"]]
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "4h"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "4h"
}

source "hyperv-iso" "bullseye" {
  boot_command           = ["<esc><wait1>auto preseed/url=http://{{ .HTTPIP  }}:{{ .HTTPPort  }}/preseed.cfg<enter>"]
  boot_wait             = "3s"
  communicator          = "ssh"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  http_directory        = "http"
  iso_checksum          = var.iso_checksum
  iso_url               = var.iso_url
  memory                = var.memsize
  cpus                  = var.numvcpus
  output_directory      = "hyperv-artifacts/${var.vm_name}_${var.vm_version}"
  shutdown_command      = "echo 'password' | sudo -S shutdown -P now"
  shutdown_timeout      = "30m"
  ssh_password          = var.ssh_password
  ssh_timeout           = "4h"
  ssh_username          = var.ssh_username
  vm_name               = var.vm_name
}

build {
  sources = ["source.qemu.bullseye", "source.hyperv-iso.bullseye"]

  provisioner "shell" {
    execute_command = "echo 'packer'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/prerequisites.sh"]
  }
  
  provisioner "ansible-local" {
    staging_directory       = "/tmp/ansible"
    galaxy_roles_path       = "/tmp/ansible/roles"
    clean_staging_directory = true
    playbook_dir            = "ansible"
    playbook_file           = "ansible/local-playbook.yml"
    galaxy_file             = "ansible/requirements.yml"
  }

  provisioner "shell" {
    execute_command = "echo 'packer'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/cleanup.sh"]
  }
}
