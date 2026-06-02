---
name: full-infrastructure-as-code
description: Manage infrastructure as code with Terraform, Pulumi, or CloudFormation. Use when provisioning cloud resources, managing environments, or implementing GitOps.
---

# Full Infrastructure as Code

## When to Use

- Provisioning cloud resources
- Managing multiple environments
- Implementing GitOps
- Automating infrastructure

## Input

- Infrastructure requirements
- Cloud provider
- Environment specifications

## Output

- IaC templates
- Environment configurations
- Deployment pipelines
- Documentation

## Checklist

1. **Tool Selection**
   - Terraform: multi-cloud, HCL
   - Pulumi: programming languages
   - CloudFormation: AWS-only
   - Consider: team skills, cloud provider

2. **Resource Definition**
   - Define VPC/networking
   - Configure compute (ECS, EKS, Lambda)
   - Set up databases
   - Configure storage

3. **State Management**
   - Remote state storage
   - State locking
   - State encryption
   - Backup strategy

4. **Security**
   - Least privilege IAM
   - Secrets management
   - Network security
   - Encryption at rest/transit

## Best Practices

- Use modules for reuse
- Implement state locking
- Use variables for configuration
- Tag all resources
- Implement drift detection
- Version control everything
- Test with plan before apply

## Anti-Patterns

❌ Manual infrastructure changes
❌ Storing state locally
❌ No tagging strategy
❌ Hardcoded values
❌ No backup of state
❌ Applying without plan

## Validation

- Plan shows expected changes
- Apply succeeds
- Resources are tagged
- Security best practices followed
- State is backed up

## Examples

### Example 1: Terraform AWS Infrastructure
```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "ecs" {
  source = "./modules/ecs"
  
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  container_image = var.container_image
}

module "rds" {
  source = "./modules/rds"
  
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.database_subnet_ids
}
```

### Example 2: Terraform Module
```hcl
# modules/ecs/main.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.environment}-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  
  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.app_port
  }
}

# modules/ecs/variables.tf
variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "container_image" {
  type = string
}

variable "app_count" {
  type    = number
  default = 2
}

# modules/ecs/outputs.tf
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}
```

### Example 3: Pulumi (TypeScript)
```typescript
// infrastructure/index.ts
import * as aws from '@pulumi/aws';
import * as pulumi from '@pulumi/pulumi';

const config = new pulumi.Config();
const environment = config.require('environment');

// VPC
const vpc = new aws.ec2.Vpc(`${environment}-vpc`, {
  cidrBlock: '10.0.0.0/16',
  enableDnsHostnames: true,
  tags: { Name: `${environment}-vpc`, Environment: environment },
});

// ECS Cluster
const cluster = new aws.ecs.Cluster(`${environment}-cluster`, {
  settings: [{ name: 'containerInsights', value: 'enabled' }],
  tags: { Environment: environment },
});

// ECS Service
const service = new aws.ecs.Service(`${environment}-service`, {
  cluster: cluster.arn,
  desiredCount: 2,
  launchType: 'FARGATE',
  taskDefinition: taskDefinition.arn,
  networkConfiguration: {
    subnets: privateSubnets.ids,
    securityGroups: [securityGroup.id],
    assignPublicIp: false,
  },
});

export const vpcId = vpc.id;
export const clusterName = cluster.name;
export const serviceName = service.name;
```

### Example 4: Environment Configuration
```yaml
# environments/prod.yaml
environment: production
aws_region: us-east-1
vpc_cidr: "10.0.0.0/16"

ecs:
  app_count: 3
  cpu: 512
  memory: 1024

rds:
  instance_class: db.t3.medium
  multi_az: true
  backup_retention: 7

tags:
  Project: my-app
  Environment: production
  ManagedBy: terraform
```

## IaC Tools Comparison

| Tool | Language | Cloud | State |
|------|----------|-------|-------|
| Terraform | HCL | Multi | Remote |
| Pulumi | TS/Python/Go | Multi | Remote |
| CloudFormation | YAML/JSON | AWS | Managed |
| CDK | TS/Python | AWS | Managed |

## Output Structure

```
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ecs/
│   │   └── rds/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── main.tf
├── pulumi/
│   ├── index.ts
│   ├── Pulumi.yaml
│   └── Pulumi.prod.yaml
└── docs/
    └── infrastructure.md
```
