# Claude Workflow Migration Guide

> **Note:** For main usage instructions and up-to-date examples, see [README.md](./README.md).

## Overview
This document outlines the migration of Claude AI workflows to the centralized `dotCMS/claude-workflows` repository to implement DRY principles and enable reuse across multiple repositories.

## Files Created for claude-workflows Repository

The following files should exist in the `dotCMS/claude-workflows` repository:

### 1. `.github/workflows/claude-executor.yml`
Location: `claude-executor-reusable.yml` (rename to `claude-executor.yml`)
- Reusable workflow that handles Claude AI execution
- Configurable allowed tools, timeout, and runner
- Accepts trigger mode and direct prompt inputs

### 2. `.github/workflows/claude-orchestrator.yml`  
Location: `claude-orchestrator-reusable.yml` (rename to `claude-orchestrator.yml`)
- Reusable workflow that orchestrates Claude interactions
- Handles all trigger events (comments, PRs, issues)
- Configurable prompts, tools, and **statically calls the executor workflow**

## Migration Benefits

### Before (Current State)
- Each repository maintains its own Claude workflow files
- Duplication of logic across repositories
- Updates require changes in multiple places
- Inconsistent configurations between repositories

### After (Centralized State)
- Single source of truth for Claude workflows
- Repository-specific configurations via parameters
- Easier maintenance and updates
- Consistent behavior across all repositories
- DRY principle implementation

## Implementation Steps

### Step 1: Ensure Files Exist in claude-workflows Repository

> **Historical Note:** This step is already completed in this repository. The required workflows are present and correctly named. For forks or future migrations, ensure the following files exist in the correct locations:
> - `.github/workflows/claude-executor.yml`
> - `.github/workflows/claude-orchestrator.yml`

### Step 2: Repository Configuration
The infrastructure-as-code repository has been updated to:
- Reference centralized workflows from `dotCMS/claude-workflows`
- Maintain infrastructure-specific configurations:
  - Terraform/Terragrunt allowed tools
  - Cost-aware automatic review prompts
  - Customer path exclusions

### Step 3: Validation
After setup, test the workflows by:
1. Creating a test PR
2. Verifying automatic reviews work
3. Testing @claude mentions in comments
4. Confirming path exclusions still apply

## Key Features Preserved

### Infrastructure-Specific Configurations
- **Allowed Tools**: Terraform, Terragrunt, and Git commands
- **Automatic Review Prompt**: Includes cost impact analysis
- **Path Exclusions**: Customer-specific Kubernetes files ignored
- **Timeout**: 15-minute execution limit
- **Runner**: Ubuntu-latest

### Workflow Triggers
- Interactive @claude mentions (case-insensitive)
- Automatic PR reviews (when no @claude mention)
- Issue comments and reviews
- Pull request events

### Concurrency Control
- Prevents multiple Claude jobs per PR/issue
- Maintains existing behavior

## Next Steps

1. **Ensure reusable workflows exist** in claude-workflows repository (already done here)
2. **Test the migration** with a sample PR
3. **Apply to other repositories** using the same pattern
4. **Document usage** for other teams

## Benefits for Other Repositories

Other dotCMS repositories can now easily add Claude support by:
1. Creating a simple orchestrator workflow that calls the centralized version
2. Customizing allowed tools for their specific needs
3. Setting repository-specific prompts and configurations
4. Maintaining consistent Claude behavior across the organization

This migration addresses issue [dotCMS/dotcat#213](https://github.com/dotCMS/dotcat/issues/213) and establishes the foundation for organization-wide Claude workflow standardization.