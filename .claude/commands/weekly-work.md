# Weekly Work Summary

Generate a summary of completed work (merged PRs) for the previous week.

## Usage

```
/weekly-work <team> <start-date> <end-date>
```

## Parameters

- `team`: Team name (scout or falcon)
- `start-date`: Start date in YYYY-MM-DD format
- `end-date`: End date in YYYY-MM-DD format

## Examples

```
/weekly-work falcon 2025-07-06 2025-07-12
/weekly-work scout 2025-07-01 2025-07-07
```

## Implementation

Generate a weekly work summary showing what was actually delivered (merged PRs) for $ARGUMENTS.

**Team Definitions:**

- **Falcon Team**: oidacra (Arcadio Quintero), hmoreras (Humberto Moreras), nicobytes (Nicolas Molina), freddyDOTCMS (Freddy Rodriguez), jcastro-dotcms (Jose Castro)
- **Scout Team**: [define team members as needed]

Use the GitHub CLI to:

1. Parse team name and date range from arguments
2. Fetch PRs that were **merged** (not just closed) between the specified dates
3. Focus on `mergedAt` field, not `closedAt`
4. **Group related PRs by feature/topic** (e.g., Analytics, Edit Content, etc.)
5. Format as consolidated bullet points showing completed work
6. Use emojis: ✨ for features, 🐛 for fixes, 🔧 for improvements, ✅ for tests, 📚 for docs
7. Combine multiple PRs for the same feature into single descriptions
8. Provide delivery count and impact summary

GitHub username mapping:

- oidacra = Arcadio Quintero
- hmoreras = Humberto Moreras
- nicobytes = Nicolas Molina
- freddyDOTCMS = Freddy Rodriguez
- jcastro-dotcms = Jose Castro

Output format:

```
## [Team Name] Team - Weekly Work Summary
### Week of [start-date] to [end-date]

**7 key deliveries completed:**
• ✨ Analytics platform enhancements: dashboard consolidation, siteKey validation, dependency updates, and CubeJS schema improvements
• 🔧 Edit Content field disable state handling for block editor, binary, file, and image fields
• 🔧 Relationship field improvements: disable new content creation flow and SCSS width enforcement
• ✨ Configuration detail enhancements with button enablement logic
• 🐛 UI consistency improvements: breadcrumb styles and e2e testing enhancements

### Summary
**Total: 11 merged PRs**
**Impact: Significant improvements to analytics capabilities, enhanced edit content functionality, and better UI consistency**
```

**Key Focus:**

- Only show PRs that were actually **merged** (completed work)
- Use `mergedAt` date for filtering, not `closedAt`
- This gives stakeholders a clear view of what was actually delivered last week
