locals {
  # 하이브리드 노드 및 Pod 접근용 CIDR을 지역 변수로 설정
  remote_node_cidr = var.remote_network_cidr
  remote_pod_cidr  = var.remote_pod_cidr
}

# EKS 클러스터 생성
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = true
  # 현재 사용자에 클러스터 admin 권한 부여
  enable_cluster_creator_admin_permissions = true

  # CNI 애드온 구성
  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          # Pod가 ENI 직접 가짐
          ENABLE_POD_ENI                    = "true"
          # ENI당 더 많은 IP 가능
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        # 네트워크 정책 지원
        enableNetworkPolicy = "true"
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # 보안 그룹을 모듈 외부에서 직접 설정할 수 있게끔 관리하지 않음
  create_cluster_security_group = false
  create_node_security_group    = false

  # 클러스터용 보안 그룹에 하이브리드 CIDR 허용
  cluster_security_group_additional_rules = {
    hybrid-node = {
      cidr_blocks = [local.remote_node_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }

    hybrid-pod = {
      cidr_blocks = [local.remote_pod_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }
  
  # 노드 그룹 보안 그룹에 동일한 CIDR 허용
  node_security_group_additional_rules = {
    hybrid_node_rule = {
      cidr_blocks = [local.remote_node_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
    
    hybrid_pod_rule = {
      cidr_blocks = [local.remote_pod_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  # 하이브리드 네트워크 설정
  cluster_remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    # Required if running webhooks on Hybrid nodes
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  # 관리형 노드 그룹 구성
  eks_managed_node_groups = {
    default = {
      # 노드 인스턴스 타입
      instance_types           = ["m5.large"]
      # 강제로 새 버전 적용
      force_update_version     = true
      # AMI 릴리스 지정
      release_version          = var.ami_release_version
      # 이름 prefix 사용 안 함
      use_name_prefix          = false

      iam_role_name            = "${var.cluster_name}-ng-default"
      iam_role_use_name_prefix = false

      min_size     = 3
      max_size     = 6
      desired_size = 3

      update_config = {
        # 롤링 업데이트 중 최대 중단 비율
        max_unavailable_percentage = 50
      }

      labels = {
        workshop-default = "yes"
      }
    }
  }

  # 전체 리소스에 공통 태그 적용
  tags = merge(local.tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })
}
