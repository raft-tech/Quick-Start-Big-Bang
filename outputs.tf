output "istio_gw_ip" {
  description = "DEPRECATED - Kept for backwards compatibility reasons, will be removed later. Returns the IP of the first LoadBalancer found in the istio-system namespace"
  value = jsondecode(module.big_bang.external_load_balancer)[0].ip
}
