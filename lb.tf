module "lb" {
  source                       = "../terraform/terraform/terraform-modules/loadbalancer"
  name                         = "tech-task"
  internal                     = false
  # http_action_type             = "redirect"
  # bucket_name                  = "${data.terraform_remote_state.base.lblogs_name}"
  # bucket_prefix                = "crawler"
  target_groups                = [
    { name="web", port="80" }
  ]
  skip_target_group_attachment = true
  health_check_interval        = "10"
  health_check_path            = "/"
  healthy_threshold            = "2"
  unhealthy_threshold          = "2"
  idle_timeout                 = "300"
  subnets                      = module.vpc.public_subnets
  vpc_id                       = module.vpc.vpc_id
  cidr                         = ["0.0.0.0/0"]
  tags                         = local.tags
}
