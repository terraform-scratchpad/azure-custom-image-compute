#
# data source used to read the custom image id
#
data "azurerm_image" "custom-image" {
  resource_group_name = "${var.custom-image-resource-group}"
  name_regex          = "^elasticsearch6-\\d{4,4}-\\d{2,2}-\\d{2,2}T\\d{6,6}"
  sort_descending     = true
}