module "statuscake" {
  for_each = var.statuscake_alerts

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = each.value.website_url
  ssl_urls       = each.value.ssl_url
  contact_groups = each.value.contact_groups
  content_matchers  = try(each.value.content_matchers, [])
}
