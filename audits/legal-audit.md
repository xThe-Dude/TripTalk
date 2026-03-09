# TripTalk Legal & Compliance Audit

**Date:** 2026-03-09
**Auditor:** Legal/Compliance Review Agent
**Scope:** App Store approval risk, harm reduction framing, legal exposure

---

## Critical Findings

### [CRITICAL] Onboarding Page 3 References "Dosage Guidelines"
**File/Location:** `Views/Onboarding/OnboardingView.swift` — page 3 subtitle
**Issue:** Text says "Access dosage guidelines, safety tips, and find licensed service centers near you." The phrase "dosage guidelines" directly contradicts the App Store review notes which state "The app does not include dosing tools or calculators of any kind." Apple reviewers will read the onboarding and compare to the review notes — this is an immediate red flag.
**Apple Guideline:** 1.4.3 (Physical harm), also contradicts own review notes
**Fix:** Change to "Access safety information, preparation tips, and find licensed service centers near you."

### [CRITICAL] Age Gate is Trivially Bypassable — Single Tap, No Verification
**File/Location:** `Views/AgeGate/AgeGateView.swift`
**Issue:** The age gate is a single "I am 21+" button with no actual verification. It uses `@AppStorage("ageVerified")` which can be reset. While Apple doesn't require ID verification, a cautious reviewer may see this as insufficient for an app with "Frequent/Intense" drug references. There's no date-of-birth entry, no confirmation dialog, nothing beyond a single tap.
**Apple Guideline:** 1.4.3, Age Rating enforcement
**Fix:** Add a date-of-birth picker (month/year at minimum) with validation that the user is 21+. This is standard practice for alcohol/cannabis apps and shows good faith. Also add a confirmation alert: "Are you sure? This app contains mature content about psychedelic substances."

### [CRITICAL] Liberty Caps Trip Report Describes Wild Foraging
**File/Location:** `Data/MockData.swift` — Liberty Caps trip report by "ForestBather"
**Issue:** "Picked these wild and consumed them where they grew" describes foraging and consuming wild psilocybin mushrooms, which is illegal everywhere in the US except Oregon (in a licensed setting). This reads as encouraging illegal activity. The safety note tries to mitigate ("ONLY consume wild mushrooms if you're 100% certain of identification") but actually makes it worse — it provides guidance on HOW to do it safely rather than discouraging it.
**Apple Guideline:** 1.4.3 (Physical harm), 1.1.1 (Objectionable content)
**Fix:** Rewrite to describe attending a legal session: "Participated in a guided session featuring Liberty Caps. The experience felt ancient..." Remove all foraging references. Change safety note to generic preparation advice.

### [CRITICAL] Trip Reports Describe Illegal Use Without Legal Context
**File/Location:** `Data/MockData.swift` — multiple trip reports
**Issue:** Most trip reports describe personal use outside of any legal/clinical framework. The B+ reports describe casual home/social use, the Albino PE reports describe home use, the mescaline reports describe illegal substance use. Only ketamine (medical) and the Oregon service center reviews are clearly legal. An Apple reviewer could see this as normalizing/encouraging illegal drug use.
**Apple Guideline:** 1.4.3 (Physical harm)
**Fix:** Reframe trip reports to reference legal contexts: "During my session at a licensed service center..." or "In a therapeutic setting with my provider..." At minimum, remove reports for substances that are illegal everywhere (mescaline/ayahuasca) or add clear legal-context framing.

---

## High Severity Findings

### [HIGH] Profile Links Point to example.com Placeholder URLs
**File/Location:** `Views/Profile/ProfileView.swift` — Info section
**Issue:** Community Guidelines links to `https://example.com/guidelines`, Privacy Policy links to `https://example.com/privacy`, Terms of Service links to `https://example.com/terms`. Apple WILL tap these during review. Broken links = immediate rejection.
**Apple Guideline:** 2.1 (App Completeness), 5.1.1 (Privacy Policy)
**Fix:** Update to actual URLs: `https://xthe-dude.github.io/TripTalk/support.html` for guidelines, `https://xthe-dude.github.io/TripTalk/privacy.html` for privacy. Create a Terms of Service page or link to support page.

### [HIGH] No Terms of Service Page Exists
**File/Location:** `docs/` directory, `Views/Profile/ProfileView.swift`
**Issue:** Profile links to Terms of Service but no such page exists. Apple may require ToS for user-generated content apps.
**Apple Guideline:** 5.1.1 (Legal)
**Fix:** Create `docs/terms.html` with basic terms covering: acceptable use, prohibited content (sourcing, dosing advice, illegal activity encouragement), content ownership, disclaimers.

