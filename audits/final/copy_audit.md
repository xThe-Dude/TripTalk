# TripTalk Copy Audit
**Auditor**: Senior Copy Editor — Harm Reduction
**Date**: 2026-03-15
**Scope**: All user-facing strings in `TripTalk/Views/**/*.swift` and `TripTalk/Data/MockData.swift`
**Method**: Full read of every file; no Swift files modified.

---

## Summary

| Priority | Count | Category |
|----------|-------|----------|
| P0 | 3 | Safety/Legal accuracy — must fix before launch |
| P1 | 7 | Tone violations, dosage guidance, misleading copy |
| P2 | 8 | Polish, consistency, minor framing issues |

---

## P0 — Critical (Safety / Legal Accuracy)

### P0-1: Fireside Project `tel:` link dials the wrong number

**File**: `TripTalk/Views/Profile/ProfileView.swift:244`

**Current text/code**:
```swift
Link(destination: URL(string: "tel:6232737654")!) {
    Text("Psychedelic peer support: 62-FIRESIDE")
```

**What's wrong**: `tel:6232737654` dials 623-273-7654. The vanity mnemonic "62-FIRESIDE" decodes to (623) 473-7433 (`tel:6234737433`). The displayed number and the dialed number do not match. A user in psychedelic crisis who taps this link reaches a wrong number.

**Replacement**:
```swift
Link(destination: URL(string: "tel:6234737433")!) {
    Text("Psychedelic peer support: 623-FIRESIDE · (623) 473-7433")
```

Also fix the matching reference in `HomeView.swift:225`:
**Current**: `"• Fireside Project Psychedelic Peer Support: 62-FIRESIDE"`
**Replacement**: `"• Fireside Project Psychedelic Peer Support: (623) 473-7433"`

---

### P0-2: "Terms of Service" link resolves to `support.html` — same page as "Community Guidelines"

**File**: `TripTalk/Views/Profile/ProfileView.swift:206`

**Current text/code**:
```swift
Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/support.html")!) {
    Text("Terms of Service")
```

**What's wrong**: "Community Guidelines" (line 180) and "Terms of Service" (line 206) both resolve to the same `support.html` URL. Users who tap "Terms of Service" receive the Community Guidelines document. These are distinct legal instruments; linking them to the same page is misleading and may affect enforceability.

**Replacement**: Point "Terms of Service" to a dedicated page, e.g.:
```swift
Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/terms.html")!) {
    Text("Terms of Service")
```

---

### P0-3: Age-gate consent disclosure references only "Community Guidelines" — Terms of Service and Privacy Policy omitted

**File**: `TripTalk/Views/AgeGate/AgeGateView.swift:82–88`

**Current text**:
```
By continuing you agree to our
[Community Guidelines]
```

**What's wrong**: Two issues:
1. Missing comma — grammatically incorrect.
2. A consent gate that binds the user to the app's terms should reference the Terms of Service and Privacy Policy, not just the Community Guidelines. An age-gate disclaimer that omits these documents is legally incomplete.

**Replacement** (approximate — layout may need adjustment):
```
By continuing, you agree to our
[Terms of Service], [Privacy Policy], and [Community Guidelines]
```

---

## P1 — Important (Tone, Dosage Guidance, Misleading Copy)

### P1-1: Explicit dosage instruction in Tip of the Day

**File**: `TripTalk/Views/Home/HomeView.swift:14`

**Current text**:
```
"Start with a lower amount than you think you need. You can always explore deeper next time."
```

**What's wrong**: "Start with a lower amount than you think you need" is direct dosage instruction — the app's own voice telling users how much to take. "You can always explore deeper next time" frames escalating use as a goal, which is recreational framing inconsistent with harm-reduction principles.

**Replacement**:
```
"Thoroughly research any substance before an experience, and consult a healthcare provider when possible. Preparation is a core harm-reduction practice."
```

---

### P1-2: "It will pass" discourages crisis help-seeking

**File**: `TripTalk/Views/Home/HomeView.swift:21`

**Current text**:
```
"If anxiety arises, remember: change your setting, breathe deeply, and it will pass."
```

**What's wrong**: "It will pass" is categorical reassurance for a scenario that may require professional intervention. Users experiencing severe distress during a psychedelic experience could be deterred from calling 988 or the Fireside Project by this phrasing. A harm-reduction app must not promise that any distressing symptom will resolve on its own.

**Replacement**:
```
"If anxiety arises, grounding techniques can help: slow your breathing, change your environment, and focus on something familiar. If distress persists or escalates, call the Fireside Project at (623) 473-7433 or dial 988."
```

---

### P1-3: "Beginner Friendly" section header encourages inexperienced use

**File**: `TripTalk/Views/Explore/ExploreView.swift:63`

**Current text**:
```swift
sectionView("Beginner Friendly")
```

