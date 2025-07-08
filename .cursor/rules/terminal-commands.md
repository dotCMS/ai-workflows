# Terminal Command Best Practices

## Quick Reference
- **ALWAYS** use single quotes for simple strings
- **AVOID** complex multi-line strings with special characters
- **USE** separate files for complex content instead of inline strings
- **NEVER** use emojis or special characters in inline git commands
- **ALWAYS** test simple commands first before complex ones
- **STOP** immediately (Ctrl+C) if you see `dquote>` or `>` prompts

## ZSH Escaping Issues - CRITICAL

### Core Principles
- **ALWAYS** use single quotes for simple strings in terminal commands
- **AVOID** complex multi-line strings with special characters in terminal commands
- **USE** separate files for complex content (like release notes) instead of inline strings
- **PREFER** simple commands over complex ones with embedded content
- **NEVER** use emojis or special characters in inline git commands
- **ALWAYS** test simple commands first before complex ones

### Safe Command Patterns
```bash
# ✅ Good - Simple, no escaping issues
git tag v1.0.0
git push origin v1.0.0
gh release create v1.0.0 --title "Simple Title"
gh pr create --title "Simple Title" --body-file description.md

# ❌ Bad - Complex inline content (causes zsh issues)
git tag -a v1.0.0 -m "🎉 Release with emojis and special chars"
gh release create v1.0.0 --notes "Complex content with @ symbols"
gh pr create --title "Complex Title" --body "Content with special chars"
```

### When ZSH Issues Occur
- **STOP** the command immediately (Ctrl+C)
- **BREAK DOWN** the operation into smaller steps
- **USE FILES** for complex content instead of inline strings
- **TEST** each step individually before combining

### Common ZSH Error Patterns to Avoid
- `dquote>` prompt - means unclosed quotes
- `>` prompt - means incomplete command
- `zsh: no such file or directory` - often means escaping issues
- `zsh: command not found` - often means special characters interpreted as commands

### Emergency Recovery
If you get stuck in a zsh prompt:
1. Press `Ctrl+C` to cancel
2. Press `Ctrl+D` to exit if needed
3. Start fresh with simple commands
4. Use file-based approach for complex content

### File Management for Complex Content
- Create temporary files for complex content
- Use `edit_file` tool for creating content files
- Use `delete_file` tool to clean up temporary files
- Always verify file contents before using them
- Use descriptive filenames like `RELEASE_NOTES_v1.0.0.md`

## Related Rules
- **Git Workflow**: See `git-workflow.md` for git-specific command patterns
- **Error Prevention**: See `error-prevention.md` for recovery procedures
- **Release Process**: See `release-process.md` for release automation
- **Thoughtful Execution**: See `thoughtful-execution.md` for planning guidelines 