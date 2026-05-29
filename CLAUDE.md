# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides centralized, reusable GitHub Actions workflows for Claude AI integration across dotCMS and related projects. It implements a DRY approach by consolidating Claude workflow logic into orchestrator and executor patterns that can be consumed by other repositories.

## Architecture Overview

The repository implements a reusable workflow architecture with model-aware routing:

### Core Workflows

- **Claude Orchestrator** (`.github/workflows/claude-orchestrator.yml`): Lightweight wrapper that handles @claude mention detection AND routes to the appropriate executor based on `model_id`. Consumer repositories call this with `trigger_mode: interactive` or `trigger_mode: automatic`. Exactly one executor runs per call.
- **Claude Executor** (`.github/workflows/claude-executor.yml`): Execution engine for Anthropic models — runs `anthropics/claude-code-action@v1` either against the direct Anthropic API (`provider: anthropic-api`, default) or via AWS Bedrock (`provider: anthropic-bedrock`, OIDC + `use_bedrock=true`).
- **Bedrock Generic Executor** (`.github/workflows/bedrock-generic-executor.yml`): Execution engine for **any non-Anthropic Bedrock model** (Amazon Nova, Meta Llama, Mistral, Cohere, AI21). Uses the Bedrock Converse API and maintains its own sticky comment via `.github/scripts/sticky-comment.sh`.
- **Deployment Guard** (`.github/workflows/deployment-guard.yml`): Reusable workflow for validating deployment changes with configurable rules. Features organization-based bypass for trusted members, file allowlist validation, image-only change detection, and comprehensive image validation (format, repository, version pattern, registry existence, anti-downgrade logic).

### Multi-model Routing (v3)

The orchestrator picks the executor by inspecting `model_id`:

| `model_id` value                                  | Routed to                          | Notes                                          |
| ------------------------------------------------- | ---------------------------------- | ---------------------------------------------- |
| _(empty / unset)_                                 | `claude-executor` (`anthropic-api`)| Backward-compat default; requires `ANTHROPIC_API_KEY` secret |
| `*.anthropic.*` (e.g. `global.anthropic.claude-sonnet-4-6`) | `claude-executor` (`anthropic-bedrock`) | Requires `bedrock_role_arn` input              |
| `anthropic.*` (bare)                              | `claude-executor` (`anthropic-bedrock`) | Requires `bedrock_role_arn` input              |
| Anything else (Nova, Llama, Mistral, …)           | `bedrock-generic-executor`          | Requires `bedrock_role_arn` input              |

The match for the Anthropic family is anchored: `^([a-z]+\.)?anthropic\.` — so a model ID that merely contains the substring `anthropic.` (e.g. `us.not-anthropic.foo`) is **not** misrouted.

### Sticky Comments

- The Anthropic path's sticky comment is managed by `anthropics/claude-code-action@v1` via `use_sticky_comment: "true"`.
- The Bedrock generic path manages its own sticky comment via `.github/scripts/sticky-comment.sh`, keyed by a marker `<!-- dotcms-ai-review:v3:<namespace> -->`. The namespace defaults to the model family; consumers can pass `sticky_namespace` to avoid collisions when running multiple review jobs on the same PR.

### Critical Architectural Insight

The original orchestrator attempted to centralize trigger logic, but GitHub Actions `workflow_call` loses the original webhook event context. When a consumer workflow calls a reusable workflow, `github.event_name` becomes `"workflow_call"` instead of the original event (like `"issue_comment"`), causing all conditional logic to fail.

**Solution**: Consumer repositories handle their own webhook events and conditional logic, then call the centralized workflows only when conditions are met. This prevents double triggering and maintains proper event context.

## Common Commands

### Testing and Validation

