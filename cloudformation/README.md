# Kiro Enterprise — CloudFormation Deployment

One-click infrastructure setup for Kiro Enterprise on AWS.

## What This Deploys

| Resource | Purpose |
|----------|---------|
| **IAM Admin Role** | Manage Kiro profiles, subscriptions, and governance |
| **IAM Developer Policy** | Read-only access for developers |
| **S3 Bucket (Prompt Logs)** | Stores user prompts and Kiro responses |
| **S3 Bucket (Activity Reports)** | Daily CSV usage telemetry |
| **S3 Bucket (CloudTrail)** | Audit trail of all Kiro API calls |
| **KMS Key** | Encryption for all log buckets |
| **CloudTrail Trail** | Records who did what, when |
| **CloudWatch Alarm** | Budget alert for Kiro spending |
| **Permission Boundary** | Budget control on subscription tiers |

## Prerequisites

1. **AWS Account** with a valid payment method (credit card)
2. **AWS CLI v2** installed and configured (`aws configure`)
3. **IAM Identity Center** enabled in your account with at least one group created
4. **Sufficient IAM permissions** to create CloudFormation stacks, IAM roles, S3 buckets, KMS keys

## Quick Start

```bash
# Clone the repo
git clone <your-repo-url>
cd Kiro-docs/cloudformation

# Run the guided deployment
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Validate your AWS credentials and the template
2. Prompt you for all configuration values (interactive)
3. Deploy the CloudFormation stack
4. Verify all resources were created
5. Print next steps to complete in the AWS Console

## Manual Deployment (AWS Console)

If you prefer the AWS Console:

1. Go to **CloudFormation** > **Create Stack** > **Upload a template file**
2. Upload `kiro-enterprise-setup.yaml`
3. Fill in the parameters (the console groups them by category)
4. Check "I acknowledge that AWS CloudFormation might create IAM resources with custom names"
5. Click **Create Stack**

## Manual Deployment (AWS CLI)

```bash
aws cloudformation deploy \
  --template-file kiro-enterprise-setup.yaml \
  --stack-name myorg-kiro-enterprise-production \
  --region us-east-1 \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    OrganizationName=myorg \
    Environment=production \
    AwsRegion=us-east-1 \
    IdentityCenterInstanceArn=arn:aws:sso:::instance/ssoins-XXXXXXXXX \
    IdentityCenterRegion=us-east-1 \
    KiroAdminGroupId=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee \
    KiroDeveloperGroupId=ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj \
    DefaultSubscriptionTier=Pro \
    MaxSubscriptions=50 \
    EnablePromptLogging=true \
    EnableUserActivityReports=true \
    LogRetentionDays=90 \
    EnableCloudTrail=true \
    EnableKmsEncryption=true
```

## After Deployment

The CloudFormation stack creates the infrastructure. You still need to complete setup in the Kiro Console:

1. Navigate to **Kiro Console** in AWS
2. Click **Onboard your team to Kiro**
3. Select **IAM Identity Center** as identity source
4. Create a **Kiro Profile**
5. Add your developer group with the chosen subscription tier
6. Enable **Prompt Logging** → point to the S3 bucket created by this stack
7. Enable **User Activity Reports** → point to the activity bucket
8. Note the **Sign-in URL** and share with your team

## Parameters Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| OrganizationName | Company name (lowercase) | `acme-corp` |
| Environment | Target env | `production` |
| AwsRegion | Kiro region | `us-east-1` |
| IdentityCenterInstanceArn | IAM IdC ARN | `arn:aws:sso:::instance/ssoins-abc123` |
| IdentityCenterRegion | IdC region | `us-east-1` |
| KiroAdminGroupId | Admin group UUID | `a1b2c3d4-...` |
| KiroDeveloperGroupId | Dev group UUID | `e5f6g7h8-...` |
| DefaultSubscriptionTier | Plan for users | `Pro` |
| MaxSubscriptions | Budget cap | `50` |
| EnablePromptLogging | Log prompts | `true` |
| EnableUserActivityReports | Daily CSV | `true` |
| LogRetentionDays | Keep logs | `90` |
| EnableCloudTrail | Audit trail | `true` |
| EnableKmsEncryption | KMS for logs | `true` |

## Cleanup

To remove all resources:

```bash
# Empty S3 buckets first (required before deletion)
aws s3 rm s3://myorg-kiro-prompt-logs-production-123456789012 --recursive
aws s3 rm s3://myorg-kiro-activity-reports-production-123456789012 --recursive
aws s3 rm s3://myorg-kiro-cloudtrail-production-123456789012 --recursive

# Delete the stack
aws cloudformation delete-stack --stack-name myorg-kiro-enterprise-production --region us-east-1
```

> **Note**: S3 buckets with `DeletionPolicy: Retain` will NOT be deleted by CloudFormation. This is intentional to prevent data loss. Empty and delete them manually if needed.

## Cost Estimate

| Resource | Approximate Cost |
|----------|-----------------|
| KMS Key | $1/month + $0.03 per 10,000 requests |
| S3 Storage | ~$0.023/GB/month (Standard) |
| CloudTrail | First trail free, $2 per 100,000 events |
| CloudWatch Alarm | $0.10/month |
| **Total infrastructure** | **~$3-10/month** (varies by usage) |

Kiro subscription costs are separate and billed per-user per-month based on tier.