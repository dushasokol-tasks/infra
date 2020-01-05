variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west3"
}

variable zone {
  description = "Zone"
  default     = "europe-west3-c"
}

variable "app-instances-count" {
  default = "1"
}

variable public_key_path {
  description = "Path to ssh public key"
}

variable private_key_path {
  description = "Path to ssh private key"
}

variable disk_image {
  description = "Disk image"
}

variable app_user {
  default = "appuser"
}
