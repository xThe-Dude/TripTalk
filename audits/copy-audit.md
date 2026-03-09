# TripTalk Copy Audit
**Date:** 2026-03-09
**Auditor:** UX Copy Review (Senior)

---

## Onboarding

### [MEDIUM] Onboarding Screen 1 — Subtitle is generic and passive
**File:** Views/Onboarding/OnboardingView.swift:9
**Current:** "Explore detailed information about psychedelic substances and varieties. Make informed decisions with community-sourced knowledge."
**Proposed:** "Learn about psychedelic varieties with real knowledge from real people. Go in informed — every time."
**Rationale:** The current copy reads like a product spec. The rewrite is warmer, more human, and ends with a clear value proposition. "Community-sourced knowledge" is corporate jargon.

### [LOW] Onboarding Screen 2 — "explorers" is vague
**File:** Views/Onboarding/OnboardingView.swift:10
**Current:** "Read real trip reports and reviews from experienced explorers. Learn from shared experiences before your own journey."
**Proposed:** "Read honest trip reports from people who've been there. Learn what to expect before you go."
**Rationale:** "Experienced explorers" is euphemistic. "People who've been there" is direct and relatable. "Before your own journey" → "before you go" is tighter.

### [LOW] Onboarding Screen 3 — solid but slightly wordy
**File:** Views/Onboarding/OnboardingView.swift:11
**Current:** "Harm reduction is our foundation. Access dosage guidelines, safety tips, and find licensed service centers near you."
**Proposed:** "Safety comes first. Dosage guidelines, harm-reduction tips, and licensed service centers — all in one place."
**Rationale:** "Harm reduction is our foundation" is mission-statement language, not user-facing copy. Lead with what the user gets.

---

## Age Gate

### [HIGH] Age Gate — No exit path for underage users
**File:** Views/AgeGate/AgeGateView.swift
**Current:** Only a "I am 21+" button. No alternative for users under 21.
**Proposed:** Add a secondary text/button: "I'm under 21" that shows a dismissive message like "TripTalk is for adults 21 and older. Check back when you're eligible." or simply closes/exits.
**Rationale:** Apple Review and legal best practice: an age gate should offer both options. A single "confirm" button with no denial path is weak verification and may be flagged in App Store review.

### [MEDIUM] Age Gate — "TripTalk is for adults." is vague
**File:** Views/AgeGate/AgeGateView.swift:48
**Current:** "TripTalk is for adults."
**Proposed:** "You must be 21 or older to use TripTalk."
**Rationale:** "For adults" is ambiguous (18? 21?). State the requirement explicitly. The button says "21+" but the text doesn't reinforce it.

### [LOW] Age Gate — "Community Guidelines" link label
**File:** Views/AgeGate/AgeGateView.swift:62-65
**Current:** "By continuing you agree to our" + "Community Guidelines"
**Proposed:** "By continuing, you agree to our" + "Terms of Use & Community Guidelines"
**Rationale:** From a legal standpoint, "Community Guidelines" alone doesn't cover Terms of Service. If this is the only consent moment, it should reference both. Also missing: comma after "continuing."

---

## Navigation & Tab Labels

### [LOW] Tab label "Explore" vs "Home" overlap
**File:** ContentView.swift:9-24
**Current:** Tabs: Home, Explore, Catalog, Services, Profile
**Proposed:** Keep as-is, but consider renaming "Explore" → "Discover"
**Rationale:** "Explore" and "Home" (which already shows featured content, tips, recent reports) have overlapping mental models. "Discover" implies curation/browsing and differentiates better. Minor — current labels work.

---

## Button Labels

### [MEDIUM] "Submit" button on Trip Report and Review forms
**File:** Views/Reviews/WriteTripReportView.swift:124, Views/Reviews/WriteReviewView.swift:80
**Current:** "Submit"
**Proposed:** "Share Report" / "Share Review"
**Rationale:** "Submit" is clinical and impersonal. "Share" reinforces the community aspect and feels less like filling out a government form. Apple's HIG prefers specific, action-oriented labels.

