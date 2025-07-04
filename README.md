# EKS Workshop Terraform

AWS EKS 클러스터와 VPC를 자동으로 프로비저닝하는 Terraform 코드입니다.

## 주요 기능

- **자동 VPC 생성**: 3개 AZ에 퍼블릭/프라이빗 서브넷 자동 배치
- **EKS 클러스터**: 관리형 노드 그룹과 함께 완전 관리형 Kubernetes 클러스터
- **Karpenter 준비**: 자동 스케일링을 위한 서브넷 태그 및 권한 사전 구성
- **하이브리드 노드 지원**: 온프레미스 노드 연결을 위한 네트워크 구성
- **향상된 네트워킹**: VPC-CNI 프리픽스 위임 및 네트워크 정책 지원

## 아키텍처

```
VPC (10.42.0.0/16)
├── 퍼블릭 서브넷 (3개 AZ)
│   ├── 10.42.0.0/19
│   ├── 10.42.32.0/19
│   └── 10.42.64.0/19
└── 프라이빗 서브넷 (3개 AZ)
    ├── 10.42.96.0/19
    ├── 10.42.128.0/19
    └── 10.42.160.0/19
```

## 사전 요구사항

- Terraform >= 1.4.2
- AWS CLI 설정 및 적절한 IAM 권한
- AWS Provider >= 4.67.0

## 사용법

### 1. 클론 및 초기화

```bash
git clone https://github.com/sangminpark9/eks-infra-HCL-v2.git
cd eks-infra-HCL-v2
terraform init
```

### 2. 변수 설정 (선택사항)

```bash
# terraform.tfvars 파일 생성
cluster_name = "my-eks-cluster"
cluster_version = "1.31"
vpc_cidr = "10.42.0.0/16"
```

### 3. 배포

```bash
terraform plan
terraform apply
```

### 4. kubeconfig 설정

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `cluster_name` | EKS 클러스터 이름 | `eks-workshop` |
| `cluster_version` | EKS 클러스터 버전 | `1.31` |
| `ami_release_version` | 노드 그룹 AMI 릴리스 버전 | `1.31.3-20250103` |
| `vpc_cidr` | VPC CIDR 블록 | `10.42.0.0/16` |
| `remote_network_cidr` | 하이브리드 노드 네트워크 CIDR | `10.52.0.0/16` |
| `remote_pod_cidr` | 하이브리드 Pod 네트워크 CIDR | `10.53.0.0/16` |

## 파일 구조

```
.
├── providers.tf      # AWS 프로바이더 설정
├── variables.tf      # 변수 정의
├── main.tf          # 공통 태그 정의
├── vpc.tf           # VPC 및 네트워킹 리소스
└── eks.tf           # EKS 클러스터 및 노드 그룹
```

## 생성되는 리소스

### VPC 리소스
- VPC
- 퍼블릭 서브넷 (3개)
- 프라이빗 서브넷 (3개)
- 인터넷 게이트웨이
- NAT 게이트웨이
- 라우팅 테이블

### EKS 리소스
- EKS 클러스터
- 관리형 노드 그룹 (3-6개 노드)
- 필수 애드온 (VPC-CNI)
- IAM 역할 및 정책
- 보안 그룹

## 주요 특징

### 네트워크 최적화
- **프리픽스 위임**: ENI당 더 많은 IP 주소 할당
- **Pod ENI**: Pod가 직접 ENI를 가져 네트워크 성능 향상
- **네트워크 정책**: Kubernetes 네트워크 정책 지원

### 비용 효율성
- **단일 NAT 게이트웨이**: 개발 환경에 적합한 비용 절약
- **적절한 인스턴스 타입**: m5.large로 균형잡힌 성능

### 확장성
- **Karpenter 준비**: 자동 스케일링을 위한 태그 사전 구성
- **하이브리드 지원**: 온프레미스 노드 연결 가능
