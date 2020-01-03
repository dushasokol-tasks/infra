terraform {
  required_version = "0.11.11"
}

provider "google" {
  version = "2.0.0"
  project = "brave-octane-262913"
  region  = "europe-west-3"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "europe-west3-c"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "reddit-base-1577465538"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
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
	  user = "appuser"
	  agent = false
	  private_key = "${file("~/.ssh/appuser")}"
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