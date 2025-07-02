# claude-workflows
Reusable Claude AI GitHub Actions workflows and config for dotCMS and related projects

## 🚀 Centralized Claude Workflows: Migration & Overview

**This repository now provides a centralized, reusable system for all Claude AI GitHub Actions workflows.**

- **Replaces the pilot workflow previously used in `dotcms/infrastructure-as-code`.**
- **Keeps things DRY and maintainable** by consolidating logic into orchestrator and executor workflows.
- **Still allows full repo-level customization** via workflow inputs (prompts, allowed tools, runners, etc.).

---

## Migration Guide: From Pilot to Centralized Workflows

If you previously used the pilot Claude workflow in `dotcms/infrastructure-as-code`, follow these steps:

1. **Remove references to the old pilot workflow** in your repository's workflow files.
2. **Update your workflow to use the new orchestrator:**

   ```yaml
   jobs:
     claude:
       uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
       with:
         # Customize as needed for your repo
         allowed_tools: |
           Bash(terraform plan)
           Bash(git status)
         automatic_review_prompt: |
           Please review this pull request for code quality, security, and best practices.
       secrets:
         ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
   ```
3. **Configure your `ANTHROPIC_API_KEY` secret** as described below.
4. **(Optional) Customize prompts, allowed tools, and runner as needed.**

---

## 📚 Migration Details

For a comprehensive migration guide—including step-by-step instructions, validation tips, and infrastructure-specific configuration examples—see [CLAUDE_WORKFLOW_MIGRATION.md](./CLAUDE_WORKFLOW_MIGRATION.md).

---

## Top-Level Points

- **Centralized, DRY, and maintainable:** All Claude logic is now in one place, making updates and improvements easy.
- **Repo-level flexibility:** Each repository can override prompts, tools, and other settings via workflow inputs.
- **Security & cost management:** Each repo must provide its own Anthropic API key for isolation and accountability.
- **No more standalone code review workflow:** All code review and other Claude actions are routed through the orchestrator/executor pattern.

---

## Important: Security and Cost Management

**⚠️ API Key Requirement**: All workflows in this repository require each consuming repository to provide its own Anthropic API key. This is a mandatory security and cost management requirement.

**Why we require per-repository API keys:**

1. **Cost Tracking & Accountability**: Each repository's Claude AI usage is tracked separately in the Anthropic console, allowing for detailed cost attribution and budget management per project.
2. **Security Isolation**: If a repository experiences unauthorized or excessive usage, it only affects that repository's API key and budget, not a shared organizational key.
3. **Usage Control**: Individual repositories can set their own API limits and monitoring, preventing runaway costs from affecting other projects.
4. **Compliance**: Many organizations require API key isolation for audit trails and security compliance.

**What this means for you:**
- You **must** configure an `ANTHROPIC_API_KEY` secret in your repository
- You **must** pass this secret to the reusable workflow in the `secrets:` section
- The workflow will **fail** if the API key is not provided
- Each repository is responsible for its own API costs and usage

---

## Available Workflows

### Claude Orchestrator (`claude-orchestrator.yml`)
Routes all Claude triggers (PRs, issues, comments, reviews) to the correct execution mode and calls the executor workflow.

### Claude Executor (`claude-executor.yml`)
Handles the actual execution of Claude actions, with configurable parameters (prompts, allowed tools, runner, etc.).

---

## Setup Instructions

### 1. Repository Secret Configuration
Each consuming repository must configure its own Anthropic API key:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Create a new repository secret named `ANTHROPIC_API_KEY`
3. Set the value to your Anthropic API key

### 2. Using the Centralized Claude Workflow

Create a workflow file in your repository at `.github/workflows/claude-review.yml` (or similar):

```yaml
name: PR Code Review with Claude

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [ main, develop ]

jobs:
  claude:
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      # Optional: Customize allowed tools
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
      # Optional: Customize review prompt
      automatic_review_prompt: |
        Please review this pull request for code quality, security, and best practices.
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 3. Workflow Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `automatic_review_prompt` | Custom prompt for automatic PR reviews | No | See orchestrator default |
| `allowed_tools` | Custom allowed tools configuration | No | See orchestrator default |
| `timeout_minutes` | Timeout for Claude execution | No | 15 |
| `runner` | GitHub runner to use | No | ubuntu-latest |

---

## Examples

See the `examples/` directory for complete workflow examples.
