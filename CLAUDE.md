# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides centralized, reusable GitHub Actions workflows for Claude AI integration across dotCMS and related projects. It implements a DRY approach by consolidating Claude workflow logic into orchestrator and executor patterns that can be consumed by other repositories.

## Architecture Overview

The repository implements a two-workflow architecture:

### Core Workflows
- **Claude Orchestrator** (`.github/workflows/claude-orchestrator.yml`): Routes different trigger types (PR events, comments, issues) to appropriate execution modes. Handles both interactive (@claude mentions) and automatic review modes. **Statically calls the executor workflow.**
- **Claude Executor** (`.github/workflows/claude-executor.yml`): The execution engine that runs Claude AI actions with configurable tools, timeouts, and runners.

### Key Design Patterns
- **Reusable Workflows**: Both workflows use `workflow_call` to be consumed by other repositories
- **Conditional Execution**: Orchestrator prevents duplicate runs by routing triggers to specific jobs
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

Repositories use this workflow by creating a workflow file that calls the orchestrator:

```yaml
jobs:
  claude:
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      # Repository-specific configurations
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
      automatic_review_prompt: |
        Custom review prompt for this repository
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

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
- **Concurrency**: Prevents multiple Claude jobs per PR/issue