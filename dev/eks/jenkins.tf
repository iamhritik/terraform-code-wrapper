data "aws_security_group" "controlplane_sg" {
  tags = {
    "aws:eks:cluster-name" = var.cluster_name
  }
  depends_on = [
    module.dev_eks_cluster
  ]
}

#Jenkins SG to communicate with eks cluster
resource "aws_security_group_rule" "jenkins_add" {
  security_group_id        = data.aws_security_group.controlplane_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "sg-001d4d01d818ed07f" #specify SG ID that you used to connect with kubernetes API server
  depends_on = [
    module.dev_eks_cluster,
    data.aws_security_group.controlplane_sg
  ]
}