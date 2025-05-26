resource "google_container_cluster" "private_cluster" {
  name               = "nayra-private-gke-cluster"
  location           = var.zone
  initial_node_count = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.restricted_subnet.name

   deletion_protection = false

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block = "172.16.0.0/28"
    master_global_access_config {
      enabled = true
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = google_compute_subnetwork.management_subnet.ip_cidr_range
      display_name = "nayra-authorized-network"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.restricted_subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.restricted_subnet.secondary_ip_range[1].range_name
  }

  node_config {
    machine_type    = "e2-small"
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["gke-node"]
    
    # Ensure no external IP
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  depends_on = [
    google_project_iam_member.gke_node_sa_permissions
  ]
}
