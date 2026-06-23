# Find First Release

Find the first release (git tag) that contains a given issue, pull request, or commit.

**Also Available as Gemini Gem:** For team members without Claude Code access, use the [Gemini Gem version](https://gemini.google.com/gem/1M7bkH8P-Inz6yRf1MRRuZEDK-_XPd0EL?usp=sharing).

## Usage

```
/find-first-release <issue|pr|commit>
```

## Parameters

- `issue`: Issue number (e.g., `21`, `#21`, or full URL)
- `pr`: Pull request number or URL
- `commit`: Commit SHA (short or long form)

## Examples

```
/find-first-release 21
/find-first-release #19
/find-first-release https://github.com/dotCMS/ai-workflows/issues/18
/find-first-release https://github.com/dotCMS/ai-workflows/pull/17
/find-first-release 9e1db62
/find-first-release 9e1db62a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e
```

## Implementation

Find the first release (git tag) that contains the specified issue, pull request, or commit: $ARGUMENTS.

**Logic:**

1. **Parse Input**: Determine if the input is an issue number, PR URL/number, or commit SHA
2. **Get Commit SHA**:
   - **For Issues**: Use `gh issue view <number> --json closedAt,timelineItems` to find linked PRs, then get merge commit
   - **For PRs**: Use `gh pr view <number> --json mergeCommit` to get the merge commit SHA
   - **For Commits**: Use the SHA directly
3. **Find First Tag**: Use `git tag --contains <commit> | sort -V | head -1` to find the first release
4. **Handle Edge Cases**:
   - Commit not found: "Commit SHA not found in repository"
   - No tags found: "This commit is not part of any release yet (possibly in an unreleased branch)"
   - Issue/PR not merged: "Issue/PR is not merged yet or has no associated commits"

**Output Format:**

```
🔍 Finding first release for: <input>
📍 Commit SHA: <sha>
🏷️  First Release: <tag> (released on <date>)

📊 Release Details:
- Tag: <tag>
- Date: <release-date>
- Commits: <number> commits since previous release
- View release: https://github.com/<owner>/<repo>/releases/tag/<tag>
```

**Error Handling:**

- If input cannot be parsed: "Invalid input format. Expected issue number, PR URL, or commit SHA"
- If commit is not in any release: "Commit <sha> is not included in any release yet"
- If API calls fail: Provide helpful error messages with suggestions

**Key Commands:**

```bash
# Get merge commit from PR
gh pr view <number> --json mergeCommit --jq '.mergeCommit.oid'

# Get linked PRs from issue
gh issue view <number> --json timelineItems --jq '.timelineItems[] | select(.source.pullRequest) | .source.pullRequest.number'

# Find first tag containing commit
git tag --contains <commit> | sort -V | head -1

# Get tag creation date
git log -1 --format=%ai <tag>

# Count commits between tags
git rev-list <previous-tag>..<tag> --count
```

**Repository Detection:**

- Auto-detect current repository using `gh repo view --json nameWithOwner`
- Support cross-repository queries if full URLs are provided
- Default to current repository for issue/PR numbers
