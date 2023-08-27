locals {
  azs          = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  cluster_name = "assesment-eks-cluster"
  node_group   = "private-nodes"
  eks_ssh_key  = "assesment"
}
