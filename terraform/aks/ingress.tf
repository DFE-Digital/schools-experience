resource "kubernetes_ingress_v1" "example" {
  wait_for_load_balancer = true
  metadata {
    name = "example"
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service_v1.example.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
