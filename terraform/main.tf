terraform {
  required_version = "0.11.11"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app-${count.index + 1}"
  machine_type = "g1-small"

  # zone         = "europe-west3-c"
  zone = "${var.zone}"

  count = "${var.app-instances-count}"



  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  tags = ["reddit-app"]

  metadata {
     ssh-keys = "${var.app_user}:${file(var.public_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }


   provisioner "remote-exec" {
     script = "files/deploy.sh"
   }

  connection {
    type = "ssh"
    user = "${var.app_user}"

    # user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_project_metadata_item" "app" {
  key   = "ssh-keys"
  value = "${chomp(file(var.public_key_path))}\n"
}

