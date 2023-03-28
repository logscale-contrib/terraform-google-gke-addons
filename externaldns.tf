module "edns_sa" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project_id
  prefix        = var.cluster_name
  names         = ["edns"]
  project_roles = ["${var.project_id}=>roles/dns.admin"]
  display_name  = var.cluster_name
  description   = var.cluster_name
}

resource "google_service_account_iam_binding" "edns" {
  service_account_id = module.edns_sa.service_account
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:$${${var.project_id}.svc.id.goog[external-dns/external-dns]",
  ]
}

# data "aws_route53_zone" "selected" {
#   zone_id = var.zone_id
# }


# module "irsa_edns" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name = "${var.uniqueName}_external-dns_external-dns"


#   attach_external_dns_policy    = true
#   external_dns_hosted_zone_arns = [data.aws_route53_zone.selected.arn]

#   oidc_providers = {
#     main = {
#       provider_arn               = var.eks_oidc_provider_arn
#       namespace_service_accounts = ["external-dns:external-dns"]
#     }
#   }
# }


module "release_edns" {
  source  = "terraform-module/release/helm"
  version = "2.8.0"

  namespace  = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  depends_on = [
    google_service_account_iam_binding.edns
  ]

  app = {
    name             = "cw"
    version          = "6.5.*"
    chart            = "external-dns"
    create_namespace = true
    wait             = true
    deploy           = 1
  }

  values = [<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
nodeSelector:
    iam.gke.io/gke-metadata-server-enabled: true

replicaCount: 2
serviceAccount:
  name: external-dns
txtOwnerId: "${var.cluster_name}"

EOF 
  ]
  set = [
    {
      "name"  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
      "value" = module.edns_sa.email
    }
  ]
}



