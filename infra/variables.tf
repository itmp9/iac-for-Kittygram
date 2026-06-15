variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
  default     = "b1gqa7ukktg6ukk8vdbh"
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "network_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "image_family" {
  description = "VM image family"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "ssh_user" {
  description = "VM user for deploys"
  type        = string
  default     = "kittygram"
}

variable "ssh_public_key" {
  description = "SSH public key for the VM user"
  type        = string
  sensitive   = true
}

variable "gateway_port" {
  description = "Public gateway port"
  type        = number
  default     = 9000
}

variable "vm_cores" {
  description = "VM CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "VM memory in GB"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "VM boot disk size in GB"
  type        = number
  default     = 20
}
