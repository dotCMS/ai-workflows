# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides centralized, reusable GitHub Actions workflows for Claude AI integration across dotCMS and related projects. It implements a DRY approach by consolidating Claude workflow logic into orchestrator and executor patterns that can be consumed by other repositories.

## Architecture Overview

The repository implements a simple, reliable architecture:

### Core Workflows

- **Claude Orchestrator** (`.github/workflows/claude-orchestrator.yml`): A lightweight wrapper that calls the executor with minimal configuration. This is the recommended workflow for consumer repositories (FIXED - no longer has the original architectural issues).
- **Claude Executor** (`.github/workflows/claude-executor.yml`): The execution engine that runs Claude AI actions with configurable tools, timeouts, and runners.

### Key Design Patterns

- **Consumer-Handled Triggers**: Consumer repositories handle their own webhook triggers and conditional logic, then call the centralized workflows
- **Simple Reusable Workflows**: The `claude-orchestrator.yml` workflow provides a clean interface to the executor
- **Parameterization**: Workflows accept inputs for customization (prompts, tools, timeouts, runners)
- **Security Isolation**: Each consuming repository must provide its own `ANTHROPIC_API_KEY` for cost tracking and security

## Common Commands

### Testing and Validation

```bash
# Lint YAML files
yamllint -c .yamllint.yml **/*.yml **/*.yaml

# Validate workflow syntax
python -c "import yaml; yaml.safe_load(open('.github/workflows/claude-orchestrator.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/claude-executor.yml'))"
```

### Workflow Testing

The repository includes automated tests in `.github/workflows/tests.yml` that:

- Lint all YAML files using yamllint configuration
- Validate GitHub Actions workflow syntax
- Check for required workflow elements (name, on, jobs)
- Validate secret requirements in reusable workflows

## Configuration Files

- **`.yamllint.yml`**: YAML linting configuration with 240-character line length limit and 2-space indentation
- **Examples**: `examples/consumer-repo-workflow.yml` shows how consuming repositories should reference these workflows

## Usage by Consuming Repositories

### Recommended Approach: Consumer-Handled Triggers

The recommended approach is for consumer repositories to handle their own webhook triggers and conditional logic, then call the centralized `claude-orchestrator.yml` workflow. This approach is reliable and avoids the architectural issues with the orchestrator pattern.

**Example for interactive @claude mentions:**

```yaml
jobs:
  claude-comment-mention:
    if: |
      github.event_name == 'issue_comment' && (
        contains(github.event.comment.body, '@claude') ||
        contains(github.event.comment.body, '@Claude') ||
        contains(github.event.comment.body, '@CLAUDE')
      )
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      trigger_mode: interactive
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
      timeout_minutes: 15
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Example for automatic PR reviews:**

```yaml
  claude-automatic-review:
    if: |
      github.event_name == 'pull_request' &&
      !contains(github.event.pull_request.title, '@claude')
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      trigger_mode: automatic
      direct_prompt: |
        Please review this pull request and provide feedback...
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Why This Approach?

The original orchestrator design had a fundamental flaw: when called via `workflow_call`, the `github.event_name` becomes `"workflow_call"` instead of the original trigger event (like `"issue_comment"`), causing all conditional logic to fail and resulting in double triggering.

The consumer-handled approach solves this by:

1. Consumer workflows handle their own webhook events directly
2. They evaluate trigger conditions using the original event context
3. They call the simple centralized workflow only when conditions are met
4. No double triggering occurs

See the complete examples in the `examples/` directory:

- `examples/consumer-repo-workflow.yml` - General purpose example
- `examples/infrastructure-consumer-workflow.yml` - Infrastructure-specific example

## Security Requirements

- Each consuming repository MUST provide its own `ANTHROPIC_API_KEY` secret
- API keys are required for cost tracking, security isolation, and usage control
- Workflows will fail if the API key is not provided

## Workflow Triggers Supported

- Interactive @claude mentions (case-insensitive) in:
  - Issue comments
  - Pull request review comments  
  - Pull request reviews
  - Issue titles/bodies
  - Pull request titles/bodies
- Automatic pull request reviews (when no @claude mention is present)

## Default Configuration

- **Timeout**: 15 minutes
- **Runner**: ubuntu-latest  
- **Default Tools**: `git status` and `git diff`
- **Concurrency**: Consumer repositories should implement concurrency control:

  ```yaml
  concurrency:
    group: claude-${{ github.event.pull_request.number || github.event.issue.number || 'manual' }}
    cancel-in-progress: false
  ```

## Migration from Orchestrator

If you're currently using the `claude-orchestrator.yml` workflow, migrate to the new pattern:

1. Replace the single orchestrator call with multiple jobs that handle different trigger conditions
2. Use `claude-orchestrator.yml` instead of `claude-orchestrator.yml`
3. Add proper concurrency control to your consumer workflow
4. Test that @claude mentions and automatic reviews work without double triggering

See the example files for complete migration templates.
