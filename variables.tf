# EKS 클러스터 이름
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-workshop"
}

# 클러스터 버전
variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.31"
}

# 관리형 노드 그룹에 사용할 AMI 릴리스 버전
variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.31.3-20250103"
}

# 생성할 VPC의 CIDR 블록
variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.42.0.0/16"
}

# 하이브리드 노드에서 접근할 수 있도록 허용할 원격 노드 네트워크 CIDR
variable "remote_network_cidr" {
  description = "Defines the remote CIDR blocks used on Amazon VPC created for Amazon EKS Hybrid Nodes."
  type        = string
  default     = "10.52.0.0/16"
}

# 하이브리드 환경의 Pod에서 접근할 수 있도록 허용할 CIDR
variable "remote_pod_cidr" {
  description = "Defines the remote CIDR blocks used on Amazon VPC created for Amazon EKS Hybrid Nodes."
  type        = string
  default     = "10.53.0.0/16"
}
