variable "autounattend" {
  type    = string
  default = "./answer_files/2022_core/Autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "50000"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
}

variable "memsize" {
  type    = string
  default = "4096"
}

variable "numvcpus" {
  type    = string
  default = "2"
}

variable "virtio_win_iso" {
  type    = string
  default = "./virtio-win.iso"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

variable "winrm_username" {
  type    = string
  default = "Packer"
}

variable "winrm_password" {
  type    = string
  default = "Packer"
}

variable "vm_name" {
  type    = string
  default = "WindowsServer2022Core"
}

variable "vm_version" {
  type    = string
  default = "0.1"
}

source "qemu" "win22core" {
  accelerator      = "kvm"
  boot_wait        = "0s"
  communicator     = "winrm"
  cpus             = var.numvcpus
  disk_size        = var.disk_size
  floppy_files     = ["${var.autounattend}", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1"]
  headless         = true
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = var.memsize
  output_directory = "artifacts/${var.vm_name}_${var.vm_version}"
  qemuargs         = [["-drive", "file=artifacts/${var.vm_name}_${var.vm_version}/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"], ["-drive", "file=${var.iso_url},media=cdrom,index=2"], ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"]]
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  vm_name          = var.vm_name
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
}

build {
  sources = ["source.qemu.win22core"]

  provisioner "powershell" {
    scripts = ["./scripts/debloat-windows.ps1", "./scripts/ConfigureRemotingForAnsible.ps1"]
  }
}
