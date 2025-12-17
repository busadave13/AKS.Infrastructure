# Project Brief: AKS.Infrastructure

## Project Overview
Terraform Infrastructure as Code (IaC) project for deploying an Azure Kubernetes Service (AKS) cluster optimized for microservices development.

## Target Audience
Small development team (1-2 developers) working on containerized applications in a single Azure region.

## Primary Goals
1. **Developer Productivity** - Fully functional Kubernetes environment for rapid development
2. **Cost Optimization** - Minimize infrastructure costs while maintaining capabilities
3. **Security by Default** - Foundational security controls for development
4. **Full Observability** - Comprehensive monitoring, logging, and metrics
5. **GitOps Ready** - Automated deployments via Flux v2
6. **Infrastructure as Code** - All infrastructure managed through Terraform

## Technology Stack
- **Cloud Platform**: Microsoft Azure
- **Container Orchestration**: Azure Kubernetes Service (AKS)
- **Infrastructure as Code**: Terraform
- **GitOps**: Flux v2
- **CI/CD**: GitHub Actions
- **Monitoring**: Azure Monitor, Managed Prometheus, Managed Grafana
- **Container Registry**: Azure Container Registry (Basic)
- **Secrets Management**: Azure Key Vault

## Key Design Decisions
| Decision | Rationale |
|----------|-----------|
| Public AKS cluster | Simplifies development access; secured via Azure RBAC |
| Burstable VM SKUs (B2ms) | Cost-effective for variable dev workloads |
| Spot instances for workloads | 60-90% cost savings on non-critical dev workloads |
| No NAT Gateway | Load balancer egress sufficient for dev |
| No DDoS Protection | Not required for development environment |
| Azure CNI Overlay | Better IP management, sufficient for dev scale |
| Separate GitOps Repository | Independent versioning for Kubernetes manifests |
| GitHub Actions CI/CD | Native OIDC support, simpler setup than Azure DevOps |

## Repository Structure
```
AKS.Infrastructure/
├── .clinerules/           # Cline rules and memory bank
├── .docs/                 # Architecture documentation
├── .github/
│   └── workflows/         # GitHub Actions workflows
│       └── terraform.yml  # Terraform CI/CD pipeline
└── terraform/
    ├── environments/      # Environment-specific configurations
    │   └── dev/
    ├── modules/           # Reusable Terraform modules
    │   ├── aks/
    │   ├── acr/
    │   ├── gitops/
    │   ├── keyvault/
    │   ├── monitoring/
    │   └── networking/
    └── shared/            # Shared provider configurations
```

## Related Repositories
- **AKS.GitOps** (separate repository) - Kubernetes manifests and Flux configurations
