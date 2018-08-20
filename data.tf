#
# data source used to read the custom image id
#
data "azurerm_image" "custom-image" {
  name                = "${var.custom-image-name}"
  resource_group_name = "${var.custom-image-resource-group}"
}

data "azurerm_storage_account" "core-storage-account" {
  name                = "qatfstate"
  resource_group_name = "${var.custom-image-resource-group}"
}