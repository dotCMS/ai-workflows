# claude-workflows
Reusable Claude AI GitHub Actions workflows and config for dotCMS and related projects

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

## Available Workflows

### Claude Code Review (`claude-code-review.yml`)
Provides AI-powered code review using Claude AI for pull requests and commits.

**Features:**
- Reviews changed files in PRs automatically
- Configurable review focus (general, security, performance, best-practices)
- Posts review comments directly on PRs
- Supports custom file selection
- Uploads review artifacts

## Setup Instructions

### 1. Repository Secret Configuration
Each consuming repository must configure its own Anthropic API key:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Create a new repository secret named `ANTHROPIC_API_KEY`
3. Set the value to your Anthropic API key

**Benefits of per-repository API keys:**
- **Cost Tracking**: Each repository's usage is tracked separately in the Anthropic console
- **Security Isolation**: Unauthorized usage in one repo won't affect others
- **Usage Control**: Individual repos can manage their own API limits

### 2. Using the Claude Code Review Workflow

Create a workflow file in your repository at `.github/workflows/claude-review.yml`:

```yaml
name: PR Code Review with Claude

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [ main, develop ]

jobs:
  claude-review:
    name: Claude AI Code Review
    uses: dotCMS/claude-workflows/.github/workflows/claude-code-review.yml@main
    with:
      # Optional: Set review focus
      review_focus: 'security'  # Options: general, security, performance, best-practices
      
      # Optional: Maximum number of files to review
      max_files: 15
      
      # Optional: Specify specific files (defaults to all changed files)
      # files_to_review: 'src/main.js,src/utils.js'
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 3. Workflow Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `files_to_review` | Comma-separated list of specific files to review | No | All changed files |
| `review_focus` | Review focus area | No | `general` |
| `max_files` | Maximum number of files to review | No | `10` |

**Review Focus Options:**
- `general`: Overall code quality, bugs, and improvements
- `security`: Security vulnerabilities and best practices
- `performance`: Performance issues and optimizations
- `best-practices`: Code quality and maintainability

### 4. Required Secrets

| Secret | Description | Required | Notes |
|--------|-------------|----------|-------|
| `ANTHROPIC_API_KEY` | Your repository's Anthropic API key | **Yes** | Must be configured in each consuming repository. The workflow will fail without this secret. |

**⚠️ Critical**: The `ANTHROPIC_API_KEY` secret is mandatory and must be passed to the reusable workflow. This is not optional - it's a security and cost management requirement. See the "Security and Cost Management" section above for details.

## Examples

See the `examples/` directory for complete workflow examples.
