#
# outputs
#
output "vm-public-ip" {
  value = "${azurerm_public_ip.public-ip.ip_address}"
}

output "vm-admin-username" {
  value = "${random_string.vm-username.result}"
}

output "vm-admin-password" {
  value = "${random_string.vm-password.result}"
}