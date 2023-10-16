variable "tags" {
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default = {
    ProjectName  = "ABCD testing"
    ProjectOwner = "inder"
    deployedBy   = "terraform"
  }

}


variable "management_sub_id" {
  default = "d5e707fe-59d0-4717-b6f3-fc64a467833d"
  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.management_sub_id)) || var.management_sub_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "vmName" {
  type        = string
  description = "Name of the Virtual Machine."
  default     = "dnsproxy"
}

variable "adminUsername" {
  type        = string
  description = "User name for the Virtual Machine."
  default = "adminuser"
}

variable "storageAccountName" {
  type        = string
  description = "The name of the storage account for diagnostics. Storage account names must be globally unique."
  default = "teststorage"
}

variable "forwardIP" {
  type        = string
  description = "This is the IP address to forward DNS queries to. The default value represents Azure's internal DNS recursive resolvers."
  default     = "168.63.129.16"
}

variable "location" {
  type        = string
  description = "Location for all resources."
  default     = "uksouth"
}

variable "authenticationType" {
  type        = string
  description = "Type of authentication to use on the Virtual Machine. SSH key is recommended."
  default     = "password"
  #allowed_values = ["sshPublicKey", "password"]
}

variable "adminPassword" {
  type        = string
  description = "SSH Key or password for the Virtual Machine. SSH key is recommended."
}

variable "vmSize" {
  type        = string
  description = "Virtual machine size"
  default     = "Standard_A1_v2"
}

variable "ubuntuOSVersion" {
  type    = string
  default = "18.04-LTS"
}

variable "asetName" {
  type    = string
  default = "dnsproxy-avail"
}

variable "nsgName" {
  type    = string
  default = "dnsproxy-nsg"
}

variable "vnetName" {
  type    = string
  default = "dnsproxy-vnet"
}

variable "vnetAddressPrefix" {
  type    = string
  default = "10.0.0.0/8"
}

variable "subnet1Name" {
  type    = string
  default = "subnet1"
}

variable "subnet_id" {
  default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myrg/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/mysubnet"
}

variable "nicName" {
  default = "config"
}
variable "rg_name" {
  type    = string
  default = "test-rg"
}

variable "pipName" {
    type = string
    default = "Pip-test"
}

variable "scriptUrl" {
    default = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/demos/dns-forwarder/forwarderSetup.sh"
}