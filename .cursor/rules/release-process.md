# Release Process Guidelines

## Release Process Checklist

### Pre-Release Preparation
1. ✅ Ensure all features are merged to main
2. ✅ Run tests and verify everything works
3. ✅ Update documentation if needed
4. ✅ Check that examples use version tags (not @main)

### Release Creation
1. ✅ Create release notes in separate file using `edit_file`
2. ✅ Use simple git tag command: `git tag v1.0.0`
3. ✅ Use `--notes-file` for GitHub releases
4. ✅ Clean up temporary files with `delete_file`
5. ✅ Verify tag points to correct commit
6. ✅ Test each command individually before combining

### Post-Release Tasks
1. ✅ Update any references to use new version tag
2. ✅ Notify team of new release
3. ✅ Monitor for any issues
4. ✅ Plan next release features

## Version Tag Best Practices

### Always Use Version Tags
```yaml
# ✅ Good - Production stable
uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@v1.0.0

# ❌ Bad - Can cause unexpected behavior
uses: dotCMS/claude-workflows/.github/workflows/claude-orchestrator.yml@main
```

### Why Version Tags Matter
- **Stability**: Version tags are immutable and won't change unexpectedly
- **Predictability**: You know exactly which version you're using
- **Rollback**: Easy to rollback to previous versions if needed
- **Production Safety**: Prevents breaking changes from affecting production workflows

## Release Automation

### Using the Release Script
```bash
# Run the automated release script
./scripts/create-release.sh v1.1.0
```

The script will:
1. Create a release notes template file
2. Let you edit it with actual content
3. Create the git tag safely
4. Create the GitHub release using the file
5. Clean up temporary files

### Manual Release Process
If not using the script, follow this pattern:

```bash
# 1. Create release notes file
edit_file "RELEASE_NOTES_v1.0.0.md" "Release content here"

# 2. Create and push tag
git tag v1.0.0
git push origin v1.0.0

# 3. Create GitHub release
gh release create v1.0.0 --title "Release v1.0.0" --notes-file RELEASE_NOTES_v1.0.0.md

# 4. Clean up
delete_file "RELEASE_NOTES_v1.0.0.md"
```

## Semantic Versioning

### Version Format: MAJOR.MINOR.PATCH
- **MAJOR**: Breaking changes, major new features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Examples
- `v1.0.0` - First major release
- `v1.1.0` - New features added
- `v1.1.1` - Bug fixes
- `v2.0.0` - Breaking changes

## Release Notes Guidelines

### Structure
```markdown
# Release Title

## What's New
- Feature 1
- Feature 2
- Bug fixes

## Migration Notes
- Breaking changes
- Important updates

## Technical Details
- Performance improvements
- Security updates
```

### Content Guidelines
- Be clear and concise
- Focus on user impact
- Include migration steps for breaking changes
- Highlight security updates
- Provide examples when helpful

## Quality Assurance

### Before Releasing
- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] Examples use version tags
- [ ] No sensitive information in release notes
- [ ] Version number follows semver
- [ ] Tag points to correct commit

### After Releasing
- [ ] Verify release appears on GitHub
- [ ] Check that tag is correct
- [ ] Test that consuming repos can use new version
- [ ] Monitor for any issues
- [ ] Update any internal documentation 