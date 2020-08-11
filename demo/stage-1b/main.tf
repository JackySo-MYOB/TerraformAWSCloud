provider "aws" {
  version = "> 2"
  region = "ap-southeast-2"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################


######
# Launch configuration and autoscaling group
######
module "example" {
  source = "../../../terraform-modules/terraform-aws-autoscaling/"


  # Launch configuration
  #
  # create_lc = false # disables creation of launch configuration
  name = "legacy-migration-demo-stage-1b"
  create_lc = true
  lc_name = "legacy-migration-demo-stage-1b-LaunchConfiguration"

  image_id                     = "ami-058b6b582383f8f50"
  instance_type                = "t2.medium"
  security_groups              = ["sg-01cb188ef5d3dbc26"]
  associate_public_ip_address  = false
  iam_instance_profile        = "snowball-lab-development"
  recreate_asg_when_lc_changes = true
  enable_monitoring            = false
  ebs_optimized                = false
  load_balancers  = [module.elb.this_elb_id]
  key_name 		       = "development-server"

  user_data = "${file("install_java.sh")}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvda"
      volume_type           = "gp2"
      volume_size           = "10"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "legacy-migration-demo-stage-1b-AutoscalingGroup"
  vpc_zone_identifier       = ["subnet-03d0a34b583ae3caa", "subnet-066ba03492efdea43", "subnet-079008974dc167e7c"]
  health_check_type         = "ELB"
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0


  tags = [
    {
        key   = "Name"
        value = "legacy-migration-demo-stage-1b"
        propagate_at_launch = true
    },
    {
        key   = "Description"
        value = "Demo - tomcat server with ELB"
        propagate_at_launch = true
    }
  ]

}

######
# ELB
######
module "elb" {
  source = "../../../terraform-modules/terraform-aws-elb"

  name = "demo-stage-1b-elb"

  subnets         = ["subnet-0ceb3b86e2b2baa70", "subnet-0d4d7ba1cbcaa45ef", "subnet-053f754bf9f8b4ae1"]
  security_groups = ["sg-01cb188ef5d3dbc26"]
  internal        = false

  listener = [
    {
      instance_port     = "8080"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:8080/profile/jackys"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

}