**What's wrong**: Labeling a category of psychedelic varieties "Beginner Friendly" implies they are safe or appropriate for first-time psychedelic use without further context — which contradicts harm-reduction best practices. No psychedelic variety should be marketed as inherently appropriate for novices.

**Replacement**:
```swift
sectionView("Lower Intensity")
```

---

### P1-4: B+ strain description uses promotional and recreational language

**File**: `TripTalk/Data/MockData.swift:37`

**Current text**:
```
"B+ is a versatile, forgiving variety known for its warm euphoria and gentle visuals. It's a fantastic choice for beginners, offering a positive, uplifting experience with minimal body load and a clear-headed quality."
```

**What's wrong**:
- "forgiving" anthropomorphizes a substance and downplays risk.
- "a fantastic choice for beginners" is an active recommendation to inexperienced users.
- "positive, uplifting experience" is promotional language, not educational.

**Replacement**:
```
"B+ is a moderate-potency psilocybin variety with community-reported euphoric and gently visual effects. Users note a comparatively mild body component. As with all psychedelic substances, harm-reduction principles — set, setting, sober support, and thorough preparation — remain essential regardless of perceived intensity."
```

---

### P1-5: Liberty Caps description implies foraging as expected access method

**File**: `TripTalk/Data/MockData.swift:38`

**Current text** (opening sentence):
```
"Wild-growing across temperate regions, Liberty Caps are one of the most potent naturally occurring psilocybin mushrooms."
```

**What's wrong**: Opening with a habitat description and calling them "naturally occurring" without any foraging warning implicitly frames wild harvesting as a viable access route. Foraging for psilocybin mushrooms is illegal in most jurisdictions and carries significant risk of misidentification and accidental poisoning. No anti-foraging statement appears anywhere in the description.

**Replacement** (replace the opening sentence):
```
"Liberty Caps (Psilocybe semilanceata) are among the most potent psilocybin-containing fungi documented. Wild foraging is strongly discouraged — misidentification risks are serious and potentially fatal, and harvesting is illegal in most jurisdictions. Access only through licensed service providers where applicable."
```

---

### P1-6: "Showing services near you" is misleading — app uses no location services

**File**: `TripTalk/Views/Services/ServicesListView.swift:26`

**Current text**:
```
"Showing services near you"
```

**What's wrong**: The app does not request or use CoreLocation. This text implies the list is personalized to the user's actual location when it shows mock/static data. Misleading location claims undermine user trust.

**Replacement**:
```
"Featured service centers"
```

---

### P1-7: Safety alert button label has URL typo — "fireside-project.org" vs. "firesideproject.org"

**File**: `TripTalk/Views/Home/HomeView.swift:221`

**Current text/code**:
```swift
Button("Visit fireside-project.org") {
    if let url = URL(string: "https://firesideproject.org") { UIApplication.shared.open(url) }
}
```

**What's wrong**: The button label displays "fireside-project.org" (with hyphen) but the URL it actually opens is "https://firesideproject.org" (no hyphen). These are different domain names. The label is factually wrong and would confuse users trying to find the resource independently.

**Replacement**:
```swift
Button("Visit firesideproject.org") {
```

---

## P2 — Polish & Consistency

### P2-1: Near-duplicate integration tips waste a rotation slot

**File**: `TripTalk/Views/Home/HomeView.swift:12` and `HomeView.swift:22`

**Current text**:
- Tip 4: `"Integration is as important as the experience itself. Take time to reflect."`
- Tip 14: `"Integration is as important as the experience itself. Give yourself time to process."`

**What's wrong**: Both tips open with an identical sentence, effectively doubling one message in a 14-item rotation. This is a missed opportunity for more varied safety guidance.

**Replacement** — replace tip 14 with:
```
"Speaking with a therapist or counselor after an experience can deepen integration and help process any difficult emotions that arise."
```

---

### P2-2: Nav title "Write Review" inconsistent with button label "Write a Review"

**File**: `TripTalk/Views/Reviews/WriteReviewView.swift:87`

**Current text**:
```swift
.navigationTitle("Write Review")
```

**What's wrong**: Every button that opens this sheet reads "Write a Review" (with "a"). The sheet's own navigation title omits the article, creating an inconsistency.

**Replacement**:
```swift
.navigationTitle("Write a Review")
```

---

### P2-3: Detail-view disclaimers are too brief and omit crisis resources

**Files**:
- `TripTalk/Views/Catalog/StrainDetailView.swift:152`
- `TripTalk/Views/Catalog/SubstanceDetailView.swift:175`

**Current text** (both files):
```
"For educational purposes only. Not medical advice."
```

**What's wrong**: HomeView carries a full disclaimer including crisis resources ("call 988 or text HOME to 741741"). Detail views — which contain the substance-specific content most likely to influence a user's decision — carry only a 7-word disclaimer with no crisis information. These are the highest-stakes screens for a harm-reduction disclaimer.

