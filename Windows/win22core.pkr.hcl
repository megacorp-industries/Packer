variable "autounattend" {
  type    = string
  default = "./answer_files/2022_core/Autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "50000"
}

variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
}

variable "iso_url" {
  type    = string
  #default = "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  default = "./win22.iso"
}

variable "manually_download_iso_from" {
  type    = string
  default = "https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "vm_name" {
  type    = string
  default = "WindowsServer2022Core"
}

variable "virtio_win_iso" {
  type    = string
  default = "./virtio-win.iso"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

source "qemu" "win22core" {
  accelerator      = "kvm"
  boot_wait        = "0s"
  communicator     = "winrm"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend}", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1"]
  headless         = "${var.headless}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "win22-core"
  qemuargs         = [["-drive", "file=win22-core/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"], ["-drive", "file=${var.iso_url},media=cdrom,index=2"], ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"]]
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  vm_name          = "${var.vm_name}"
  winrm_password   = "changeme"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_username   = "Dedsec"
}

build {
  sources = ["source.qemu.win22core"]

  provisioner "powershell" {
    scripts = ["./scripts/debloat-windows.ps1", "./scripts/ConfigureRemotingForAnsible.ps1"]
  }
}
