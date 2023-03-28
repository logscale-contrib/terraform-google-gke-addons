


resource "helm_release" "cert-manager" {
  depends_on = [
    helm_release.promcrds,
  ]
  namespace        = "cert-manager"
  create_namespace = true

  name       = "cw"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.11.*"


  values = [<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists

    
installCRDs: true

replicaCount: 2
webhook:
  replicaCount: 2
cainjector:
  replicaCount: 2
serviceAccount:
  create: true
  name: cw-cert-manager

admissionWebhooks:
  certManager:
    enabled: true

prometheus:
  enabled: true
  servicemonitor:
    enabled: true

webhook:
    securePort: 8443
EOF 
  ]

}
