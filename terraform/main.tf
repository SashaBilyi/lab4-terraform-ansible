terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "worker" {
  count     = 1
  name      = "worker-vm"
  image     = "./ubuntu-jammy.box"
  cpus      = 2
  memory    = "1.0 gib"
  user_data = file("${path.module}/cloud_init.yml")

  network_adapter {
    type = "nat"
  }
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "db" {
  count      = 1
  name       = "db-vm"
  image      = "./ubuntu-jammy.box"
  cpus       = 1
  memory     = "1.0 gib"
  user_data  = file("${path.module}/cloud_init.yml")
  depends_on = [virtualbox_vm.worker]

  network_adapter {
    type = "nat"
  }
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

output "worker_ip" {
  value = virtualbox_vm.worker[0].network_adapter[1].ipv4_address
}

output "db_ip" {
  value = virtualbox_vm.db[0].network_adapter[1].ipv4_address
}