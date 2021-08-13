locals {
  bin_dir = "${path.cwd}/bin"
  yaml_dir = "${path.cwd}/.tmp/pact-broker/chart/pact-broker"
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
  values_file = "values-${var.server_name}.yaml"
  name = "pact-broker"
}

resource null_resource setup_binaries {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-binaries.sh"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "$(command -v igc || command -v ${local.bin_dir}/igc) gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --valueFiles 'values.yaml,${local.values_file}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
