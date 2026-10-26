variable "project_id" {
  description = "ID of the dedicated GCP sandbox project."
  type        = string
}

variable "region" {
  description = "GCP region for the regional GKE cluster."
  type        = string
  default     = "me-central2"
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
  default     = "command-sandbox-gke"
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "command-sandbox-vpc"
}

variable "subnet_name" {
  description = "Name of the GKE subnet."
  type        = string
  default     = "command-sandbox-subnet"
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR range."
  type        = string
  default     = "10.20.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE Pods."
  type        = string
  default     = "10.24.0.0/14"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE Services."
  type        = string
  default     = "10.28.0.0/20"
}

variable "master_ipv4_cidr_block" {
  description = "Small, non-overlapping CIDR range for the GKE control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_machine_type" {
  description = "Machine type for each GKE worker node."
  type        = string
  default     = "e2-standard-2"
}

variable "node_count" {
  description = "Initial number of nodes per node-pool location."
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum nodes per node-pool location."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes per node-pool location."
  type        = number
  default     = 3
}

variable "labels" {
  description = "Labels applied to GCP resources where supported."
  type        = map(string)
  default = {
    application = "command"
    environment = "sandbox"
    managed_by  = "terraform"
  }
}
