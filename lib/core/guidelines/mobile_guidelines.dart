// =============================================================================
// INSIDETEAM — MOBILE-FIRST RESPONSIVE GUIDELINES
// =============================================================================
//
// All existing and future pages/screens MUST follow these patterns to ensure
// zero overflow errors on mobile viewports (target: 360–390px wide).
//
// RULE 1: STAGE / STATUS BADGES
//   NEVER place a stage.displayName badge inside a Row() alongside expanding
//   content. Always use one of:
//     • Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 6)
//     • Move badge to its own full-width dedicated row/line
//     • Add ConstrainedBox(maxWidth: 190) + TextOverflow.ellipsis to badge text
//
// RULE 2: APPBAR TITLES
//   Always wrap title text with Flexible() or Expanded() + overflow: TextOverflow.ellipsis.
//   Use Builder + MediaQuery to show icon-only action buttons on < 500px.
//   Hide role Chip widgets on < 400px.
//
// RULE 3: SIDE-BY-SIDE BUTTONS (YES / NO, etc.)
//   Use LayoutBuilder → Column with SizedBox(width: double.infinity) on < 460px.
//   On wider screens, keep the standard Row layout.
//
// RULE 4: CARD HEADERS (ID + Badge)
//   Use Wrap(spacing: 8, runSpacing: 6) for ID + badge pairs.
//   Never use Row(mainAxisAlignment: spaceBetween) for these.
//
// RULE 5: DIALOG PADDING
//   All dialogs: insetPadding: EdgeInsets.symmetric(
//     horizontal: MediaQuery.of(context).size.width < 600 ? 12 : 20
//   )
//
// RULE 6: METRICS / STATS ROWS
//   Use LayoutBuilder → GridView with adaptive crossAxisCount on mobile.
//   Example: crossAxisCount = width > 860 ? 5 : width > 600 ? 3 : 2
//
// RULE 7: INFO ROW LABELS
//   Use LayoutBuilder to shrink label SizedBox width on < 400px.
//   Example: labelWidth = constraints.maxWidth < 400 ? 110 : 140
//
// RULE 8: TEXT OVERFLOW PROTECTION
//   Any user-facing text that could be long MUST have:
//     maxLines: N, overflow: TextOverflow.ellipsis
//
// RULE 9: FORM FIELD PAIRS
//   Side-by-side form fields: Use LayoutBuilder → stacked Column on < 560px.
//
// RULE 10: BANNER TITLES + ACTION BUTTONS
//   Use LayoutBuilder → stacked Column on < 540px.
//   On wide screens, keep Row with Expanded title + button.
//
// ESTABLISHED BREAKPOINTS:
//   < 380px : Dashboard grid aspectRatio 0.80–0.88
//   < 400px : Hide role chips in AppBar
//   < 460px : Stack YES/NO decision buttons vertically
//   < 480px : 2-column spec grids in detail sheets
//   < 500px : Show icon-only action buttons in AppBar
//   < 540px : Stack banner title + flowchart button
//   < 560px : Stack form fields in register modals
//   < 600px : Adapt dialog padding (12px mobile vs 20px desktop)
//   < 640px : Stack hero banner columns
//   > 860px : 5-column metric rows
//
// TEST CHECKLIST BEFORE MARKING COMPLETE:
//   ✓ flutter analyze → 0 issues
//   ✓ flutter test → all tests pass
//   ✓ Test at 360px viewport width in Chrome DevTools
//   ✓ Test on physical phone via network URL
// =============================================================================

