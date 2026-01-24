# Fix "Reset Onboarding Flow" Button

**Overall Progress:** `100%`

## TLDR
Fix GitHub issue #4 - the "Reset Onboarding Flow" button in Settings does nothing because it only clears the onboarding flag, not the email (which also gates onboarding). Add a full reset with confirmation dialog.

## Critical Decisions
- **Full reset scope:** Clear email, send history, and AI settings (not just onboarding flag)
- **Confirmation required:** Destructive action needs user confirmation before executing
- **Warning about email change:** Dialog message will note that users can just change email in Settings if that's all they want

## Tasks

- [x] 🟩 **Step 1: Add `resetAll()` method to UserPreferences**
  - [x] 🟩 Add method that clears: `hasCompletedOnboarding`, `email`, `sentHistory`, `aiSummaryEnabled`, `summaryLength`
  - File: `Brief/Shared (App)/UserPreferences.swift`

- [x] 🟩 **Step 2: Add confirmation dialog to ContentView**
  - [x] 🟩 Add `@State private var showResetConfirmation = false`
  - [x] 🟩 Change button action to show dialog instead of direct reset
  - [x] 🟩 Add `.confirmationDialog` modifier with:
    - Title: "Reset Brief?"
    - Message: explains what gets cleared + tip about Email Address field
    - Destructive "Reset" button that calls `resetAll()`
    - Cancel button
  - File: `Brief/Shared (App)/ContentView.swift`

- [x] 🟩 **Step 3: Test and commit**
  - [x] 🟩 Build in Xcode to verify no errors
  - [x] 🟩 Commit with reference to GitHub issue #4
