# 공통 태그 정의 (모든 리소스에 자동 적용됨)
locals {
  tags = {
    created-by = "eks-workshop-v2"
    env        = var.cluster_name
  }
}
