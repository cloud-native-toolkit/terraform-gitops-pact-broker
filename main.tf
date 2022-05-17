locals {
  bin_dir  = module.setup_clis.bin_dir
  yaml_dir = "${path.cwd}/.tmp/pact-broker/chart/pact-broker"
  ingress_host  = "pact-broker-${var.namespace}.${var.cluster_ingress_hostname}"
  database_type = "sqlite"
  database_name = "pactbroker.sqlite"
  service_name  = "pact-broker"
  ingress_url   = "https://${local.ingress_host}"
  service_url  = "http://${local.service_name}.${var.namespace}"
  type  = "base"
  application_branch = "main"
  values_content = {
    pact-broker = {
      ingress = {
        enabled = false
      }
      route = {
        enabled = true
      }
      database = {
        type = local.database_type
        name = local.database_name
      }
    }
    tool-config = {
      name = "pact-broker"
      privateUrl = local.service_url
    }
    ocp-route       = {
      nameOverride = "pact-broker"
      targetPort = "http"
      app = "pact-broker"
      serviceName = local.service_name
      termination = "edge"
      insecurePolicy = "Redirect"
      consoleLink = {
        enabled = true
        section = "Cloud-Native Toolkit"
        displayName = "Pact Broker"
        imageUrl = "data:image/png;base64,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"
      }
    }
  }
  values_server_content = {
    global = {
      clusterType = var.cluster_type
      ingressSubdomain = var.cluster_ingress_hostname
      tlsSecretName = var.tls_secret_name
    }
    pact-broker = {
      ingress = {
        enabled = var.cluster_type == "kubernetes"
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
        enabled = var.cluster_type == "kubernetes"
      }
    }
  }

  layer = "services"
  values_file = "values-${var.server_name}.yaml"
  name = "pact-broker"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
      VALUES_SERVER_CONTENT = yamlencode(local.values_server_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

