# thanks for https://github.com/terraform-providers/terraform-provider-google-beta/blob/master/examples/endpoints-on-compute-engine/main.tf
resource "google_compute_global_address" "external-address" {
  name = "tf-external-address"
}

resource "google_compute_instance_group" "www-resources" {
  name      = "tf-www-resources"
  zone      = var.vm_zone
  instances = google_compute_instance.app[*].self_link
  named_port {
    name = "http"
    port = 9292
  }
}

resource "google_compute_health_check" "health-check" {
  name = "tf-health-check"

  http_health_check {
    port_name = "http"
    port      = 9292
  }
}

resource "google_compute_backend_service" "www-service" {
  name     = "tf-www-service"
  protocol = "HTTP"

  backend {
    group = google_compute_instance_group.www-resources.self_link
  }

  health_checks = [google_compute_health_check.health-check.self_link]
}

resource "google_compute_url_map" "web-map" {
  name            = "tf-web-map"
  default_service = google_compute_backend_service.www-service.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "tf-allpaths"
  }

  path_matcher {
    name            = "tf-allpaths"
    default_service = google_compute_backend_service.www-service.self_link
  }
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "tf-http-lb-proxy"
  url_map = google_compute_url_map.web-map.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "tf-http-content-gfr"
  target     = google_compute_target_http_proxy.http-lb-proxy.self_link
  ip_address = google_compute_global_address.external-address.address

  port_range = "80"
}
