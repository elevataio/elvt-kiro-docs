# CDK Infrastructure Standards

## General Rules

- Use AWS CDK v2 with Python
- One stack per bounded context (api, data, auth, monitoring, pipeline)
- Each custom construct lives in its own file, named after the construct
- Props interfaces defined in the same file as the construct
- Use L2/L3 constructs where available; L1 (CfnResource) only when the higher-level construct is missing functionality

## Stack Organization

```
infra/
├── app.py                          # CDK app entry point
├── stacks/
│   ├── api_stack.py                # API Gateway + Lambda
│   ├── data_stack.py               # DynamoDB + S3
│   ├── auth_stack.py               # Cognito
│   ├── monitoring_stack.py         # Dashboards + Alarms
│   └── pipeline_stack.py           # CDK Pipelines (CI/CD)
├── constructs/
│   ├── lambda_function.py          # Reusable Lambda construct with standards
│   ├── api_endpoint.py             # API Gateway route construct
│   └── secure_bucket.py            # S3 bucket with security defaults
└── config/
    ├── dev.py                      # Dev environment config
    ├── staging.py                  # Staging environment config
    └── prod.py                     # Production environment config
```

## CDK App Entry Point Pattern

```python
# infra/app.py
import aws_cdk as cdk
from config.dev import DevConfig
from config.staging import StagingConfig
from config.prod import ProdConfig
from stacks.pipeline_stack import PipelineStack

app = cdk.App()

# Pipeline deploys to all environments
PipelineStack(app, "OrderApi-Pipeline",
    env=cdk.Environment(account="111111111111", region="us-east-1"),
    stages=[DevConfig, StagingConfig, ProdConfig],
)

app.synth()
```

## Environment Configuration Pattern

```python
# infra/config/prod.py
from dataclasses import dataclass

@dataclass
class ProdConfig:
    env_name: str = "prod"
    account: str = "333333333333"
    region: str = "us-east-1"
    
    # Compute
    lambda_memory: int = 1024
    lambda_timeout_seconds: int = 30
    reserved_concurrency: int = 100
    
    # Data
    dynamodb_billing_mode: str = "PROVISIONED"
    dynamodb_read_capacity: int = 25
    dynamodb_write_capacity: int = 25
    
    # Monitoring
    alarm_email: str = "ops-team@company.com"
    enable_xray: bool = True
    log_retention_days: int = 90
```

## Lambda Construct Pattern

```python
# infra/constructs/lambda_function.py
from aws_cdk import (
    aws_lambda as _lambda,
    aws_logs as logs,
    Duration,
)
from constructs import Construct

class StandardLambdaFunction(Construct):
    """A Lambda function with organizational standards applied."""

    def __init__(
        self,
        scope: Construct,
        id: str,
        handler_path: str,
        function_name: str,
        memory_size: int = 512,
        timeout_seconds: int = 30,
        environment: dict = None,
        **kwargs,
    ) -> None:
        super().__init__(scope, id, **kwargs)

        self.function = _lambda.Function(
            self, "Function",
            function_name=function_name,
            runtime=_lambda.Runtime.PYTHON_3_12,
            handler="handler.handler",
            code=_lambda.Code.from_asset(handler_path),
            memory_size=memory_size,
            timeout=Duration.seconds(timeout_seconds),
            environment=environment or {},
            tracing=_lambda.Tracing.ACTIVE,
            log_retention=logs.RetentionDays.ONE_MONTH,
        )
```

## Deployment Rules

- **Never deploy directly to production** — all changes go through CDK Pipelines
- **Always run `cdk diff` before deploying** to review changes
- **Use `cdk synth` to validate** — this catches errors without touching AWS
- **Tag all resources** with: project, environment, owner, cost-center

```python
# Apply tags to all resources in a stack
cdk.Tags.of(self).add("project", "order-api")
cdk.Tags.of(self).add("environment", config.env_name)
cdk.Tags.of(self).add("owner", "backend-team")
cdk.Tags.of(self).add("cost-center", "engineering")
```

## Common Patterns

### Cross-Stack References
Pass resources between stacks using construct properties, not hard-coded ARNs:

```python
# In DataStack
self.orders_table = dynamodb.Table(...)

# In ApiStack constructor
api_stack = ApiStack(self, "Api", orders_table=data_stack.orders_table)
```

### Removal Policies
- **Dev**: `RemovalPolicy.DESTROY` (easy cleanup)
- **Staging**: `RemovalPolicy.SNAPSHOT` where supported
- **Production**: `RemovalPolicy.RETAIN` (never lose data)

### Outputs
Export important values for reference:

```python
cdk.CfnOutput(self, "ApiUrl", value=api.url, description="API Gateway endpoint URL")
cdk.CfnOutput(self, "TableName", value=table.table_name, description="DynamoDB table name")
```
