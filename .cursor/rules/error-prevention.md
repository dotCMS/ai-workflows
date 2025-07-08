# Error Prevention and Recovery

## Common Issues and Solutions

### ZSH Escaping Issues

#### Symptoms
- Commands hang with `dquote>` or `>` prompts
- `zsh: no such file or directory` errors
- `zsh: command not found` errors
- Commands with special characters fail

#### Prevention
- Use single quotes for simple strings
- Avoid complex multi-line strings in terminal commands
- Use separate files for complex content
- Test simple commands first

#### Recovery
1. Press `Ctrl+C` to cancel the command
2. Press `Ctrl+D` if stuck in a prompt
3. Break down the operation into smaller steps
4. Use file-based approach for complex content

### Git Issues

#### Protected Branch Errors
```
remote: error: GH006: Protected branch update failed for refs/heads/main.
remote: - 2 of 2 required status checks are expected.
```

**Solution**: Create a feature branch and PR instead of pushing directly to main

#### Tag Conflicts
```
fatal: tag 'v1.0.0' already exists
```

**Solution**: 
```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Recreate tag
git tag v1.0.0
git push origin v1.0.0
```

### GitHub CLI Issues

#### Authentication Errors
```
gh: not logged in to any hosts. Run 'gh auth login' to authenticate with a host
```

**Solution**: Run `gh auth login` and follow the prompts

#### Rate Limiting
```
API rate limit exceeded for user ID
```

**Solution**: Wait a few minutes and try again, or use a personal access token

## Debugging Strategies

### Step-by-Step Approach
1. **Start Simple**: Test basic commands first
2. **Add Complexity**: Gradually add more complex operations
3. **Verify Each Step**: Check results before proceeding
4. **Use Files**: Create temporary files for complex content
5. **Clean Up**: Remove temporary files when done

### Command Validation
```bash
# Test git commands
git status
git log --oneline -3

# Test GitHub CLI
gh auth status
gh repo view

# Test complex operations with files
edit_file "test.md" "Test content"
cat test.md
delete_file "test.md"
```

### Logging and Debugging
- Use `set -x` in scripts for verbose output
- Check command exit codes: `echo $?`
- Use `gh --version` and `git --version` to verify tools
- Check shell: `echo $SHELL`

## Prevention Checklist

### Before Running Commands
- [ ] Verify you're in the correct directory
- [ ] Check that required tools are installed
- [ ] Ensure you have proper permissions
- [ ] Test simple commands first
- [ ] Have a backup plan

### For Complex Operations
- [ ] Break down into smaller steps
- [ ] Use file-based approach for content
- [ ] Test each step individually
- [ ] Have rollback procedures ready
- [ ] Document the process

### For Releases
- [ ] Verify all tests pass
- [ ] Check documentation is up to date
- [ ] Ensure examples use version tags
- [ ] Test the release process on a test repo
- [ ] Have rollback plan ready

## Emergency Procedures

### If Commands Hang
1. Press `Ctrl+C` to cancel
2. Press `Ctrl+D` if still stuck
3. Close terminal and open new one
4. Start fresh with simple commands

### If Files Get Corrupted
1. Use `git status` to check what changed
2. Use `git checkout -- filename` to restore
3. Use `git reset --hard HEAD` as last resort
4. Recreate from backup if needed

### If Tags Get Messed Up
1. Delete problematic tags locally and remotely
2. Recreate tags pointing to correct commits
3. Update GitHub releases if needed
4. Verify everything works correctly

## Best Practices Summary

### Do's
- ✅ Use simple commands when possible
- ✅ Test commands before running complex operations
- ✅ Use files for complex content
- ✅ Follow the release checklist
- ✅ Use version tags instead of @main
- ✅ Clean up temporary files

### Don'ts
- ❌ Use complex inline strings with special characters
- ❌ Use emojis in git commands
- ❌ Skip testing simple commands first
- ❌ Leave temporary files around
- ❌ Use @main in production workflows
- ❌ Ignore error messages 