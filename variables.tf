variable "location" {
  description = "geographical location"
}

variable "resource_group_name" {
  description = "main resource group"
}

variable vm_flavor {
  description = "virtual machine size (flavor)"
}

variable custom-image-id {
  description = "custom image id"
}

variable custom-image-resource-group {
  description = "Resource group where the custom image is associated and stored"
}

variable "subnet_id" {
  description = "subnet id controlling vm private address space and nsg"
}

variable "nsg_id" {
  description = "NSG created by core infrastrucutre template"
}

variable "tags" {
  type = "map"
  description = "tags to identify the VM"
}

#
# data disk
#
variable disk_size_gb {
  default = "50"
}