# Project Overview

## What This Project Is

This is a serverless backend application that provides a REST API for managing customer orders. It runs entirely on AWS using managed services.

## Tech Stack

- **Runtime**: Python 3.12
- **Infrastructure as Code**: AWS CDK (Python)
- **API Layer**: Amazon API Gateway (REST)
- **Compute**: AWS Lambda
- **Database**: Amazon DynamoDB
- **Storage**: Amazon S3
- **Authentication**: Amazon Cognito
- **Monitoring**: Amazon CloudWatch
- **CI/CD**: AWS CodePipeline via CDK Pipelines

## Project Structure

```
project-root/
├── .kiro/
│   └── steering/          # AI agent guidance
├── infra/
│   ├── app.py             # CDK app entry point
│   ├── stacks/            # CDK stack definitions
│   └── constructs/        # Reusable CDK constructs
├── src/
│   ├── lambdas/           # Lambda function handlers
│   ├── shared/            # Shared utilities (logging, validation)
│   └── models/            # Data models and schemas
├── tests/
│   ├── unit/              # Unit tests for Lambda handlers
│   ├── integration/       # Integration tests against AWS
│   └── e2e/               # End-to-end API tests
├── docs/
│   └── architecture.md    # Architecture decision records
└── requirements.txt
```

## Environments

| Environment | AWS Account | Region | Purpose |
|-------------|-------------|--------|---------|
| dev | 111111111111 | us-east-1 | Developer sandbox |
| staging | 222222222222 | us-east-1 | Pre-production validation |
| production | 333333333333 | us-east-1 | Live customer traffic |

## Key Decisions

- DynamoDB single-table design with GSIs for access patterns
- Lambda functions are independently deployable (one function per file)
- All API responses follow JSON:API format
- Deployment uses immutable infrastructure (no in-place updates)