### [HIGH] No Disclaimer Visible in the App UI
**File/Location:** App-wide
**Issue:** The APPSTORE.md description includes a disclaimer ("TripTalk is an educational resource and does not provide medical advice...") but this text appears NOWHERE in the actual app UI. An Apple reviewer could note that the app presents substance information, effects, and safety notes without any visible disclaimer that this is not medical advice.
**Apple Guideline:** 5.2.1 (Legal), 1.4.3
**Fix:** Add a persistent disclaimer footer or a disclaimer section visible in: (1) the Home view, (2) each SubstanceDetailView, and (3) the Profile/About section. Text: "TripTalk is an educational harm-reduction resource. It does not provide medical advice. Consult a healthcare provider before making health decisions. Psilocybin and other substances discussed remain controlled in most jurisdictions."

### [HIGH] Fake Service Centers with Real-Looking Addresses
**File/Location:** `Data/MockData.swift` — services array
**Issue:** Service centers have specific street addresses (e.g., "412 Laurel St, Fort Collins, CO 80521", "2847 SE Hawthorne Blvd, Portland, OR 97214"). If these are real addresses of businesses/residences that are NOT psilocybin service centers, this could cause real-world harm (people showing up) and legal issues. Apple may also verify these.
**Apple Guideline:** 1.4.3, 5.2.1
**Fix:** Either: (1) use clearly fictional addresses or add "Example listing — not a real service center" disclaimer, or (2) verify these are actual licensed service centers with consent to be listed. For v1 with mock data, use obvious placeholders or add a banner: "Sample listings for demonstration purposes."

### [HIGH] Content Moderation Gap — Report Button Without Backend
**File/Location:** Support FAQ mentions "Tap the flag icon... Flagged content is reviewed against our community guidelines"
**Issue:** The FAQ implies active content moderation ("Flagged content is reviewed"), but there's no server, no moderation system, and data is local-only. If Apple asks about moderation of UGC (user-generated content), this is a problem. Apple Guideline 1.2 requires apps with UGC to have: content filtering, reporting mechanism, blocking, and the ability to remove content.
**Apple Guideline:** 1.2 (User Generated Content)
**Fix:** Since all data is local-only, clarify in the FAQ and review notes that user-generated content is stored only on the user's own device and is not shared with other users. This exempts the app from UGC moderation requirements. Update FAQ: "TripTalk stores all content locally on your device. Content you create is visible only to you."

### [HIGH] Ayahuasca Trip Report Contains Preparation Instructions
**File/Location:** `Data/MockData.swift` — Caapi + Chacruna trip report safety notes
**Issue:** "Requires strict MAOI diet 2 weeks before. DO NOT mix with SSRIs—this is life-threatening." While framed as safety, this is preparation guidance for consuming an illegal substance. The Caapi + Mimosa description says "Same dietary restrictions as traditional ayahuasca." These read as instructions.
**Apple Guideline:** 1.4.3 (Physical harm)
**Fix:** Reframe as clinical/educational: "Ayahuasca has dangerous interactions with SSRIs and many medications. Consult a healthcare provider." Remove specific dietary preparation timelines.

---

## Medium Severity Findings

### [MEDIUM] App Store Category "Health & Fitness" May Invite Scrutiny
**File/Location:** `APPSTORE.md` — Category
**Issue:** "Health & Fitness" implies the app provides health guidance. This sets Apple reviewer expectations for medical accuracy and could trigger Guideline 5.2.1 scrutiny. Combined with substance information, this could be seen as providing unqualified health advice.
**Apple Guideline:** 5.2.1 (Legal — Medical)
**Fix:** Consider "Education" as primary category instead. Secondary can remain "Health & Fitness."

### [MEDIUM] Peyote Description May Offend — Cultural Sensitivity
**File/Location:** `Data/MockData.swift` — Peyote strain and trip report
**Issue:** Including Peyote with user "reviews" and ratings could be seen as disrespectful to Native American religious practices. The trip report "Honored to participate in a NAC ceremony" implies the user participated in a Native American Church ceremony, which is legally restricted to enrolled members. Rating sacred ceremonial medicine alongside recreational strains could draw criticism.
**Apple Guideline:** 1.1.1 (Objectionable content — religious sensitivity)
**Fix:** Either remove Peyote entirely, or add a prominent cultural sensitivity disclaimer. Consider removing the star rating from Peyote and ceremonial substances. At minimum, add: "Peyote use is legally restricted to enrolled members of the Native American Church."

### [MEDIUM] Strain Descriptions Read as Promotional
**File/Location:** `Data/MockData.swift` — strain descriptions
**Issue:** Several descriptions use promotional language: "beloved for their reliable, gentle introduction," "fantastic choice for beginners," "offering a positive, uplifting experience." This reads more like a product catalog than harm-reduction education. An Apple reviewer could interpret this as promoting drug use.
**Apple Guideline:** 1.4.3 (Physical harm)
**Fix:** Rewrite descriptions in neutral, encyclopedic tone. Instead of "beloved for their reliable, gentle introduction" → "Commonly reported effects include moderate visual changes and introspective states. Often cited in community reports as having predictable effects." Remove superlatives and recommendations.

