variable "networks" {
  type = "list"
  default = [
    "10.180.64.0/24",
    "10.180.66.0/24",
    "10.180.76.22/32",
    "10.180.67.0/24",
    "10.180.181.0/26",
  ]
}

variable "tables" {
  type = "list"
  default = [
    "rtb-0148ddf4f22fb647d",
    "rtb-0780d90a5e49837a2",
    "rtb-0c9649c88310036a6",
  ]
}
locals {

  networks = [
    for network in var.networks : {
      cidr_block = network
    }
  ]
  tables = [
    for table in var.tables : {
      table = table
    }
  ]

  network_routes = [
    for pair in setproduct(local.networks, local.tables) : {
      cidr_block  = pair[0].cidr_block
      route_table = pair[1].table
    }
  ]


}



resource "aws_route" "routes" {

  for_each = {
    for route in local.network_routes : "${route.cidr_block}.${route.route_table}" => route
  }
  route_table_id         = each.value.route_table
  destination_cidr_block = each.value.cidr_block
  gateway_id             = "igw-9b9e22e0"
}

