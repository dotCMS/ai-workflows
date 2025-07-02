# Claude Workflows Architecture

## Overview

This repository provides centralized, reusable GitHub Actions workflows for Claude AI integration. The architecture follows a simple, reliable pattern where consumer repositories handle their own triggers and call centralized execution workflows.

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│           Consumer Repository           │
│  ┌───────────────────────────────────┐  │
│  │     Consumer Workflow File       │  │
│  │  (.github/workflows/claude.yml)  │  │
│  │                                   │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │    Webhook Triggers         │  │  │
│  │  │  • issue_comment            │  │  │
│  │  │  • pull_request             │  │  │
│  │  │  • pull_request_review      │  │  │
│  │  │  • issues                   │  │  │
│  │  └─────────────────────────────┘  │  │
│  │           │                       │  │
│  │           ▼                       │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │   Conditional Logic         │  │  │
│  │  │  • Check for @claude        │  │  │
│  │  │  • Route to appropriate     │  │  │
│  │  │    trigger mode             │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────┬───────────────────┘  │
└──────────────────┼──────────────────────┘
                   │
                   ▼ (workflow_call)
┌─────────────────────────────────────────┐
│        Claude Workflows Repo           │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │      claude-orchestrator.yml            │  │
│  │   (Lightweight Wrapper)           │  │
│  │                                   │  │
│  │  • Receives trigger_mode          │  │
│  │  • Receives configuration         │  │
│  │  • Passes through to executor     │  │
│  └───────────────┬───────────────────┘  │
│                  │                     │
│                  ▼ (workflow_call)     │
│  ┌───────────────────────────────────┐  │
│  │      claude-executor.yml          │  │
│  │    (Execution Engine)             │  │
│  │                                   │  │
│  │  • Runs Claude AI with tools      │  │
│  │  • Handles interactive/automatic   │  │
│  │  • Posts results as comments      │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Workflow Types

### Consumer Workflows

Located in consuming repositories (e.g., `infrastructure-as-code`, `dotcat`):

- Handle webhook events directly
- Implement trigger conditions and routing logic
- Call centralized workflows with appropriate parameters
- Provide repository-specific configuration (tools, prompts, timeouts)

### Centralized Workflows

Located in this repository (`claude-workflows`):

#### 1. `claude-orchestrator.yml` (Recommended)

- Lightweight wrapper around the executor
- Simple interface for consumer repositories
- Reliable and predictable behavior

#### 2. `claude-executor.yml`

- Core execution engine
- Runs Claude AI with configured tools
- Handles both interactive and automatic modes
- Posts results back to GitHub

#### 3. `claude-orchestrator.yml` (Deprecated)

- **DO NOT USE** - Has architectural flaws
- Loses original event context when called via `workflow_call`
- Causes double triggering
- Kept for backward compatibility only

## Key Benefits

### ✅ Reliable Event Handling

- Consumer repositories maintain full control over webhook events
- No loss of event context
- No double triggering issues

### ✅ DRY Principle

- Centralized execution logic in `claude-executor.yml`
- Reusable across multiple repositories
- Consistent behavior and updates

### ✅ Security Isolation

- Each repository provides its own `ANTHROPIC_API_KEY`
- Cost tracking per repository
- No shared credentials

### ✅ Flexibility

- Repository-specific tool configurations
- Custom prompts and timeouts
- Configurable path exclusions

## Migration Path

If you're using the old orchestrator pattern:

### Before (Problematic)

```yaml
jobs:
  claude:
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      allowed_tools: "Bash(git status)"
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### After (Fixed)

```yaml
jobs:
  claude-comment-mention:
    if: |
      github.event_name == 'issue_comment' && 
      contains(github.event.comment.body, '@claude')
    uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
    with:
      trigger_mode: interactive
      allowed_tools: "Bash(git status)"
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## Examples

See the `examples/` directory for complete working examples:

- `consumer-repo-workflow.yml` - General purpose template
- `infrastructure-consumer-workflow.yml` - Infrastructure-specific example
- `corrected-consumer-workflow.yml` - Shows the fix for double triggering

## Why This Architecture?

The original orchestrator design attempted to centralize trigger logic, but GitHub Actions `workflow_call` loses the original webhook event context. When a consumer workflow calls a reusable workflow:

1. Consumer receives `issue_comment` event
2. Consumer calls orchestrator via `workflow_call`
3. Orchestrator sees `github.event_name` as `"workflow_call"`, not `"issue_comment"`
4. All conditional logic fails
5. Multiple jobs may trigger unexpectedly

The new architecture solves this by keeping trigger logic where the event context is available (in the consumer workflow) and using centralized workflows only for execution.
