# AWS 프로바이더 설정 및 모든 리소스에 공통 태그 적용
provider "aws" {
  default_tags {
    tags = local.tags
  }
}

# Terraform에서 요구하는 최소 버전과 provider 버전 정의
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }

  required_version = ">= 1.4.2"
}
