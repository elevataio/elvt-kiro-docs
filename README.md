# Kiro Enterprise — AWS Deployment Guide & Samples

Everything your team needs to deploy and configure Kiro with AWS backend services. From zero to production-ready in under 30 minutes.

---

## What's in This Repo

```
Kiro-docs/
├── README.md                        ← You are here
├── kiro-aws-guide.md                # Complete guide (English)
├── kiro-aws-guide.docx              # Same guide as Word document
├── kiro-aws-guide-pt-br.md          # Complete guide (Portuguese-BR)
├── kiro-aws-guide-pt-br.docx        # Same guide as Word document (PT-BR)
├── cloudformation/
│   ├── kiro-enterprise-setup.yaml   # CloudFormation template (validated)
│   ├── deploy.sh                    # Interactive guided deployment script
│   └── README.md                    # CloudFormation-specific documentation
└── samples/
    ├── README.md                    # Steering samples documentation
    └── .kiro/steering/              # 13 production-ready steering files
        ├── 01-project-overview.md
        ├── 02-coding-standards.md
        ├── 03-aws-security-baseline.md
        ├── 04-cdk-infrastructure.md
        ├── 05-api-design.md
        ├── 06-dynamodb-patterns.md
        ├── 07-deployment-pipeline.md
        ├── 08-forbidden-patterns.md
        ├── 09-testing-strategy.md
        ├── 10-monitoring-observability.md
        ├── 11-lambda-handler-guide.md    (conditional: Lambda files)
        ├── 12-cdk-construct-guide.md     (conditional: CDK files)
        └── 13-openapi-reference.md       (manual inclusion)
```

---

## Quick Start

### 1. Read the Guide

Start with the comprehensive guide that covers all Kiro features and AWS integration:

- **English**: [kiro-aws-guide.md](./kiro-aws-guide.md)
- **Portugues-BR**: [kiro-aws-guide-pt-br.md](./kiro-aws-guide-pt-br.md)

### 2. Deploy Infrastructure (One-Click)

Provision all AWS resources needed for Kiro Enterprise:

```bash
cd cloudformation/
chmod +x deploy.sh
./deploy.sh
```

This creates: S3 buckets for logging, KMS encryption, IAM roles, CloudTrail audit, and budget alarms.

### 3. Copy Steering Samples

Add production-ready steering files to your project:

```bash
cp -r samples/.kiro/ /path/to/your/project/.kiro/
```

Then customize the files to match your team's conventions.

---

## Who Is This For

| Audience | Start Here |
|----------|-----------|
| **Non-technical decision-makers** | Read the guide (sections 1-2) for overview and billing |
| **IT Administrators** | CloudFormation template + guide sections on governance |
| **Developers** | Steering file samples + guide sections on hooks and specs |
| **Security/Compliance teams** | Guide section on enterprise governance + CloudTrail setup |

---

## What's Covered

| Topic | Description |
|-------|-------------|
| **Getting Started** | Prerequisites, billing setup, IAM Identity Center configuration |
| **Steering Files** | Teaching Kiro your project conventions (with 13 working samples) |
| **Hooks** | Automating workflows with event-triggered actions |
| **Specs** | Structured development: Requirements → Design → Tasks |
| **MCP Servers** | Extending Kiro with AWS Documentation, CDK, and CloudWatch servers |
| **Bedrock Integration** | Using Kiro with Amazon Bedrock and AgentCore |
| **Infrastructure as Code** | Building AWS resources with CDK using Kiro's cloud-architect power |
| **Enterprise Governance** | Permissions, model control, MCP allow-lists, identity providers |
| **CloudFormation Deploy** | One-click infrastructure with S3 logging, KMS, CloudTrail |

---

## Prerequisites

- **AWS Account** with a valid payment method (credit card required for enterprise billing)
- **AWS CLI v2** installed and configured
- **IAM Identity Center** enabled with at least one admin group and one developer group
- **Kiro** installed from [kiro.dev](https://kiro.dev/docs/getting-started/installation/)

---

## CloudFormation Template — What It Deploys

| Resource | Purpose |
|----------|---------|
| IAM Admin Role | Manage Kiro profiles, subscriptions, governance |
| IAM Developer Policy | Read-only access for developers |
| S3 Bucket (Prompt Logs) | User prompts + Kiro responses for compliance |
| S3 Bucket (Activity Reports) | Daily CSV usage telemetry per user |
| S3 Bucket (CloudTrail) | Audit trail of all Kiro API calls |
| KMS Key | Customer-managed encryption for all log buckets |
| CloudTrail Trail | Who did what, when (API-level audit) |
| CloudWatch Alarm | Budget alert for Kiro spending |
| Permission Boundary | Controls which subscription tiers can be created |

**Estimated infrastructure cost**: ~$3-10/month (Kiro subscriptions billed separately).

---

## Steering File Samples

The `samples/` folder contains 13 production-ready steering files for an AWS serverless backend project. They demonstrate:

- **Always-on steering** (files 01-10): loaded every session
- **Conditional steering** (files 11-12): activated only when editing matching files
- **Manual steering** (file 13): available on-demand via `#` in chat

Copy them, customize them, commit them with your project.

---

## Contributing

1. Fork this repo
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## Useful Links

| Resource | URL |
|----------|-----|
| Kiro Documentation | [kiro.dev/docs](https://kiro.dev/docs/) |
| Kiro Downloads | [kiro.dev/downloads](https://kiro.dev/downloads/) |
| Kiro Pricing | [kiro.dev/pricing](https://kiro.dev/pricing/) |
| AWS CDK Best Practices | [docs.aws.amazon.com](https://docs.aws.amazon.com/cdk/latest/guide/best-practices.html) |
| IAM Identity Center | [docs.aws.amazon.com](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) |

---

*Last updated: August 2026*
