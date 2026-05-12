terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

# S3-compatible object storage volume for MinIO
# MinIO will be deployed via Docker/Ansible on the app server
resource "hcloud_volume" "object_storage" {
  name     = "${var.environment}-object-storage"
  size     = var.storage_size
  location = var.location
  format   = "ext4"

  labels = {
    environment = var.environment
    role        = "storage"
    encrypted   = "true"
  }
}

output "storage_volume_id" {
  value = hcloud_volume.object_storage.id
}

output "storage_volume_name" {
  value = hcloud_volume.object_storage.name
}
