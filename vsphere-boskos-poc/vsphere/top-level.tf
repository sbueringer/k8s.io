# FIXME
#  * We want to have 4 users for vCenter:
#    * cluster-api-provider-vsphere
#    * cloud-provider-vsphere
#    * image-builder
#    * janitor
#  * Each of these accounts should only have permissions on the 001,002, ... resourcePools and folders, so we don't accidentally delete their parent folders.

variable "vsphere_user" {
  type    = string
}

variable "vsphere_password" {
  type = string
}

variable "vsphere_server" {
  type = string
}

variable "nr_cluster_api_provider_projects" {
  type    = number
  default = 20
}

variable "nr_cloud_provider_projects" {
  type    = number
  default = 10
}

variable "nr_image_builder_projects" {
  type    = number
  default = 10
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "SDDC-Datacenter"
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = "Cluster-1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_role" "capv_ci" {
  label = "capv-ci"
}

data "vsphere_role" "image_builder" {
  label = "image-builder"
}

# Top-level

resource "vsphere_resource_pool" "prow" {
  name                    = "prow"
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_folder" "prow" {
  path          = "prow"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
