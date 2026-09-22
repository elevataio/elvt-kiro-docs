# Kiro Steering Files — Complete Working Samples

This folder contains a full set of production-ready steering files for an AWS serverless backend project. Copy the `.kiro/` folder into your project root and customize to fit your needs.

## What's Included

```
.kiro/
└── steering/
    ├── 01-project-overview.md         # Project structure, tech stack, environments
    ├── 02-coding-standards.md         # Python style, naming, error handling, logging
    ├── 03-aws-security-baseline.md    # IAM, encryption, network, secrets management
    ├── 04-cdk-infrastructure.md       # CDK patterns, stack organization, constructs
    ├── 05-api-design.md               # REST conventions, request/response format
    ├── 06-dynamodb-patterns.md        # Single-table design, access patterns, GSIs
    ├── 07-deployment-pipeline.md      # CDK Pipelines, branch strategy, rollback
    ├── 08-forbidden-patterns.md       # What Kiro should NEVER generate
    ├── 09-testing-strategy.md         # Test pyramid, unit/integration/e2e patterns
    ├── 10-monitoring-observability.md # Logging, tracing, metrics, alarms
    ├── 11-lambda-handler-guide.md     # (Conditional) Activates for Lambda files
    ├── 12-cdk-construct-guide.md      # (Conditional) Activates for CDK files
    └── 13-openapi-reference.md        # (Manual) Available via # in chat
```

## Inclusion Modes

| File | Mode | When Active |
|------|------|-------------|
| 01 through 10 | **Always** | Every Kiro session automatically |
| 11 (Lambda guide) | **fileMatch** | Only when editing `src/lambdas/**/*.py` |
| 12 (CDK guide) | **fileMatch** | Only when editing `infra/**/*.py` |
| 13 (OpenAPI ref) | **Manual** | Only when user types `#` and selects it |

## How to Use These Samples

### Quick Start

1. Copy the `.kiro/steering/` folder into your project root
2. Edit `01-project-overview.md` to match your actual project
3. Adjust naming conventions in `02-coding-standards.md`
4. Update AWS account IDs and regions in `04-cdk-infrastructure.md`
5. Remove any files that don't apply to your project

### For Non-Serverless Projects

If your project uses ECS, EKS, or EC2 instead of Lambda:
- Remove `11-lambda-handler-guide.md`
- Modify `04-cdk-infrastructure.md` to reflect your compute layer
- Adjust `10-monitoring-observability.md` for your monitoring approach

### For Frontend Projects

If you're building a frontend (React, Vue, etc.):
- Keep `01-project-overview.md` (update tech stack)
- Keep `02-coding-standards.md` (update for JS/TS)
- Keep `08-forbidden-patterns.md` (update patterns)
- Remove AWS-specific files (03, 04, 06, 07)
- Add your own frontend-specific steering

## Customization Tips

1. **Start small** — You don't need all 13 files. Begin with 01, 02, and 08.
2. **Be specific** — Generic advice doesn't help Kiro. Say "use DynamoDB" not "use a database."
3. **Include examples** — Code samples in steering files dramatically improve Kiro's output quality.
4. **Update regularly** — As your project evolves, update the steering to match.
5. **Use file references** — `#[[file:path]]` syntax lets you point to existing docs without duplication.

## File Naming Convention

Files are numbered (`01-`, `02-`, etc.) for reading order, but Kiro loads them all regardless of naming. The numbering helps humans navigate the folder.

## Need More?

- [Kiro Steering Documentation](https://kiro.dev/docs/steering/)
- [Global Steering (user-level)](https://kiro.dev/blog/stop-repeating-yourself/)
- [Teaching Kiro with Steering and MCP](https://kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/)
