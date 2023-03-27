module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "24.1.0"
  project_id   = var.project_id
  location     = var.location
  cluster_name = var.cluster_name
}
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_auth.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_auth.ca_certificate)
}
