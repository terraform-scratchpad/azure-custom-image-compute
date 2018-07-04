provider "azurerm" {
  version = ">=1.8.0"
}

provider "random" {
  version = "1.3.1"
}

#
# data source used to read the custom image id
#
data "azurerm_image" "custom-image" {
  name                = "${var.custom-image-name}"
  resource_group_name = "${var.custom-image-resource-group}"
}

#
# storage account
#
resource "azurerm_storage_account" "storage-account" {
  name                      = "tfstorageaccount${count.index}"
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.location}"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
}

#
# public ip
#
resource "azurerm_public_ip" "public-ip" {
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  name                          = "staging-pip-${count.index}"
  public_ip_address_allocation  = "Dynamic"
}

#
# data disk
#
resource "azurerm_managed_disk" "data-disk" {
  name                  = "stg-datadisk-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  disk_size_gb          = "50"
}

# network interface
resource "azurerm_network_interface" "network-interface" {
  name                            = "nic-${count.index}"
  location                        = "${var.location}"
  resource_group_name             = "${var.resource_group_name}"

  ip_configuration {
    name                          = "public-ip-cfg-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public-ip.id}"
  }
}

# generate random username and password
resource "random_string" "vm-username" {
  length = 10
  special = false
  upper = false
}

resource "random_string" "vm-password" {
  length = 16
  special = true
  override_special = "/@\" "
}

# vm
resource "azurerm_virtual_machine" "vm" {
  name                              = "vm-${count.index}"
  location                          = "${var.location}"
  resource_group_name               = "${var.resource_group_name}"
  network_interface_ids             = ["${azurerm_network_interface.network-interface.id}"]
  vm_size                           = "${var.vm_flavor}"
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

  storage_image_reference {
    id="${data.azurerm_image.custom-image.id}"
  }

  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.data-disk.name}"
    managed_disk_id = "${azurerm_managed_disk.data-disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.data-disk.disk_size_gb}"
  }

  os_profile {
    computer_name   = "dummy"
    admin_username  = "${random_string.vm-username.id}"
    admin_password  = "${random_string.vm-password.id}"
  }

  boot_diagnostics {
    enabled = true
    storage_uri = "${azurerm_storage_account.storage-account.primary_blob_endpoint}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#
# outputs
#
output "vm-public-ip" {
  value = "${azurerm_public_ip.public-ip.ip_address}"
}

output "vm-admin-username" {
  value = "${azurerm_virtual_machine.vm.os_profile.admin_username}"
}

output "vm-admin-password" {
  value = "${azurerm_virtual_machine.vm.os_profile.admin_password}"
}