### [LOW] "Learn more" on featured variety
**File:** Views/Home/HomeView.swift:76
**Current:** "Learn more"
**Proposed:** "View Details" or "Explore This Variety"
**Rationale:** "Learn more" is the most overused CTA on the internet. Something more specific tells users exactly what they'll get.

---

## Empty States

### [MEDIUM] Empty state for saved varieties — passive copy
**File:** Views/Profile/ProfileView.swift:108
**Current:** title: "No Saved Varieties", subtitle: "Browse the catalog and bookmark varieties you're interested in"
**Proposed:** title: "No Saved Varieties Yet", subtitle: "Bookmark varieties from the Catalog to find them here"
**Rationale:** "Yet" implies this is a temporary state. The rewrite is more concise and clearly connects the action (bookmark) to the result (find them here).

### [MEDIUM] Empty state for trip reports — vague CTA
**File:** Views/Profile/ProfileView.swift:122
**Current:** title: "No Trip Reports", subtitle: "Share your experiences to help the community"
**Proposed:** title: "No Trip Reports Yet", subtitle: "Write your first report from any variety's detail page"
**Rationale:** The current text tells users *why* but not *how*. The rewrite gives a clear path to action.

### [MEDIUM] Empty state for reviews — same issue
**File:** Views/Profile/ProfileView.swift:164
**Current:** title: "No Reviews Yet", subtitle: "Share your thoughts on substances and services"
**Proposed:** title: "No Reviews Yet", subtitle: "Leave a review from any substance or service page"
**Rationale:** Same pattern — tell users where to go, not just what to do.

### [LOW] Empty state for saved substances
**File:** Views/Profile/ProfileView.swift:138
**Current:** title: "No Saved Substances", subtitle: "Explore substances and save the ones you want to learn about"
**Proposed:** title: "No Saved Substances Yet", subtitle: "Bookmark substances to track them here"
**Rationale:** Tighter. Consistent "Yet" pattern.

### [LOW] Empty state for saved services
**File:** Views/Profile/ProfileView.swift:152
**Current:** title: "No Saved Services", subtitle: "Find licensed service centers near you"
**Proposed:** title: "No Saved Services Yet", subtitle: "Bookmark service centers from the Services tab"
**Rationale:** Consistent with other empty states. Gives location.

---

## Search Placeholders

### [LOW] Inconsistent search placeholder text
**File:** Views/Catalog/CatalogListView.swift:16 — "Search varieties..."
**File:** Views/Explore/ExploreView.swift:12 — "Search varieties, services..."
**File:** Views/Services/ServicesListView.swift:13 — "Search services..."
**Current:** Three different placeholders
**Proposed:** Keep all three — they're context-appropriate. But consider "Search by name…" for Catalog since users may also want to search by effect or substance type (which the pills already handle).
**Rationale:** The differentiation is actually correct UX — each search scopes differently. No change needed, but noting for awareness.

---

## Tip of the Day

### [MEDIUM] Only 4 tips — will repeat frequently
**File:** Views/Home/HomeView.swift:7-11
**Current:** 4 tips cycling by day-of-year
**Proposed:** Expand to 10-15 tips. Suggested additions:
- "Test your substance with a reagent kit when possible. Know what you're taking."
- "Hydrate before, during, and after. Your body will thank you."
- "Write down your intentions before the experience. They can be your anchor."
- "Avoid mixing substances, especially on your first experience."
- "Plan for the full duration plus afterglow time. Don't schedule obligations."
- "Music can profoundly shape the experience. Curate your playlist in advance."
- "If you feel overwhelmed, change one thing: the music, the room, your position."
- "Integration matters more than intensity. What you do after shapes the lasting impact."
- "Tell a trusted person what you're doing, even if they're not present."
- "It's okay to take a smaller dose than planned. You can always explore deeper next time."
**Rationale:** With only 4 tips, users see the same one for ~91 days straight. More variety keeps the feature fresh and increases harm-reduction coverage.

