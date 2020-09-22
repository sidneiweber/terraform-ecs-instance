environment = "dev"
name = "webserver"
cidr = "10.1.0.0/16"
keypair = "terraform"
private_subnets = [
  "10.1.1.0/24",
  "10.1.2.0/24",
]
public_subnets = [
  "10.1.11.0/24",
  "10.1.12.0/24",
]