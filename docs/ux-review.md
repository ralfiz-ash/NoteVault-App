# Phase 13 UX review checklist

Found by reviewing every screen and flow (plus a small-screen / large-text /
light+dark layout test). Each item is fixed in Phase 13 unless noted.

| # | Area | Issue | Fix |
|---|------|-------|-----|
| 1 | Notes list | Sort sheet overflowed on short screens with large text | Sheet scrolls |
| 2 | Theme (light) | Gold text (links, text/outlined buttons, section titles) on cream was ~2:1 contrast | Darker gold for text actions (>= 4.5:1); section titles use body colour |
| 3 | Folders / tags / note tags | No double-tap protection, no progress, no success message | Guard in the notifiers, progress bar, success SnackBars |
| 4 | Delete note | The same note could be deleted twice (swipe + note screen) | Ignored while its delete is in progress |
| 5 | Sync | Retry could be tapped repeatedly | Ignored while a sync runs |
| 6 | Editor | Leave dialog had no Save; note loaded by mutating state during build; no success message; load error without retry | Save / Discard / Keep editing; load via listener; "Note saved"; Retry |
| 7 | Note screen | Load error without Retry | Retry |
| 8 | Folders / tags / drawer | No empty state for folders; load errors without Retry | Empty states with next step; Retry |
| 9 | Editor folder picker | Folder load errors were silent | Helper text |
| 10 | Wide screens (web, tablets) | Content stretched edge to edge | Max content width 760 |
| 11 | Keyboard | Lists/forms did not dismiss the keyboard on scroll; tag dialog did not submit from the keyboard | Drag-to-dismiss; submit on done |
| 12 | Accessibility | Tag remove buttons ~22 px; colour swatches announced as hex codes | 40 px targets; named colours with tooltips |
