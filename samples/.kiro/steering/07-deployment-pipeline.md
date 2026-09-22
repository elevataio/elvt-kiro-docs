# Deployment Pipeline

## Pipeline Strategy

All deployments go through CDK Pipelines. No manual `cdk deploy` to staging or production.

## Pipeline Stages

```
Source (GitHub) → Build → Unit Tests → Synth → Deploy Dev → Integration Tests → Deploy Staging → E2E Tests → Manual Approval → Deploy Production
```

### Stage Details

| Stage | Auto-triggered | Gate |
|-------|---------------|------|
| Build + Unit Tests | Yes (on push) | Tests must pass |
| Deploy to Dev | Yes | Synth succeeds |
| Integration Tests | Yes (post-deploy) | All tests pass |
| Deploy to Staging | Yes | Integration tests pass |
| E2E Tests | Yes (post-deploy) | All tests pass |
| Deploy to Production | No | Manual approval required |

## Branch Strategy

| Branch | Deploys To | Auto-deploy |
|--------|-----------|-------------|
| `main` | Dev → Staging → Production (with approval) | Yes |
| `feature/*` | Dev only (if PR open) | No |
| `hotfix/*` | Fast-track to production (with approval) | Yes |

## CDK Pipelines Example

```python
from aws_cdk import (
    Stack,
    pipelines,
    aws_codepipeline_actions as cpactions,
)

class PipelineStack(Stack):
    def __init__(self, scope, id, stages, **kwargs):
        super().__init__(scope, id, **kwargs)

        pipeline = pipelines.CodePipeline(
            self, "Pipeline",
            pipeline_name="OrderApi-Pipeline",
            synth=pipelines.ShellStep("Synth",
                input=pipelines.CodePipelineSource.connection(
                    "org/repo", "main",
                    connection_arn="arn:aws:codestar-connections:..."
                ),
                commands=[
                    "pip install -r requirements.txt",
                    "pip install -r requirements-dev.txt",
                    "pytest tests/unit/ --cov=src --cov-fail-under=80",
                    "cd infra && cdk synth",
                ],
                primary_output_directory="infra/cdk.out",
            ),
        )

        # Dev stage
        dev_stage = pipeline.add_stage(DeployStage(self, "Dev", config=stages[0]))
        dev_stage.add_post(
            pipelines.ShellStep("IntegrationTests",
                commands=["pytest tests/integration/ -v"],
            )
        )

        # Staging stage
        staging_stage = pipeline.add_stage(DeployStage(self, "Staging", config=stages[1]))
        staging_stage.add_post(
            pipelines.ShellStep("E2ETests",
                commands=["pytest tests/e2e/ -v"],
            )
        )

        # Production stage (with manual approval)
        prod_stage = pipeline.add_stage(DeployStage(self, "Prod", config=stages[2]))
        prod_stage.add_pre(
            pipelines.ManualApprovalStep("PromoteToProd",
                comment="Review staging results before deploying to production"
            )
        )
```

## Rollback Strategy

- CDK Pipelines automatically rolls back failed CloudFormation deployments
- For application-level issues: revert the commit on `main` and let the pipeline redeploy
- DynamoDB: point-in-time recovery allows table restoration to any second in the last 35 days
- S3: object versioning allows recovery of deleted or overwritten files

## Deployment Checklist

Before approving production deployment:

- [ ] All tests pass in staging
- [ ] No CloudWatch alarms firing in staging
- [ ] Performance metrics within acceptable range
- [ ] Database migrations (if any) are backward-compatible
- [ ] Rollback plan documented
- [ ] On-call team notified
