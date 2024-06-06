resource "vsphere_resource_pool" "image_builder" {
  name                    = "image-builder"
  parent_resource_pool_id = vsphere_resource_pool.prow.id
}

resource "vsphere_resource_pool" "image_builder_project" {
  count = var.nr_image_builder_projects

  name                    = "${format("%03d", count.index + 1)}"
  parent_resource_pool_id = "${vsphere_resource_pool.image_builder.id}"
}

resource "vsphere_folder" "image_builder" {
  path          = "${vsphere_folder.prow.path}/image-builder"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_folder" "image_builder_project" {
  count = var.nr_image_builder_projects

  path          = "${vsphere_folder.image_builder.path}/${format("%03d", count.index + 1)}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_entity_permissions" "image_builder_resource_pools" {
  entity_id = vsphere_resource_pool.image_builder.id
  entity_type = "ResourcePool"
  permissions {
    user_or_group = "ldap.local\\prow-image-builder-users"
    propagate = true
    is_group = true
    role_id = data.vsphere_role.image_builder.id
  }
}

resource "vsphere_entity_permissions" "image_builder_folders" {
  entity_id = vsphere_folder.image_builder.id
  entity_type = "Folder"
  permissions {
    user_or_group = "ldap.local\\prow-image-builder-users"
    propagate = true
    is_group = true
    role_id = data.vsphere_role.image_builder.id
  }
}
