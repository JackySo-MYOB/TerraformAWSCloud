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
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  name = "legacy-migration-demo-legacy"
  create_lc = true
  lc_name = "legacy-migration-demo-legacy-LaunchConfiguration"

  image_id                     = "ami-058b6b582383f8f50"
  instance_type                = "t2.medium"
  security_groups              = ["sg-01cb188ef5d3dbc26"]
  associate_public_ip_address  = true
  iam_instance_profile         = "snowball-lab-development"
  recreate_asg_when_lc_changes = true
  enable_monitoring            = false
  ebs_optimized                = false
  key_name 		       = "development-server"

  user_data = "${file("install_legacy.sh")}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvda"
      volume_type           = "gp2"
      volume_size           = "20"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size           = "20"
      volume_type           = "gp2"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "legacy-migration-demo-legacy-AutoscalingGroup"
  # vpc_zone_identifier       = ["subnet-0ceb3b86e2b2baa70", "subnet-0d4d7ba1cbcaa45ef", "subnet-053f754bf9f8b4ae1"]
  # Removing other subnets for capable to keep running in single AZ and same private IP
  vpc_zone_identifier       = ["subnet-0ceb3b86e2b2baa70"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0


  tags = [
    {
        key   = "Name"
        value = "legacy-migration-demo-legacy"
        propagate_at_launch = true
    },
    {
        key   = "Description"
        value = "Demo - all-in-one legacy server"
        propagate_at_launch = true
    }
  ]

}
