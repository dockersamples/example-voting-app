# Lets the CI deploy user (from terraform/bootstrap) use kubectl/helm on this cluster.
data "aws_iam_user" "github_deploy" {
  user_name = "${var.cluster_name}-github-deploy"
}

resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_user.github_deploy.arn
  type          = "STANDARD"
}

# Cluster-admin keeps the demo simple (Helm creates the namespace).
# Production would scope this to the voting-app namespace with AmazonEKSEditPolicy.
resource "aws_eks_access_policy_association" "github_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_user.github_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_deploy]
}