```bash
# Lint all workflows with actionlint (via docker)
docker run --rm -v "${PWD}:/repo" -w /repo rhysd/actionlint:1.7.7

# Validate workflow syntax
python -c "import yaml; yaml.safe_load(open('.github/workflows/claude-orchestrator.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/claude-executor.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/bedrock-generic-executor.yml'))"
python -c "import yaml; yaml.safe_load(open('.github/workflows/deployment-guard.yml'))"

# Shellcheck the sticky-comment helper
docker run --rm -v "${PWD}:/repo" -w /repo koalaman/shellcheck:stable .github/scripts/sticky-comment.sh

# Run automated tests
# Tests are defined in .github/workflows/tests.yml and run automatically on PR/push to main
```

### Testing Deployment Guard

The deployment-guard workflow includes a `testing_force_non_bypass` parameter for testing validation logic even when you're an organization member. See recent commits `9e1db62` and earlier for refactoring details and state management improvements.

## Development Patterns

### ZSH Command Safety (CRITICAL)

When using terminal commands, especially git and GitHub CLI operations:

- **ALWAYS** use single quotes for simple strings
- **NEVER** use emojis or special characters in inline git/gh commands
- **USE** separate files for complex content (release notes, commit messages) instead of inline strings
- **STOP IMMEDIATELY** (Ctrl+C) if you see `dquote>` or `>` prompts - this means ZSH escaping issues

**Safe patterns:**
```bash
# Good - simple commands with file-based content
git tag v1.0.0
gh release create v1.0.0 --title "Simple Title" --notes-file release-notes.md

# Bad - complex inline content causes ZSH issues
git tag -a v1.0.0 -m "🎉 Release with emojis"
gh release create v1.0.0 --notes "Complex @ content"
```

### File Management Best Practices

The deployment-guard workflow demonstrates critical state management patterns:
- **NO temporary files** - Use bash arrays and variables instead
- Avoids race conditions and cleanup issues
- See commit `9e1db62` (deployment-guard v2.0.0) for robust state management examples

### Version Tagging

**ALWAYS use version tags** (`@v1.0.0`) instead of `@main` for production workflows:
```yaml
# Production-safe
uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v1.0.0

# Unsafe - can break unexpectedly
uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@main
```

## Usage by Consuming Repositories

Consumer repositories handle their own webhook triggers and conditional logic, then call centralized workflows. This preserves event context and prevents double triggering.

**Interactive mode example (with built-in @claude detection):**
```yaml
jobs:
  claude-interactive:
    if: |
      github.event_name != 'pull_request' || (
        contains(github.event.pull_request.title, '@claude') ||
        contains(github.event.pull_request.title, '@Claude') ||
        contains(github.event.pull_request.title, '@CLAUDE') ||
        contains(github.event.pull_request.body, '@claude') ||
        contains(github.event.pull_request.body, '@Claude') ||
        contains(github.event.pull_request.body, '@CLAUDE')
      )
    uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v1.0.0
    with:
      trigger_mode: interactive
      enable_mention_detection: true  # Built-in @claude detection
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Automatic mode example:**
```yaml
  claude-automatic:
    if: github.event_name == 'pull_request'
    uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v1.0.0
    with:
      trigger_mode: automatic
      enable_mention_detection: false
      skip_automatic_when_mentioned: true  # Default; avoids overlap with @claude PR mentions
      direct_prompt: |
        Please review this pull request for code quality and security.
      allowed_tools: |
        Bash(terraform plan)
        Bash(git status)
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Multi-model (v3) examples:**

Anthropic Sonnet 4.6 via Bedrock (no `ANTHROPIC_API_KEY` needed):
```yaml
  claude-bedrock:
    permissions:
      id-token: write      # OIDC
      contents: read
      pull-requests: write
    uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v3.0.0
    with:
      trigger_mode: automatic
      enable_mention_detection: false
      prompt: Review this PR for correctness, security, and design issues.
      model_id: global.anthropic.claude-sonnet-4-6
      bedrock_role_arn: arn:aws:iam::123456789012:role/GitHubActions-BedrockReview
```

