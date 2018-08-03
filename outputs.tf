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