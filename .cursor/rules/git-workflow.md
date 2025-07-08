# Git and GitHub CLI Best Practices

## Quick Reference
- **Use version tags** (`@v1.0.0`) instead of `@main` for production stability
- **Create release notes in files** instead of inline messages
- **Use simple git commands** without complex inline content
- **Test simple commands first** before complex operations
- **Use file-based approach** for complex content (PR descriptions, release notes)

## Git Commands - Safe Patterns

### Tagging and Releases
- Use `git tag v1.0.0` instead of `git tag -a v1.0.0 -m "complex message"`
- Create release notes in separate files, then use `--notes-file` flag
- Avoid inline commit messages with special characters
- Use `git commit -m "simple message"` for commits
- Use `git push origin branch-name` for pushes

### Branch Management
- Use descriptive branch names: `feature/description` or `fix/issue-description`
- Always pull latest changes before creating new branches
- Use `git checkout -b branch-name` for new branches
- Use `git branch -D branch-name` to force delete local branches

### Commit Messages
- Keep commit messages concise and descriptive
- Use present tense: "Add feature" not "Added feature"
- Avoid special characters and emojis in commit messages
- Use conventional commit format when possible: `type(scope): description`

## GitHub CLI Commands - Safe Patterns

### Releases
- Use `gh release create v1.0.0 --title "Simple Title" --notes-file release-notes.md`
- Avoid complex inline descriptions with emojis and special formatting
- Create temporary files for complex content, then delete them
- Use `gh release edit v1.0.0 --title "Simple Title" --notes-file notes.md`

### Pull Requests
- Use `gh pr create --title "Simple Title" --body-file pr-description.md`
- Create PR description files for complex content
- Use `gh pr view --web` to open PR in browser
- Use `gh pr status` to check PR status

### Repository Management
- Use `gh repo view --web` to open repository in browser
- Use `gh repo clone owner/repo` for cloning
- Use `gh repo fork owner/repo` for forking

## Safe Command Examples

### Creating a Release
```bash
# ✅ Good - File-based approach
edit_file "RELEASE_NOTES_v1.0.0.md" "Release content here"
git tag v1.0.0
git push origin v1.0.0
gh release create v1.0.0 --title "Release v1.0.0" --notes-file RELEASE_NOTES_v1.0.0.md
delete_file "RELEASE_NOTES_v1.0.0.md"

# ❌ Bad - Inline complex content
git tag -a v1.0.0 -m "🎉 Major release with new features and bug fixes"
gh release create v1.0.0 --notes "Complex release notes with @mentions and special chars"
```

### Creating a Pull Request
```bash
# ✅ Good - File-based approach
edit_file "PR_DESCRIPTION.md" "PR description content"
gh pr create --title "Feature: Add new functionality" --body-file PR_DESCRIPTION.md
delete_file "PR_DESCRIPTION.md"

# ❌ Bad - Inline complex content
gh pr create --title "Complex Title 🚀" --body "Complex description with @mentions and special chars"
```

## Error Prevention
- Test simple commands first
- Break complex operations into smaller steps
- Use file-based approaches for complex content
- Verify results after each step
- Check command output for zsh errors
- If you see `dquote>` or `>` prompts, cancel and simplify

## Related Rules
- **Terminal Commands**: See `terminal-commands.md` for zsh escaping best practices
- **Release Process**: See `release-process.md` for release automation
- **Error Prevention**: See `error-prevention.md` for troubleshooting
- **Thoughtful Execution**: See `thoughtful-execution.md` for planning guidelines 