### [LOW] Tip 1 — minor phrasing
**File:** Views/Home/HomeView.swift:8
**Current:** "Start low, go slow. Especially with unfamiliar varieties."
**Proposed:** "Start low, go slow — especially with unfamiliar varieties."
**Rationale:** Em dash instead of sentence fragment. Reads as one cohesive thought.

---

## Trip Report Form

### [LOW] Section header "What stood out?" — inconsistent casing
**File:** Views/Reviews/WriteTripReportView.swift:96
**Current:** "What stood out?"
**Proposed:** Keep — this is great conversational copy. One of the best labels in the app.
**Rationale:** Noting as a positive. Warm, specific, inviting.

### [LOW] "Safety notes or tips?" placeholder
**File:** Views/Reviews/WriteTripReportView.swift:107
**Current:** Placeholder: "Any safety advice for others?"
**Proposed:** "What would you tell someone trying this for the first time?"
**Rationale:** More specific and personal. Taps into the user's empathy and generates better content.

### [MEDIUM] "Community Agreement" toggle text
**File:** Views/Reviews/WriteTripReportView.swift:116-119, Views/Reviews/WriteReviewView.swift:68-71
**Current:** "I confirm this report does not contain sourcing information, specific dosing instructions, or encouragement of illegal activity."
**Proposed:** "My report doesn't include sourcing info, specific doses, or encouragement of illegal activity."
**Rationale:** First person ("My report") instead of third-person formal ("I confirm this report") feels less legalistic. Same meaning, warmer tone. The legal protection is the toggle itself, not the wording.

---

## Terminology Consistency

### [HIGH] "Varieties" vs "Strains" — inconsistent throughout
**File:** Multiple
**Current:**
- Code uses `Strain`, `StrainCard`, `StrainDetailView`, `savedStrainIDs`, `strains`
- UI mostly uses "Varieties": "Popular Varieties", "Saved Varieties", "Search varieties..."
- But: `StrainDetailView` nav title shows `strain.name`, search refers to "varieties"
- Profile section "Saved Substances" exists alongside "Saved Varieties" — confusing overlap
**Proposed:** Pick **"Varieties"** for all user-facing text (it's less stigmatized and more accurate for non-mushroom items like ketamine forms). Keep `Strain` in code if refactoring is too costly. Ensure NO user-facing text says "strain."
**Rationale:** Consistency is critical. "Strain" carries cannabis/drug connotations. "Variety" is the deliberate, harm-reduction-friendly choice. Make sure it's airtight.

### [MEDIUM] "Substances" section in Profile — confusing vs "Varieties"
**File:** Views/Profile/ProfileView.swift:133
**Current:** "Saved Substances" section alongside "Saved Varieties"
**Proposed:** Consider renaming to "Saved Substance Guides" or adding a subtitle explaining the difference
**Rationale:** Users may not understand why there are both "Saved Varieties" and "Saved Substances." The hierarchy is Substance → Varieties, but this isn't explained anywhere in the UI.

---

## MockData Text Quality

### [LOW] Ketamine strain descriptions are clinical and flat
**File:** Data/MockData.swift (ketamine strains)
**Current:** "Administered intravenously in a clinical setting, typically over 40 minutes. Provides precise dosing control."
**Proposed:** "The gold standard for clinical ketamine therapy. Administered intravenously over ~40 minutes, IV infusion provides the most precise dosing control and consistent therapeutic response."
**Rationale:** The psilocybin and ayahuasca descriptions are rich and evocative. The ketamine forms read like medical pamphlets. Even clinical content deserves warmth.

### [LOW] Ketamine "species" field shows "Ketamine HCl" — misleading label
**File:** Data/MockData.swift (ketamine strains) + Views/Catalog/StrainDetailView.swift:19
**Current:** Species field shows "Ketamine HCl" or "Esketamine"
**Proposed:** The field label "species" doesn't make sense for ketamine. Consider showing "Formulation" or "Type" for non-mushroom/plant varieties, or hide the species line when it's a pharmaceutical.
**Rationale:** "Species: Ketamine HCl" is jarring. A mushroom has a species; a drug formulation doesn't.

---

## Microcopy

### [LOW] Success message after trip report submission
**File:** Views/Reviews/WriteTripReportView.swift:129
**Current:** "Trip report submitted! Thank you."
**Proposed:** "Your report is live. Thanks for sharing — the community benefits from every story."
**Rationale:** "Submitted" sounds transactional. The rewrite acknowledges the user's contribution.

### [LOW] Success message after review submission
**File:** Views/Reviews/WriteReviewView.swift:82
**Current:** "Review submitted! Thank you for contributing."
**Proposed:** "Your review is live. Thanks for helping others make informed choices."
**Rationale:** Ties back to the app's mission. More specific than generic "contributing."

### [LOW] Share text — overly long
**File:** Views/Catalog/StrainDetailView.swift:225
**Current:** "Check out [name] on TripTalk — [substance] variety, rated [x]⭐ with [n] community reports. A harm-reduction resource for informed experiences."
**Proposed:** "Check out [name] on TripTalk — [substance] variety, [x]⭐ from [n] reports."
**Rationale:** Share text should be scannable. The tagline "A harm-reduction resource..." is marketing copy that doesn't belong in a share snippet.

### [LOW] Home subtitle
**File:** Views/Home/HomeView.swift:29
**Current:** "Your guide to informed experiences"
**Proposed:** "Know more. Worry less."
**Rationale:** The current is descriptive but forgettable. The proposed is punchy, memorable, and captures the app's value in 4 words. (Alternatively, keep current — it's functional.)

