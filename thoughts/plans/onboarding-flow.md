# Plan: Brief Onboarding Flow

## Overview

Add a 3-step onboarding flow for first-time users that:
1. Collects email address (saves to UserPreferences)
2. Shows how to enable the share extension
3. Demonstrates how to share a link with animation

## Architecture

### New Files
- `Brief/Shared (App)/OnboardingView.swift` - Main onboarding container
- `Brief/Shared (App)/OnboardingStepViews.swift` - Individual step views

### Modified Files
- `Brief/Shared (App)/UserPreferences.swift` - Add `hasCompletedOnboarding` flag
- `Brief/iOS (App)/BriefApp.swift` - Conditional onboarding vs main app
- `Brief/macOS (App)/AppDelegate.swift` - Same for macOS

---

## Step 1: Email Entry

**Screen: Welcome + Email Input**

```
┌─────────────────────────────────┐
│                                 │
│        [App Icon]               │
│                                 │
│     Welcome to Brief            │
│   AI-powered article summaries  │
│   delivered to your inbox       │
│                                 │
│  ┌───────────────────────────┐  │
│  │ your@email.com            │  │
│  └───────────────────────────┘  │
│                                 │
│     [Continue →]                │
│                                 │
└─────────────────────────────────┘
```

**Implementation:**
- Gradient background (briefPrimary → briefSecondary) at top
- Email TextField with validation (must contain @)
- "Continue" button disabled until valid email
- On continue: save to `userPreferences.email`

---

## Step 2: Enable Extension

**Screen: How to Enable Share Extension**

```
┌─────────────────────────────────┐
│                                 │
│   Enable Brief in Share Sheet   │
│                                 │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │   [Illustration/Steps]    │  │
│  │                           │  │
│  │   1. Tap Share button     │  │
│  │   2. Scroll right →       │  │
│  │   3. Tap "More"           │  │
│  │   4. Enable "Brief"       │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│     [Continue →]                │
│                                 │
└─────────────────────────────────┘
```

**Implementation:**
- Platform-specific instructions (iOS vs macOS differ)
- iOS: Share sheet → Edit → Toggle Brief on
- macOS: Share menu → More → Enable Brief
- Use numbered steps with SF Symbols
- Static illustration or simple diagram

---

## Step 3: Share Demo Animation

**Screen: Animated Demo of Sharing Flow**

```
┌─────────────────────────────────┐
│                                 │
│      How Brief Works            │
│                                 │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │   [Animated Demo]         │  │
│  │                           │  │
│  │   Safari → Share →        │  │
│  │   Brief → Email arrives   │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
│     [Get Started]               │
│                                 │
└─────────────────────────────────┘
```

**Implementation:**
- Use SwiftUI animation with `withAnimation` and `Timer`
- Sequence of states showing:
  1. Browser icon with article
  2. Share button appears/highlights
  3. Brief icon appears
  4. Email icon with checkmark
- Loop animation or play once
- "Get Started" completes onboarding

---

## Data Model Changes

### UserPreferences.swift

```swift
// Add new property
@Published var hasCompletedOnboarding: Bool {
    didSet { userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
}

// In init()
hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
```

---

## App Entry Point Changes

### BriefApp.swift (iOS) / AppDelegate.swift (macOS)

```swift
var body: some Scene {
    WindowGroup {
        if userPreferences.hasCompletedOnboarding {
            ContentView()
                .environmentObject(userPreferences)
        } else {
            OnboardingView()
                .environmentObject(userPreferences)
        }
    }
}
```

---

## OnboardingView Structure

```swift
struct OnboardingView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var currentStep = 0
    @State private var email = ""

    var body: some View {
        TabView(selection: $currentStep) {
            EmailStepView(email: $email, onContinue: {
                userPreferences.email = email
                currentStep = 1
            })
            .tag(0)

            EnableExtensionStepView(onContinue: { currentStep = 2 })
            .tag(1)

            ShareDemoStepView(onComplete: {
                userPreferences.hasCompletedOnboarding = true
            })
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
```

---

## Animation Approach for Step 3

Use a state machine with Timer:

```swift
enum DemoState: Int, CaseIterable {
    case browsing    // Show browser with article
    case tapping     // Highlight share button
    case selecting   // Show Brief in share sheet
    case sending     // Show sending animation
    case delivered   // Email with checkmark
}

@State private var demoState: DemoState = .browsing

// Timer advances state every 1.5 seconds
// Each state triggers different view with transition
```

Visual elements:
- SF Symbols: `safari`, `square.and.arrow.up`, `doc.text`, `envelope`, `checkmark.circle`
- Animate with `.transition(.scale.combined(with: .opacity))`
- Use `withAnimation(.spring())` for smooth transitions

---

## Design Tokens

Match existing theme:
- Background: `.briefBackground` (light lavender)
- Primary gradient: `[.briefPrimary, .briefSecondary]`
- Cards: White with `cornerRadius(16)` and subtle shadow
- Buttons: Gradient fill with white text
- Text: `.primary` for titles, `.secondary` for descriptions

---

## Implementation Order

1. **UserPreferences.swift** - Add `hasCompletedOnboarding` property
2. **OnboardingView.swift** - Create container with TabView
3. **OnboardingStepViews.swift** - Create 3 step views
   - EmailStepView
   - EnableExtensionStepView
   - ShareDemoStepView
4. **BriefApp.swift** - Add conditional rendering
5. **AppDelegate.swift** - Same for macOS
6. **Test** - Reset UserDefaults to test flow

---

## Testing

To reset onboarding for testing:
```swift
UserDefaults(suiteName: "group.com.danielensign.Brief")?.removeObject(forKey: "hasCompletedOnboarding")
```

Or add a hidden debug gesture in SettingsView.

---

## Platform Considerations

- **iOS**: Use `.tabViewStyle(.page)` for swipe between steps
- **macOS**: May need custom navigation (Next/Back buttons) as page style less natural
- Both share same step content views with `#if os()` for platform-specific instructions
