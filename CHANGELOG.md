# Changelog

All notable changes to the Deployment Guard workflow will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### ✨ Added

- **New `/find-first-release` Command**: Find the first release (git tag) containing an issue, PR, or commit (#21)
  - Supports multiple input formats: issue numbers, PR URLs, and commit SHAs
  - Auto-detects input type and retrieves commit information via GitHub CLI
  - Uses `git tag --contains` to find the first release containing the commit
  - Provides rich output with release date, commit count, and release URL
  - Handles edge cases: unreleased commits, unmerged PRs, and invalid input

## [1.1.2] - 2025-12-16

### 🐛 Critical Bug Fixes

This is a complete architectural refactor of the Deployment Guard workflow to fix critical bugs that were present since v1.0.0. These bugs prevented proper validation and are now fixed without breaking changes.

### ✨ Added

- **Robust Version Comparison**: Complete rewrite of anti-downgrade logic with proper handling of:
  - Base version comparison (YY.MM.DD format)
  - Rebuild number comparison (e.g., `-2` in `25.12.08-2`)
  - Hash comparison (e.g., `_abc123` in `25.12.08_abc123`)
  - Full support for all combinations: `25.12.08`, `25.12.08-2`, `25.12.08_abc`, `25.12.08-2_abc`

- **Improved Registry Validation**:
  - Now tries Docker Hub first, then falls back to full image path for private registries
  - Better error messages indicating which registry was checked
  - Handles mirror registries more gracefully

- **Enhanced Error Reporting**:
  - State variables now accumulate ALL validation failures before exiting
  - Detailed failure reasons shown for each failed image/file
  - Clear indication of which validation step failed and why

### 🔧 Changed

- **State Management Architecture**: Complete replacement of temporary files with bash arrays
  - **Before (v1.x)**: Used `/tmp/validation_failed.txt`, `/tmp/new_images.txt`, `/tmp/old_images.txt`
  - **After (v1.1.2)**: Uses bash arrays: `VALIDATION_FAILED`, `FAILED_IMAGES`, `NEW_IMAGES`, `OLD_IMAGES`
  - Eliminates race conditions and file cleanup issues
  - Deterministic execution with explicit state tracking

- **Error Handling**: Added `set -euo pipefail` to all bash scripts for strict error handling
  - Scripts now fail fast on any command error
  - Undefined variables cause immediate failure
  - Pipe failures are properly detected

### 🐛 Fixed

- **Bug #1**: Fixed rebuild number downgrade detection
  - **Issue**: v1.x allowed downgrade from `25.12.08-2` to `25.12.08` (no suffix)
  - **Root Cause**: Version comparison only compared base version (YY.MM.DD), ignored rebuild numbers
  - **Fix**: Now extracts and compares rebuild numbers when base version is the same
  - **Example**: `25.12.08-2` → `25.12.08` is now correctly blocked as a downgrade
  - **Example**: `25.12.08` → `25.12.08-2` is correctly allowed as an upgrade
  - **Example**: `25.12.08-2_abc` → `25.12.08-2_xyz` is allowed (same version, different hash)

- **Bug #2**: Fixed temporary file persistence issues
  - **Issue**: v1.x had race conditions with `/tmp/validation_failed.txt` file
  - **Root Cause**: Multiple writes to same file in loops, manual cleanup required
  - **Fix**: Eliminated ALL temporary files, using in-memory bash arrays

- **Bug #3**: Fixed image existence validation fragility
  - **Issue**: v1.x only checked Docker Hub canonical image, failed for private registries
  - **Root Cause**: Assumed all images exist in Docker Hub
  - **Fix**: Now tries Docker Hub first, then falls back to full image path with registry

- **Bug #4**: Fixed silent failures in validation loops
  - **Issue**: v1.x would continue loop even after validation failure, sometimes skipping images
  - **Root Cause**: Lack of strict error handling (`set -euo pipefail`)
  - **Fix**: Added strict error handling and explicit state tracking

- **Bug #5**: Fixed version pattern validation edge cases
  - **Issue**: v1.x regex allowed malformed tags to pass
  - **Root Cause**: Regex didn't enforce proper format boundaries
  - **Fix**: Improved regex validation with proper anchoring and format checks

### 🔒 Security

- All bash scripts now use `set -euo pipefail` for strict error handling
- Eliminated potential security issues from temporary file handling
- Better validation of all input parameters before processing

### 📝 Documentation

- Added comprehensive CHANGELOG documenting all fixes
- Improved inline comments explaining complex version comparison logic
- Added examples of supported version formats in code comments

## [1.1.1] - 2025-12-13

### 🐛 Fixed

- Fixed immutable tag support in image validation
- Improved hash extraction for commit hashes in tags

## [1.1.0] - 2025-12-12

### ✨ Added

- Added support for immutable tags with commit hashes
- Added `testing_force_non_bypass` parameter for testing validation logic

## [1.0.0] - 2025-12-10

### ✨ Initial Release

- Organization-based bypass for trusted members
- File allowlist validation
- Image-only change validation
- Image format and repository validation
- Version pattern validation
- Basic anti-downgrade protection
- Image existence verification in registry

---

## Migration Guide: v1.1.1 → v1.1.2

### No Breaking Changes

v1.1.2 is a **hotfix release** that fixes critical bugs without changing the API or default behavior. All workflows using v1.1.1 can safely upgrade to v1.1.2 without any changes.

### What's Fixed in v1.1.2

1. **Rebuild Downgrade Protection**: Now correctly blocks downgrades like `25.12.08-2` → `25.12.08`
2. **Private Registry Support**: Image existence checks now work with private registries
3. **Deterministic Execution**: No more temporary file race conditions
4. **Complete Error Reporting**: All validation failures are reported, not just the first one

### Upgrade Steps

Simply update the version tag in your workflow:

```yaml
# Before (v1.1.1 - buggy)
uses: dotCMS/ai-workflows/.github/workflows/deployment-guard.yml@v1.1.1

# After (v1.1.2 - fixed)
uses: dotCMS/ai-workflows/.github/workflows/deployment-guard.yml@v1.1.2
```

No configuration changes needed! All parameters remain the same.

---

## Bug Details

### Bug #1: Rebuild Downgrade Not Detected

**Severity**: High
**Impact**: Allowed downgrades that should be blocked

**Scenario**:
```yaml
# Before: 25.12.08-2_abc123 (rebuild 2)
# After:  25.12.08_xyz789     (no rebuild = rebuild 0)
```

**v1.1.1 Behavior**: ✅ Allowed (incorrectly)
- Extracted base version: `25.12.08` == `25.12.08` → Same version, allowed
- Did NOT compare rebuild numbers

**v1.1.2 Behavior**: ❌ Blocked (correctly)
- Extracted base version: `25.12.08` == `25.12.08`
- Extracted rebuild: `2` > `0` → Downgrade detected, blocked

**Technical Details**:
```bash
# v1.1.1 logic (BROKEN)
OLD_VERSION_NO_HASH="${OLD_TAG%%_*}"      # 25.12.08-2
NEW_VERSION_NO_HASH="${TAG%%_*}"           # 25.12.08
OLD_VERSION="${OLD_VERSION_NO_HASH%%-*}"   # 25.12.08
NEW_VERSION="${NEW_VERSION_NO_HASH%%-*}"   # 25.12.08
# Only compared: 25.12.08 == 25.12.08 → ✅ PASS (BUG!)

# v1.1.2 logic (FIXED)
OLD_BASE_VERSION=$(echo "$OLD_TAG" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')  # 25.12.08
NEW_BASE_VERSION=$(echo "$TAG" | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')      # 25.12.08
# Compare base: 25.12.08 == 25.12.08
# Extract rebuilds: OLD=2, NEW=0
# Compare rebuild: 2 > 0 → ❌ BLOCKED (CORRECT!)
```

### Bug #2: Temporary File Race Conditions

**Severity**: Medium
**Impact**: Non-deterministic failures, potential missed validations

**Scenario**: Multiple validation failures in same job run

**v1.1.1 Behavior**:
- Wrote `echo "false" > /tmp/validation_failed.txt` from different points
- Files could be left behind from previous runs
- Race conditions in concurrent validations

**v1.1.2 Behavior**:
- Uses in-memory bash arrays: `VALIDATION_FAILED=false`, `FAILED_IMAGES=()`
- Accumulates all failures before exiting
- Deterministic, no file system dependencies

### Bug #3: Image Existence Check Failures

**Severity**: High
**Impact**: Validation failed for valid private registry images

**Scenario**: Using a mirror registry (e.g., `mirror.gcr.io/dotcms/dotcms:25.12.08`)

**v1.1.1 Behavior**: ❌ Failed
- Only checked Docker Hub: `docker manifest inspect dotcms/dotcms:25.12.08`
- If image not in Docker Hub → validation failed
- Didn't fallback to full image path

**v1.1.2 Behavior**: ✅ Success
- First tries Docker Hub: `dotcms/dotcms:25.12.08`
- If not found, tries full path: `mirror.gcr.io/dotcms/dotcms:25.12.08`
- Gracefully handles both public and private registries

---

## Version Support

- **v1.1.2**: Current stable release (recommended) - Bug fixes
- **v1.1.1**: Previous release (deprecated - contains critical bugs)
- **v1.1.0**: Deprecated (use v1.1.2)
- **v1.0.0**: Deprecated (use v1.1.2)

## Support

For issues or questions:
- Report bugs: https://github.com/dotCMS/ai-workflows/issues
- Security issues: security@dotcms.com