---

## Filter Labels

### [LOW] "Difficulty" filter label
**File:** Views/Catalog/CatalogFilterSheet.swift (Section header)
**Current:** "Difficulty"
**Proposed:** "Experience Level"
**Rationale:** "Difficulty" implies something is hard. "Experience Level" matches the enum values better ("Beginner Friendly", "Intermediate", "Experienced") and doesn't have negative connotations.

### [LOW] StrainDetailView uses "Level" for difficulty
**File:** Views/Catalog/StrainDetailView.swift:60
**Current:** "Level"
**Proposed:** "Experience Level" (if space allows) or keep "Level" — it's fine for the compact stat bar
**Rationale:** Minor inconsistency between "Difficulty" in filters and "Level" on detail. Not critical.

---

## Tone Consistency

### [LOW] Overall tone assessment: **Strong**
The app maintains a warm, educational, harm-reduction-focused tone throughout. The MockData trip reports and reviews are particularly well-written — authentic, diverse in experience level, and consistently include safety advice. The onboarding → home → detail flow is cohesive.

**One gap:** The Profile view is more utilitarian and less warm than the rest. Adding a brief welcome message or context ("Your saved items and reports") would bring it in line.

---

## Accessibility Copy

### [MEDIUM] Potency dots lack visible text on StrainCard
**File:** Views/Components/StrainCard.swift (not read but referenced from StrainDetailView pattern)
**Current:** Potency shown as colored dots only in card view
**Proposed:** Ensure accessibility labels exist on all potency dot indicators (confirmed on StrainDetailView and MiniStrainCard — good). Verify StrainCard also has them.
**Rationale:** VoiceOver users need potency information. The detail view has good a11y labels; verify the card does too.

---

## Summary

| Severity | Count |
|----------|-------|
| HIGH     | 2     |
| MEDIUM   | 9     |
| LOW      | 16    |

**Top 3 priorities:**
1. **Age Gate needs a denial path** — App Store risk
2. **"Varieties" vs "Strains" consistency** — terminology leaks undermine the deliberate naming choice
3. **"Submit" → "Share"** on forms — low-effort, high-impact tone improvement
