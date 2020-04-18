output "app_external_ip" {
  value = google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip
}

// used with lb.tf
//output "lb_external_ip" {
//  value = google_compute_global_address.external-address.address
//}
