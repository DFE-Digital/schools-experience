data "cloudfoundry_domain" "cloudapps" {
  name = "london.cloudapps.digital"
}

data "cloudfoundry_domain" "internal" {
  name = "apps.internal"
}

data "cloudfoundry_domain" "internet" {
  name = "education.gov.uk"
}
