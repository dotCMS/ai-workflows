#!/bin/bash
# Release script for claude-workflows
# This script follows best practices to avoid zsh escaping issues

set -e  # Exit on any error

# Configuration
VERSION=$1
RELEASE_NOTES_FILE="RELEASE_NOTES_${VERSION}.md"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

echo "🚀 Creating release $VERSION..."

# Step 1: Create release notes file
echo "📝 Creating release notes file..."
cat > "$RELEASE_NOTES_FILE" << 'EOF'
# Release Notes Template

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
EOF

echo "✅ Release notes template created: $RELEASE_NOTES_FILE"
echo "📝 Please edit $RELEASE_NOTES_FILE with actual release content"
echo "⏸️  Press Enter when ready to continue..."
read

# Step 2: Create git tag (simple, no complex messages)
echo "🏷️  Creating git tag..."
git tag "$VERSION"

# Step 3: Push tag
echo "📤 Pushing tag to remote..."
git push origin "$VERSION"

# Step 4: Create GitHub release
echo "📦 Creating GitHub release..."
gh release create "$VERSION" \
    --title "claude-workflows $VERSION" \
    --notes-file "$RELEASE_NOTES_FILE"

# Step 5: Clean up
echo "🧹 Cleaning up..."
rm "$RELEASE_NOTES_FILE"

echo "✅ Release $VERSION created successfully!"
echo "🔗 Check the release at: https://github.com/dotCMS/claude-workflows/releases/tag/$VERSION" 