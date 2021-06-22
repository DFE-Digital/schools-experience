resource "statuscake_test" "alert" {
  for_each = var.alerts

  website_name   = each.value.website_name
  website_url    = each.value.website_url
  test_type      = each.value.test_type
  check_rate     = each.value.check_rate
  contact_group  = each.value.contact_group
  trigger_rate   = each.value.trigger_rate
  confirmations  = each.value.confirmations
  node_locations = each.value.node_locations
  test_tags      = ["SE"]
}
