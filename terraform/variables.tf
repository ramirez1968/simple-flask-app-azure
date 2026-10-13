variable "subscription_id" {
  description = "Azure subscription ID (set it in terraform.tfvars, which is gitignored)"
  type        = string
}

variable "location" {
  description = "Azure region for everything"
  type        = string
  default     = "westus2"
}

variable "project_name" {
  description = "Used as the resource group name and as a naming prefix"
  type        = string
  default     = "simple-flask-app-azure"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.101.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "aks_vm_size" {
  description = "Worker VM size. Check availability in your region and subscription before applying."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_node_count" {
  type    = number
  default = 1
}