### [MEDIUM] "Would you try this again?" Toggle in Trip Reports
**File/Location:** `Views/Reviews/WriteTripReportView.swift`
**Issue:** This toggle normalizes repeated use and could be seen as encouraging ongoing drug consumption. The mock data shows most reports with `wouldRepeat: true`.
**Apple Guideline:** 1.4.3
**Fix:** Reframe as "Was this experience valuable for your personal growth?" or remove entirely.

### [MEDIUM] Subtitle Options May Be Flagged
**File/Location:** `APPSTORE.md` — subtitle
**Issue:** "Safe Psychedelic Experiences" could be interpreted as claiming psychedelic use is safe, which is a medical claim. "Informed Psychedelic Experiences" is better but still implies the app facilitates experiences rather than providing education.
**Apple Guideline:** 5.2.1 (Medical claims)
**Fix:** Use subtitle: "Psychedelic Safety & Education" or "Harm Reduction Resource"

### [MEDIUM] Jurisdiction Status for California Shows "Decriminalized" for Psilocybin
**File/Location:** `Data/MockData.swift` — psilocybin jurisdictionStatuses
**Issue:** California psilocybin is listed as `.decriminalized`. As of early 2026, California has not decriminalized psilocybin statewide (SB 58 was vetoed in 2023). Some cities have deprioritized enforcement but that's different from decriminalization. Inaccurate legal information is a liability.
**Apple Guideline:** 5.2.1 (Legal)
**Fix:** Verify current legal status. If not actually decriminalized statewide, change to `.illegal` or add city-level granularity. Add disclaimer: "Legal information is provided for general reference only and may not reflect the most current laws. Consult a legal professional."

### [MEDIUM] No Emergency Resources or Crisis Hotline
**File/Location:** App-wide
**Issue:** An app about psychedelic experiences with no crisis resources (988 Suicide & Crisis Lifeline, Fireside Project psychedelic peer support line) could be seen as negligent. This is also something Apple reviewers may look for in harm-reduction apps.
**Apple Guideline:** 1.4.3 (Physical harm — safety)
**Fix:** Add emergency resources section: 988 Suicide & Crisis Lifeline, Fireside Project (62-FIRESIDE), Poison Control (1-800-222-1222). Include in Safety sections and make accessible from Home.

---

## Low Severity Findings

### [LOW] Privacy Policy Uses "privacy@triptalk.app" — Domain May Not Exist
**File/Location:** `docs/privacy.html`, `docs/support.html`
**Issue:** Contact emails use `triptalk.app` domain. If this domain isn't registered with working email, Apple may flag it.
**Fix:** Ensure email addresses are functional before submission, or use a working alternative.

### [LOW] "Community Photos" Section Shows Placeholder Content
**File/Location:** `Views/Catalog/StrainDetailView.swift`
**Issue:** Community Photos shows colored rectangles with a photo icon. While clearly placeholder, this could look unfinished during review.
**Apple Guideline:** 2.1 (App Completeness)
**Fix:** Either remove the section for v1 or add "Coming soon" label.

### [LOW] Share Text Could Be More Cautious
**File/Location:** `Views/Catalog/StrainDetailView.swift` — `strainShareText`
**Issue:** "Check out Golden Teachers on TripTalk" sounds like sharing a product recommendation rather than educational content.
**Fix:** Change to: "Learn about Golden Teachers on TripTalk — a harm-reduction resource for psychedelic safety education."

### [LOW] App Store Description Says "Strain & Species Catalog"
**File/Location:** `APPSTORE.md`
**Issue:** "Strain" is cannabis/drug industry terminology. While technically correct for mushroom varieties, it may trigger automated keyword flags.
**Fix:** Already using "Varieties" in some places — standardize on "Varieties & Species Catalog" throughout.

### [LOW] No "Not Medical Advice" in Safety Notes
**File/Location:** `Data/MockData.swift` — substance safetyNotes
**Issue:** Safety notes like "Not recommended for those with a personal or family history of psychosis" read as medical advice without qualification.
**Fix:** Prepend each safety notes section with: "The following community-sourced information is not medical advice. Consult a healthcare provider."

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 4 |
| High | 6 |
| Medium | 6 |
| Low | 5 |
| **Total** | **21** |

### Top 5 Must-Fix Before Submission
1. **Fix onboarding "dosage guidelines" text** — direct contradiction of review notes
2. **Fix placeholder URLs in Profile** — instant rejection
3. **Strengthen age gate** with DOB picker
4. **Reframe trip reports in legal contexts** — biggest 1.4.3 risk
5. **Add in-app disclaimer** — no medical advice disclaimer anywhere in UI

### Assessment
The app is well-designed with strong harm-reduction intent, but several content and compliance issues could result in App Store rejection under Guideline 1.4.3 (Physical Harm). The primary risk is that trip reports and strain descriptions read as promoting/normalizing illegal drug use rather than providing neutral educational information. The broken placeholder URLs are an automatic rejection. With the fixes above, the app has a reasonable path to approval — the precedent of TripSit, DanceSafe, and similar apps existing on the App Store is favorable.
