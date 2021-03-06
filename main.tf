#
# Create a VM from a custom image
#
provider "azurerm" {
  version = "~> 1.12.0"
}

provider "random" {
  version = "~> 1.3.0"
}

#
# public ip
#
resource "azurerm_public_ip" "public-ip" {
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  name                          = "staging-pip-${random_string.random-name-suffix.result}"
  public_ip_address_allocation  = "Dynamic"
}

#
# data disk
#
resource "azurerm_managed_disk" "data-disk" {
  name                  = "stg-datadisk-${random_string.random-name-suffix.result}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  disk_size_gb          = "${var.disk_size_gb}"
}

#
# network interface
#
resource "azurerm_network_interface" "network-interface" {
  name                            = "nic-${random_string.random-name-suffix.result}"
  location                        = "${var.location}"
  resource_group_name             = "${var.resource_group_name}"
  network_security_group_id       = "${var.nsg_id}"

  ip_configuration {
    name                          = "public-ip-cfg-${random_string.random-name-suffix.result}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public-ip.id}"
  }
}

#
# core storage account
#
resource "azurerm_storage_account" "core-storage-account" {
  name                      = "corestorageacc${random_string.random-name-suffix.result}"
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.location}"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  tags                      = "${var.tags}"
}

#
# vm from custom image (see packer template)
#
resource "azurerm_virtual_machine" "vm" {
  name                              = "${var.vm_name_is_random == "1" ? random_string.random-name-suffix.result : var.vm_name}"
  location                          = "${var.location}"
  resource_group_name               = "${var.resource_group_name}"
  network_interface_ids             = ["${azurerm_network_interface.network-interface.id}"]
  vm_size                           = "${var.vm_flavor}"
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

  storage_image_reference {
    id="${var.custom-image-id}"
  }

  storage_os_disk {
    name              = "myosdisk-${random_string.random-name-suffix.result}"
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
    computer_name   = "qa-${random_string.random-name-suffix.result}"
    admin_username  = "${random_string.vm-username.result}"
    # admin_password  = "${random_string.vm-password.result}"
    admin_password  = "${random_string.vm-password.result}"
  }



  boot_diagnostics {
    enabled = true
    storage_uri = "${azurerm_storage_account.core-storage-account.primary_blob_endpoint}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

  }

  tags = "${var.tags}"
}