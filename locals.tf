locals {
  capacity      = "mundose"
  functionality = "pinfinal"

  resource_tags = {
    capacity      = local.capacity
    functionality = local.functionality
    terraform     = "true"
    environment   = "dev"
  }
}

locals {
  vpc_id    = "vpc-0c7b99973da428a73"
  subnet_id = "subnet-064998e47c2bed4f2"
}

locals {
  keypair_name = "key-${local.capacity}-${local.functionality}"
  security_group_name = "${local.capacity}-${local.functionality}"
  ec2_instance_name   = "ec2-${local.capacity}-instance-${local.functionality}"
}