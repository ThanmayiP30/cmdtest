locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
  ])
}

resource "google_project_service" "required_apis" {
  for_each           = local.required_apis
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "gke" {
  name                     = var.subnet_name
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_router" "gke" {
  name    = "${var.cluster_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "gke" {
  name                               = "${var.cluster_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.gke.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.gke.id

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  resource_labels = var.labels

  depends_on = [
    google_project_service.required_apis,
    google_compute_subnetwork.gke,
    google_compute_router_nat.gke,
  ]
}

resource "google_container_node_pool" "primary" {
  name     = "${var.cluster_name}-nodes"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  node_count = var.node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.node_machine_type
    image_type   = "COS_CONTAINERD"

    labels = var.labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
