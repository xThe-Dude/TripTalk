import Foundation

/// Client-side content filter for UGC submissions.
/// Checks for sourcing language, slurs, explicit content, and dosage advice.
enum ContentFilter {

    /// Returns a rejection reason if the text contains prohibited content, or nil if clean.
    static func check(_ text: String) -> String? {
        let lowered = text.lowercased()

        // Sourcing / vendor language
        let sourcingPatterns = [
            "where (can i|to) (buy|get|find|order|source)",
            "for sale", "vendor", "plug", "dealer",
            "wickr", "telegram.*sell", "sell.*telegram",
            "shipping", "discrete packaging"
        ]
        for pattern in sourcingPatterns {
            if lowered.range(of: pattern, options: .regularExpression) != nil {
                return "Your submission appears to contain sourcing or vendor information, which is not allowed."
            }
        }

        // Dosage advice
        let dosagePatterns = [
            "\\bhow (much|many) (to|should)",
            "\\b\\d+(\\.\\d+)?\\s*(g|gram|mg|milligram|ug|microgram|tab|hit)",
            "\\bheroic dose\\b",
            "\\bmicrodose protocol\\b"
        ]
        for pattern in dosagePatterns {
            if lowered.range(of: pattern, options: .regularExpression) != nil {
                return "Your submission appears to contain dosage information. TripTalk does not provide dosage advice."
            }
        }

        // Slurs and explicit hate speech (abbreviated list — extend as needed)
        let slurPatterns = [
            "\\bn[i1][g9]{2}[e3]r\\b",
            "\\bf[a@][g9]{2}[o0]t\\b",
            "\\bk[i1]k[e3]\\b",
            "\\bsp[i1]c\\b",
            "\\btr[a@]nn[y1]\\b"
        ]
        for pattern in slurPatterns {
            if lowered.range(of: pattern, options: .regularExpression) != nil {
                return "Your submission contains language that violates our community guidelines."
            }
        }

        return nil
    }
}
