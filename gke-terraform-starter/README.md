# GKE Terraform sandbox starter

This starter provisions a regional GKE Standard cluster in a **dedicated sandbox GCP project**:
- Custom VPC and subnet with Pod and Service secondary ranges
- Cloud Router and Cloud NAT for private-node outbound access
- Regional GKE Standard cluster with private nodes
- Managed node pool with autoscaling, auto-repair, and auto-upgrade
- Workload Identity and basic system/workload logging

## Before running

1. Confirm with the project owner that this is a dedicated test project and confirm the target region.
2. Check that the CIDR ranges do not overlap with connected networks or existing networks.
3. Confirm permissions and billing are enabled.
4. Authenticate with an approved identity, preferably company SSO or service-account impersonation. Do not put service-account keys in source control.
5. Review estimated costs. GKE, worker VMs, NAT, logging, and related resources may incur charges.
6. This starter uses local Terraform state by default. Do not use local state for shared/team or production use. Set up an access-controlled GCS state bucket separately and configure the `backend "gcs"` block before team use. Backend bucket creation should be a separate bootstrap step.

## Initialize and validate

From the `terraform/` directory:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set the actual sandbox project ID.

gcloud auth login
gcloud config set project REPLACE_WITH_SANDBOX_PROJECT_ID
gcloud auth application-default login

terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
```

Review the plan carefully. Only continue if it targets the intended sandbox project and contains expected changes:

```bash
terraform apply tfplan
```

Configure kubectl and verify the cluster:

```bash
gcloud container clusters get-credentials command-sandbox-gke \
  --region me-central2 \
  --project REPLACE_WITH_SANDBOX_PROJECT_ID

kubectl get nodes
kubectl get namespaces
```

Use the actual values from your `terraform.tfvars` if they differ from the examples.

## Destroy test resources

Only after confirming the active project and reviewing the destroy plan:

```bash
gcloud config get-value project
terraform plan -destroy -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
```

Do not run destroy against production or a shared project. The API services are configured not to be disabled when Terraform is destroyed.

## Important hardening before production

This is a sandbox baseline, not a production-ready design. Before production use, agree on:
- GCS remote state, versioning, IAM, and state locking
- Private control-plane endpoint or approved control-plane access restrictions
- Least-privilege node and Terraform identities
- Organization policy, audit logging, alerting, budgets, and security controls
- Workload-specific secrets management (for example, Secret Manager)
- Backup/recovery requirements, upgrade windows, capacity, and cost targets
- CI plan review and protected apply approvals

The Google provider may propose changes as versions evolve. Pin and test provider versions according to team standards.
