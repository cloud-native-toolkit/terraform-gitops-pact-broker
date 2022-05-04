
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.gitops_pactbroker.name
        branch      = module.gitops_pactbroker.branch
        namespace   = module.gitops_pactbroker.namespace
        server_name = module.gitops_pactbroker.server_name
        layer       = module.gitops_pactbroker.layer
        layer_dir   = module.gitops_pactbroker.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_pactbroker.layer == "services" ? "2-services" : "3-applications")
        type        = module.gitops_pactbroker.type
      })
    }
  }
}
