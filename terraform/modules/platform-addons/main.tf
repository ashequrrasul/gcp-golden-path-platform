locals {
  monitoring_namespace = "monitoring"
  logging_namespace    = "logging"
  argocd_namespace     = "argocd"
  istio_namespace      = "istio-system"

  monitoring_manifests = [
    yamldecode(file("${var.repo_root}/platform/monitoring/ecommerce-dashboard.yaml")),
    yamldecode(file("${var.repo_root}/platform/monitoring/ecommerce-prometheus-rules.yaml")),
    yamldecode(file("${var.repo_root}/platform/monitoring/istio-sidecar-podmonitor.yaml")),
  ]

  istio_manifests = [
    yamldecode(file("${var.repo_root}/platform/istio/golden-path-namespace-label.yaml")),
    yamldecode(file("${var.repo_root}/platform/istio/peer-authentication.yaml")),
    yamldecode(file("${var.repo_root}/platform/istio/destination-rule-product-service.yaml")),
    yamldecode(file("${var.repo_root}/platform/istio/destination-rule-cart-payment-service.yaml")),
    yamldecode(file("${var.repo_root}/platform/istio/destination-rule-order-service.yaml")),
    yamldecode(file("${var.repo_root}/platform/istio/telemetry.yaml")),
  ]

  argocd_applications = [
    yamldecode(file("${var.repo_root}/argocd/applications/product-service.yaml")),
    yamldecode(file("${var.repo_root}/argocd/applications/frontend.yaml")),
    yamldecode(file("${var.repo_root}/argocd/applications/cart-payment-service.yaml")),
    yamldecode(file("${var.repo_root}/argocd/applications/order-service.yaml")),
  ]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.monitoring_namespace
  }
}

resource "kubernetes_namespace" "logging" {
  count = var.install_logging ? 1 : 0

  metadata {
    name = local.logging_namespace
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.argocd_namespace
  }
}

resource "kubernetes_namespace" "istio_system" {
  count = var.install_istio ? 1 : 0

  metadata {
    name = local.istio_namespace
  }
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    admin-user     = var.grafana_admin_user
    admin-password = var.grafana_admin_password
  }

  type = "Opaque"
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  wait       = true
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = true

  values = [
    file("${var.repo_root}/platform/monitoring/kube-prometheus-stack-values.yaml")
  ]

  depends_on = [kubernetes_secret.grafana_admin]
}

resource "helm_release" "loki" {
  count = var.install_logging ? 1 : 0

  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.logging[0].metadata[0].name
  wait       = true

  values = [
    file("${var.repo_root}/platform/logging/loki-values.yaml")
  ]
}

resource "helm_release" "promtail" {
  count = var.install_logging ? 1 : 0

  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = kubernetes_namespace.logging[0].metadata[0].name
  wait       = true

  values = [
    file("${var.repo_root}/platform/logging/promtail-values.yaml")
  ]

  depends_on = [helm_release.loki]
}

resource "helm_release" "istio_base" {
  count = var.install_istio ? 1 : 0

  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  wait       = true
}

resource "helm_release" "istiod" {
  count = var.install_istio ? 1 : 0

  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  wait       = true

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingressgateway" {
  count = var.install_istio ? 1 : 0

  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  wait       = true

  depends_on = [helm_release.istiod]
}

resource "kubectl_manifest" "monitoring_extras" {
  for_each = {
    for manifest in local.monitoring_manifests :
    "${manifest.kind}/${try(manifest.metadata.namespace, "_cluster")}/${manifest.metadata.name}" => manifest
  }

  yaml_body = yamlencode(each.value)

  depends_on = [helm_release.kube_prometheus_stack]
}

resource "kubectl_manifest" "istio_config" {
  for_each = {
    for manifest in local.istio_manifests :
    "${manifest.kind}/${try(manifest.metadata.namespace, "_cluster")}/${manifest.metadata.name}" => manifest
    if var.install_istio
  }

  yaml_body = yamlencode(each.value)

  depends_on = [
    helm_release.istiod,
    helm_release.istio_ingressgateway,
  ]
}

resource "kubectl_manifest" "argocd_applications" {
  for_each = {
    for manifest in local.argocd_applications :
    "${manifest.kind}/${try(manifest.metadata.namespace, "_cluster")}/${manifest.metadata.name}" => manifest
  }

  yaml_body = yamlencode(each.value)

  depends_on = [
    helm_release.argocd,
    helm_release.external_secrets,
    helm_release.kube_prometheus_stack,
    kubectl_manifest.monitoring_extras,
    kubectl_manifest.istio_config,
  ]
}
