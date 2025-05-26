resource "google_compute_instance" "private_vm" {
  name         = "nayra-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.management_subnet.id
  }

  service_account {
    email  = google_service_account.gke_node_sa.email
    scopes = ["cloud-platform"]
  }

  tags = ["private-vm"]
}