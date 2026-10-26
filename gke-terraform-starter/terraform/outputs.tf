output "project_id" {
  description = "GCP project containing the sandbox cluster."
  value       = var.project_id
}

output "cluster_name" {
  description = "Created GKE cluster name."
  value       = google_container_cluster.primary.name
}

output "cluster_region" {
  description = "Region hosting the regional GKE cluster."
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "GKE control-plane endpoint. Treat as infrastructure metadata."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.vpc.name
}

output "get_credentials_command" {
  description = "Command to configure kubectl for this cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.location} --project ${var.project_id}"
}
