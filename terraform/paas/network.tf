data "cloudfoundry_app" "prometheus" {
    name_or_id = var.paas_monitoring_app
    space      = data.cloudfoundry_space.monitoring.id
}

data "cloudfoundry_app" "monitor_delayed" {
  count      = length(cloudfoundry_app.delayed_jobs) > 0 ? 1 : 0
  name_or_id = cloudfoundry_app.delayed_jobs.id
  space      = data.cloudfoundry_space.space.id

  depends_on = [cloudfoundry_app.delayed_jobs ]
}


data "cloudfoundry_app" "monitor_apps" {

  name_or_id = cloudfoundry_app.application.id
  space      = data.cloudfoundry_space.space.id

  depends_on = [ cloudfoundry_app.application ]
}


resource "cloudfoundry_network_policy" "monitoring-policy-app" {

    policy {
        source_app = data.cloudfoundry_app.prometheus.id
        destination_app = data.cloudfoundry_app.monitor_apps.id
        port = "3000"
        protocol = "tcp"
    }
}

resource "cloudfoundry_network_policy" "monitoring-policy-del" {

    count      = length( data.cloudfoundry_app.monitor_delayed  ) == 0 ? 0 : 1
    policy {
        source_app = data.cloudfoundry_app.prometheus.id
        destination_app = data.cloudfoundry_app.monitor_delayed[0].id
        port = "3000"
        protocol = "tcp"
    }
}
