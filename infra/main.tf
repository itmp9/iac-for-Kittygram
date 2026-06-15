data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_vpc_network" "kittygram" {
  name = "kittygram-network"
}

resource "yandex_vpc_subnet" "kittygram" {
  name           = "kittygram-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.kittygram.id
  v4_cidr_blocks = [var.network_cidr]
}

resource "yandex_vpc_address" "kittygram" {
  name = "kittygram-public-ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_vpc_security_group" "kittygram" {
  name       = "kittygram-security-group"
  network_id = yandex_vpc_network.kittygram.id

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Kittygram gateway"
    protocol       = "TCP"
    port           = var.gateway_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "kittygram" {
  name                      = "kittygram-vm"
  hostname                  = "kittygram"
  platform_id               = "standard-v3"
  zone                      = var.zone
  allow_stopping_for_update = true

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kittygram.id
    nat                = true
    nat_ip_address     = yandex_vpc_address.kittygram.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.kittygram.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      ssh_user       = var.ssh_user
      ssh_public_key = var.ssh_public_key
    })
  }

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}
