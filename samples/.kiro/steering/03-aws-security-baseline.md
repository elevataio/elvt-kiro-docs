# AWS Security Baseline

## IAM Policies

- **Least privilege**: every Lambda function gets its own IAM role with only the permissions it needs
- **No wildcard resources**: never use `Resource: "*"` in production policies — specify exact ARNs
- **No inline policies**: use managed policies attached to roles
- **Condition keys**: use `aws:SourceAccount` and `aws:SourceArn` conditions where possible

```python
# CDK example - CORRECT (scoped permissions)
table.grant_read_write_data(create_order_function)

# CDK example - WRONG (overly broad)
create_order_function.add_to_role_policy(
    iam.PolicyStatement(
        actions=["dynamodb:*"],
        resources=["*"]  # NEVER do this
    )
)
```

## Data Protection

### Encryption
- All S3 buckets: SSE-S3 or SSE-KMS encryption enabled
- All DynamoDB tables: encryption at rest enabled (AWS managed key minimum)
- All data in transit: TLS 1.2+ enforced
- Secrets and API keys: stored in AWS Secrets Manager, never in code or environment variables

### S3 Buckets
- Public access: blocked at bucket level (BlockPublicAccess.BLOCK_ALL)
- Versioning: enabled for data buckets
- Lifecycle policies: configure expiration for temporary files
- Access logging: enabled for audit-sensitive buckets

```python
# CDK example - secure S3 bucket
bucket = s3.Bucket(
    self, "UploadsBucket",
    encryption=s3.BucketEncryption.S3_MANAGED,
    block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
    versioned=True,
    enforce_ssl=True,
    removal_policy=RemovalPolicy.RETAIN,
    auto_delete_objects=False,
)
```

## Network Security

- Lambda functions that access databases: deploy in VPC with private subnets
- Security groups: restrict to minimum required ports and sources
- API Gateway: use WAF for rate limiting and IP filtering in production
- No resources should have public IPs unless explicitly required (ALB, CloudFront)

## Authentication & Authorization

- API Gateway protected by Cognito User Pool authorizer
- Service-to-service calls use IAM authorization
- JWT tokens validated on every request (no trust without verification)
- Token expiration: access tokens 1 hour, refresh tokens 30 days

## Secrets Management

- All secrets stored in AWS Secrets Manager
- Rotate secrets automatically where supported
- Lambda functions retrieve secrets at cold start and cache in memory
- Never commit secrets to version control (use .gitignore patterns)

```python
# Correct pattern for secrets in Lambda
import boto3
from functools import lru_cache

@lru_cache(maxsize=1)
def get_secret(secret_name: str) -> str:
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_name)
    return response["SecretString"]
```

## Monitoring & Alerting

- CloudWatch Alarms for: Lambda errors > 1%, latency p99 > 3s, DynamoDB throttling
- X-Ray tracing enabled on all Lambda functions
- CloudTrail enabled for API audit logging
- GuardDuty enabled for threat detection

## Compliance Checklist

Before any deployment to production, verify:

- [ ] No IAM policies with wildcard resources
- [ ] All S3 buckets have public access blocked
- [ ] All data stores have encryption at rest
- [ ] No secrets in code, environment variables, or logs
- [ ] Lambda functions in VPC where database access is required
- [ ] CloudWatch alarms configured for critical paths
- [ ] WAF rules active on API Gateway
