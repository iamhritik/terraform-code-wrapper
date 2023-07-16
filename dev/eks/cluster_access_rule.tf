data "aws_security_group" "controlplane_sg" {
  tags = {
    "aws:eks:cluster-name" = var.cluster_name
  }
  depends_on = [
    module.dev_eks_cluster
  ]
}

#Jenkins SG to communicate with eks cluster
resource "aws_security_group_rule" "cluster_access" {
  security_group_id        = data.aws_security_group.controlplane_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.cluster_access_sg #specify SG ID that you used to connect with kubernetes API server
  depends_on = [
    module.dev_eks_cluster,
    data.aws_security_group.controlplane_sg
  ]
}