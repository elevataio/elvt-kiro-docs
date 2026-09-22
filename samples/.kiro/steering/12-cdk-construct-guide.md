---
inclusion: fileMatch
fileMatchPattern: "infra/**/*.py"
---

# CDK Construct Guide

This steering activates automatically when working on infrastructure files.

## When Creating a New Stack

Follow this template:

```python
from aws_cdk import Stack, Tags
from constructs import Construct


class MyStack(Stack):
    """Brief description of what this stack provisions."""

    def __init__(self, scope: Construct, id: str, config, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        # Apply standard tags
        Tags.of(self).add("project", "order-api")
        Tags.of(self).add("environment", config.env_name)
        Tags.of(self).add("owner", "backend-team")
        Tags.of(self).add("managed-by", "cdk")

        # Define resources below
        ...
```

## When Creating a New Construct

```python
from constructs import Construct
from dataclasses import dataclass


@dataclass
class MyConstructProps:
    """Configuration for MyConstruct."""
    name: str
    environment: str
    # ... other properties


class MyConstruct(Construct):
    """Brief description of what this construct provides.
    
    Example usage:
        MyConstruct(self, "Example", props=MyConstructProps(name="test", environment="dev"))
    """

    def __init__(self, scope: Construct, id: str, props: MyConstructProps) -> None:
        super().__init__(scope, id)

        # Implementation here
        ...
```

## Checklist Before Synth

- [ ] All resources use parameterized names (not hardcoded)
- [ ] Removal policies match the environment (DESTROY for dev, RETAIN for prod)
- [ ] IAM permissions are scoped to specific resources (no wildcards)
- [ ] Tags applied at stack level
- [ ] Cross-stack dependencies use construct properties (not SSM or hard-coded ARNs)
- [ ] CfnOutput for any value other stacks or humans need to reference

## Common CDK Mistakes to Avoid

- Don't use `cdk.Fn.import_value()` — it creates brittle CloudFormation dependencies
- Don't put secrets in CDK context or `cdk.json` — use Secrets Manager
- Don't use `aws_cdk.aws_lambda.Function` for Python without specifying `architecture` (defaults may change)
- Don't forget `removal_policy` on stateful resources — the default is DESTROY