Amazon Nova Pro via the generic Bedrock executor:
```yaml
  nova-review:
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v3.0.0
    with:
      trigger_mode: automatic
      enable_mention_detection: false
      prompt: Review this PR for backend Java/Spring issues.
      model_id: us.amazon.nova-pro-v1:0
      bedrock_role_arn: arn:aws:iam::123456789012:role/GitHubActions-BedrockReview
      sticky_namespace: backend-reviewer   # Avoids collisions with other generic-bedrock jobs on the same PR
```

**Custom trigger conditions:**
```yaml
  claude-security-review:
    uses: dotCMS/ai-workflows/.github/workflows/claude-orchestrator.yml@v1.0.0
    with:
      trigger_mode: automatic
      enable_mention_detection: false
      custom_trigger_condition: |
        github.event_name == 'pull_request' && (
          contains(github.event.pull_request.title, 'security') ||
          contains(github.event.pull_request.body, 'vulnerability')
        )
      direct_prompt: Review for security implications.
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

See `examples/` directory for complete working examples.

### Dual invocation troubleshooting

If interactive and automatic jobs exist in the same consumer workflow:
- Add a job-level `if` guard to the interactive job so non-mention PR open/sync events do not invoke it.
- Keep automatic job scoped to `pull_request`.
- Use `skip_automatic_when_mentioned: true` (default) so automatic mode does not overlap when PR title/body includes `@claude`.

## Deployment Guard Workflow

The deployment-guard workflow provides configurable validation for deployment changes:

### Key Features
- **Organization-based bypass**: Public members of a trusted organization bypass all validations
- **File allowlist**: Restrict changes to specific file patterns (glob-based)
- **Image-only validation**: Ensure only container image fields are modified (no resource/env changes)
- **Image validation**: Format, repository, version pattern, registry existence, anti-downgrade checking
- **Testing mode**: `testing_force_non_bypass: true` to test validation logic even as org member

### State Management Pattern
The deployment-guard demonstrates robust bash state management without temporary files (see `deployment-guard.yml:227-252` and `297-382`):
- Uses bash arrays instead of temp files to avoid race conditions
- Proper error handling with `set -euo pipefail`
- Clear state tracking with boolean flags

### Version Validation Logic
Sophisticated version comparison supporting dotCMS format: `YY.MM.DD[-REBUILD][_HASH]`
- Prevents downgrades at base version level (25.12.08 → 25.12.07)
- Prevents rebuild downgrades (25.12.08-2 → 25.12.08-1)
- Allows hash changes for same version (25.12.08_abc → 25.12.08_def)

## Security Requirements

- Each consuming repository MUST provide its own `ANTHROPIC_API_KEY` secret
- API keys are required for cost tracking, security isolation, and usage control
- Workflows will fail if the API key is not provided
- Never commit secrets to version control

## Default Configuration

### Claude Workflows
- **Timeout**: 15 minutes
- **Runner**: ubuntu-latest
- **Default Tools**: `git status` and `git diff`
- **Mention Detection**: Case-insensitive @claude in comments, reviews, issues, and PRs
- **Concurrency**: Consumer repositories should implement concurrency control to prevent duplicate runs

### Deployment Guard
- **Organization bypass**: Disabled by default (must configure `trusted_organization`)
- **All validations**: Enabled by default
- **Image verification**: Checks Docker Hub by default

## Important Files

- **ARCHITECTURE.md**: Two labeled diagrams (toolchain-wide + repo-internal v3 routing), workflow types, migration path from v2 → v3, and the reasoning behind the consumer-handles-triggers pattern
- **CLAUDE_WORKFLOW_MIGRATION.md**: Step-by-step migration guide from pilot workflows
- **.cursor/rules/**: Modular development rules covering terminal commands, git workflow, release process, error prevention, and collaboration patterns
- **examples/**: Working examples for general-purpose, infrastructure, and advanced custom triggers
