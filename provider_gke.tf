module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "24.1.0"
  project_id   = var.project_id
  location     = var.region
  cluster_name = var.cluster_name
}
data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_auth.host}"
    token                  = module.gke_auth.token
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  }
}

# provider "kubernetes" {
#   host                   = "https://${module.gke_auth.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = module.gke_auth.ca_certificate
# }
