locals {
  chart_dir = "${path.cwd}/.tmp/pact-broker/chart/pact-broker"
  ingress_host  = "pact-broker-${var.namespace}.${var.cluster_ingress_hostname}"
  database_type = "sqlite"
  database_name = "pactbroker.sqlite"
  ingress_url   = "https://${local.ingress_host}"
  service_url  = "http://pact-broker.${var.namespace}"
  values_content = {
    pact-broker = {
      ingress = {
        enabled = var.cluster_type == "kubernetes" ? true : false
        hosts = [{
          host = local.ingress_host
        }]
        tls = [{
          secretName = var.tls_secret_name
          hosts = [
            local.ingress_host
          ]
        }]
      }
      route = {
        enabled = var.cluster_type == "kubernetes" ? false : true
      }
      database = {
        type = local.database_type
        name = local.database_name
      }
    }
    tool-config = {
      name = "pactbroker"
      url = local.ingress_url
      privateUrl = local.service_url
      applicationMenu = false
      ingressSubdomain = var.cluster_ingress_hostname
      displayName = "Pact Broker"
    }
  }
  layer = "services"
  application_branch = "main"
  layer_config = var.gitops_config[local.layer]
}

resource null_resource setup_chart {
  provisioner "local-exec" {
    command = "mkdir -p ${local.chart_dir} && cp -R ${path.module}/chart/pact-broker/* ${local.chart_dir} && echo '${yamlencode(local.values_content)}' > ${local.chart_dir}/values.yaml"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.setup_chart]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh 'pact-broker' '${local.chart_dir}' 'pact-broker' '${local.application_branch}' '${var.namespace}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}
