locals {
  capacity      = "mundose"
  functionality = "pin2"

  resource_tags = {
    capacity      = local.capacity
    functionality = local.functionality
    terraform     = "true"
    environment   = "dev"
  }
}

locals {
  vpc_id    = "vpc-02fe81f1f7effa35b"
  subnet_id = "subnet-0e016bf7fe6a285a1"
}

locals {
  keypair_name = "key-${local.capacity}-${local.functionality}"
  security_group_name = "${local.capacity}-${local.functionality}"
  ec2_instance_name   = "ec2-${local.capacity}-instance-${local.functionality}"
}