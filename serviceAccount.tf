resource "google_service_account" "gke_node_sa" {
  account_id   = "nayra-gke-node-sa"
  display_name = "Custom Service Account for GKE Nodes"
}

resource "google_project_iam_member" "gke_node_sa_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader" ,
    "roles/container.developer"

  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}