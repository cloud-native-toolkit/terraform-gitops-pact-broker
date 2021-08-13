module "gitops_pactbroker" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  namespace = module.gitops_namespace.name
  cluster_ingress_hostname = module.dev_cluster.platform.ingress
  cluster_type             = module.dev_cluster.platform.type_code
  tls_secret_name          = module.dev_cluster.platform.tls_secret
  server_name = module.gitops.server_name
}
