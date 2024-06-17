resource "vsphere_resource_pool" "cluster_api_provider_vsphere" {
  name                    = "cluster-api-provider-vsphere"
  parent_resource_pool_id = vsphere_resource_pool.prow.id
}

resource "vsphere_resource_pool" "cluster_api_provider_vsphere_project" {
  count = var.nr_cluster_api_provider_projects

  name                    = "${format("%03d", count.index + 1)}"
  parent_resource_pool_id = "${vsphere_resource_pool.cluster_api_provider_vsphere.id}"
}

resource "vsphere_folder" "cluster_api_provider_vsphere" {
  path          = "${vsphere_folder.prow.path}/cluster-api-provider-vsphere"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_folder" "cluster_api_provider_vsphere_project" {
  count = var.nr_cluster_api_provider_projects

  path          = "${vsphere_folder.cluster_api_provider_vsphere.path}/${format("%03d", count.index + 1)}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_entity_permissions" "cluster_api_provider_vsphere_resource_pools" {
  entity_id = vsphere_resource_pool.cluster_api_provider_vsphere.id
  entity_type = "ResourcePool"
  permissions {
    user_or_group = "ldap.local\\prow-cluster-api-provider-vsphere-users"
    propagate = true
    is_group = true
    role_id = data.vsphere_role.capv_ci.id
  }
}

resource "vsphere_entity_permissions" "cluster_api_provider_vsphere_folders" {
  entity_id = vsphere_folder.cluster_api_provider_vsphere.id
  entity_type = "Folder"
  permissions {
    user_or_group = "ldap.local\\prow-cluster-api-provider-vsphere-users"
    propagate = true
    is_group = true
    role_id = data.vsphere_role.capv_ci.id
  }
}
