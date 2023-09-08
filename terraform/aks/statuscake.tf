module "statuscake" {
  for_each = var.statuscake_alerts

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = each.value.website_url
  contact_groups = each.value.contact_group
}