**Replacement**:
```
"For educational purposes only. Not medical, legal, or therapeutic advice. In crisis, call or text 988."
```

---

### P2-4: Home subtitle "safer experiences" makes an unqualifiable claim

**File**: `TripTalk/Views/Home/HomeView.swift:47`

**Current text**:
```
"Your guide to informed, safer experiences"
```

**What's wrong**: "Safer" is a relative comparative claim — safer than what? The app cannot guarantee safer outcomes. This phrasing risks implying a level of protection the app cannot provide.

**Replacement**:
```
"Your guide to informed, harm-aware experiences"
```

---

### P2-5: Hardcoded profile placeholder text shown to all users

**File**: `TripTalk/Views/Profile/ProfileView.swift:33–38`

**Current text**:
```swift
Text("Explorer")   // username
Text("Fort Collins, CO")   // location
```

**What's wrong**: Every user sees the same hardcoded username "Explorer" and location "Fort Collins, CO". This looks like unfilled placeholder data — unprofessional and misleading for users outside Colorado.

**Replacement**: Replace with user-configurable fields or remove until user profiles are implemented (e.g., `Text("Your Profile")`).

---

### P2-6: "62-FIRESIDE" display format is ambiguous

**Files**: `TripTalk/Views/Home/HomeView.swift:225`, `TripTalk/Views/Profile/ProfileView.swift:252`

**Current text** (HomeView alert):
```
"• Fireside Project Psychedelic Peer Support: 62-FIRESIDE"
```
**Current text** (ProfileView):
```
"Psychedelic peer support: 62-FIRESIDE"
```

**What's wrong**: "62-FIRESIDE" looks like a 9-character partial number (2 digits + dash + 8 letters = implying a 10-digit number starting with "62…"). The correct vanity format is "623-FIRESIDE" — showing the full 3-digit area code prefix before the dash. A user unfamiliar with vanity numbers will not know how to dial "62-FIRESIDE".

*Note: This also connects to P0-1 — the tel: link itself is wrong and must be fixed.*

**Replacement** (display text only):
```
"Fireside Project Psychedelic Peer Support: 623-FIRESIDE · (623) 473-7433"
```

---

### P2-7: "Would you try this again?" sounds casual/recreational in a harm-reduction context

**File**: `TripTalk/Views/Reviews/WriteTripReportView.swift:154`

**Current text**:
```swift
Toggle("Would you try this again?", isOn: $wouldRepeat)
```

**What's wrong**: "Try this again" frames repeat use as a desirable goal — recreational rather than therapeutic framing. In a harm-reduction context, neutral language is preferable.

**Replacement**:
```swift
Toggle("Would you choose this experience again?", isOn: $wouldRepeat)
```

---

### P2-8: "Community Photos" section shows only placeholders — heading misrepresents content

**File**: `TripTalk/Views/Catalog/StrainDetailView.swift:70–102`

**Current text**:
```swift
Text("Community Photos")
```
(followed by gray placeholder squares with a "photo" system icon)

**What's wrong**: The section header promises real community photographs, but the content is static gray placeholders. Users may interpret this as broken functionality or actual photos of a substance, which creates confusion about the app's capabilities.

**Replacement** (until real photos are implemented):
```swift
Text("Community Photos")
// Add subtitle:
Text("Photos coming soon as the community grows.")
    .font(.caption)
    .foregroundStyle(Color.ttTertiary)
```
Or remove the section entirely until the feature is implemented.

---

## Terminology Consistency

**Verdict: Generally consistent.** The app uses "variety/varieties" throughout the UI. "Strain" appears only in code identifiers (not user-facing strings). The one exception is the field label `species` in Strain data (e.g., "Ketamine HCl", "Psilocybe cubensis") — this field is not currently surfaced in UI text, so no action needed.

**Flag**: The ketamine section lists "forms" (IV Infusion, Sublingual Troche, etc.) under the same "varieties" taxonomy as mushroom varieties. If the catalog ever surfaces a sub-label explaining what "variety" means for ketamine, ensure it reads "administration route" rather than "variety" or "strain."

---

## Crisis Resources Accuracy Checklist

| Resource | Displayed Number | Tel Link | Status |
|----------|-----------------|----------|--------|
| 988 Suicide & Crisis Lifeline | 988 ✓ | `tel:988` ✓ | **Correct** |
| Crisis Text Line | "text HOME to 741741" ✓ | (text only, no link) | **Correct** |
| SAMHSA (age-gate underage alert) | 1-800-662-4357 ✓ | (not linked) | **Correct** |
| Fireside Project | "62-FIRESIDE" ✗ | `tel:6232737654` ✗ | **P0-1 — Fix required** |

---

*End of audit. 18 findings total. No Swift files were modified.*
