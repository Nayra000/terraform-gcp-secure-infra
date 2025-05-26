resource "google_compute_network" "vpc" {
  name                    = "nayra-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

#Hosts the private VM and NAT gateway
resource "google_compute_subnetwork" "management_subnet" {
  name          = "nayra-management-subnet"
  ip_cidr_range = "10.0.15.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

#Purpose: Hosts the private GKE cluster.
resource "google_compute_subnetwork" "restricted_subnet" {
  name                     = "nayra-restricted-subnet"
  ip_cidr_range            = "10.0.16.0/24"
  region                   =  var.region
  network                  =  google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.3.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.4.0.0/20"
  }
}

resource "google_compute_router" "router" {
  name    = "nayra-management-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nayra-management-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"  # Auto-assign NAT IPs
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  
  subnetwork {
    name                    = google_compute_subnetwork.management_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]  # NAT all traffic
  }
}