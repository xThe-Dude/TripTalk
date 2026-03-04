import Foundation

struct MockData {
    // MARK: - Substance IDs (stable for review references)
    static let psilocybinID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let ayahuascaID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let mescalineID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let lsdID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let mdmaID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let ketamineID = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!

    static let serviceID1 = UUID(uuidString: "00000000-0000-0000-0001-000000000001")!
    static let serviceID2 = UUID(uuidString: "00000000-0000-0000-0001-000000000002")!
    static let serviceID3 = UUID(uuidString: "00000000-0000-0000-0001-000000000003")!
    static let serviceID4 = UUID(uuidString: "00000000-0000-0000-0001-000000000004")!

    // MARK: - Substances
    static let substances: [Substance] = [
        Substance(
            id: psilocybinID,
            name: "Psilocybin Mushrooms",
            category: .psychedelic,
            about: "Psilocybin mushrooms are fungi containing the psychoactive compounds psilocybin and psilocin. Used for centuries in indigenous ceremonies, they are now the subject of extensive clinical research for depression, anxiety, and PTSD. Experiences typically last 4-6 hours and can range from gentle mood elevation to profound mystical states.",
            effects: [.visualDistortions, .introspection, .spiritualExperience, .euphoria, .creativity, .emotionalRelease, .nausea],
            safetyNotes: [
                "Always have a trusted sitter present, especially for first experiences.",
                "Set and setting profoundly influence the experience.",
                "Avoid combining with lithium or tramadol.",
                "Not recommended for those with a personal or family history of psychosis.",
                "Start with a comfortable environment you know well."
            ],
            jurisdictionStatuses: [
                .colorado: .decriminalized,
                .oregon: .legal,
                .california: .decriminalized,
                .national: .illegal
            ],
            averageRating: 4.7,
            reviewCount: 142,
            imageSymbol: "leaf.fill"
        ),
        Substance(
            id: ayahuascaID,
            name: "Ayahuasca",
            category: .psychedelic,
            about: "Ayahuasca is a traditional plant medicine brew originating from the Amazon basin, typically combining Banisteriopsis caapi vine with Psychotria viridis leaves. It has been used in indigenous spiritual practices for centuries. The experience is often described as deeply introspective and emotionally cathartic, lasting 4-8 hours.",
            effects: [.spiritualExperience, .emotionalRelease, .introspection, .visualDistortions, .nausea, .dissolution],
            safetyNotes: [
                "Requires careful dietary preparation (MAOI interactions).",
                "Should only be taken with experienced facilitators.",
                "Purging (vomiting) is a common and expected part of the experience.",
                "Dangerous interactions with SSRIs, SNRIs, and many other medications.",
                "Screen for cardiovascular conditions before participation."
            ],
            jurisdictionStatuses: [
                .colorado: .illegal,
                .oregon: .underReview,
                .california: .illegal,
                .national: .illegal
            ],
            averageRating: 4.8,
            reviewCount: 87,
            imageSymbol: "drop.fill"
        ),
        Substance(
            id: mescalineID,
            name: "Mescaline (Peyote / San Pedro)",
            category: .psychedelic,
            about: "Mescaline is a naturally occurring psychedelic found in several cactus species, most notably Peyote and San Pedro. It has a long history of ceremonial use among Native American and South American indigenous peoples. The experience is known for vivid visual enhancement, a strong body component, and a sense of connection to nature.",
            effects: [.visualDistortions, .euphoria, .spiritualExperience, .bodyHigh, .creativity, .synesthesia, .nausea],
            safetyNotes: [
                "Peyote is sacred to many indigenous cultures—approach with respect.",
                "Duration is long (8-12 hours); plan accordingly.",
                "Nausea is common in the initial phase.",
                "Stay hydrated throughout the experience.",
                "Not recommended for those with heart conditions."
            ],
            jurisdictionStatuses: [
                .colorado: .illegal,
                .oregon: .illegal,
                .california: .illegal,
                .national: .illegal
            ],
            averageRating: 4.5,
            reviewCount: 34,
            imageSymbol: "sun.max.fill"
        ),
        Substance(
            id: lsdID,
            name: "LSD",
            category: .psychedelic,
            about: "Lysergic acid diethylamide (LSD) is a semisynthetic psychedelic first synthesized in 1938. Known for its potent effects at very small quantities, LSD produces profound alterations in perception, thought, and feeling. Clinical research has shown promise for treating anxiety, depression, and substance use disorders.",
            effects: [.visualDistortions, .euphoria, .creativity, .introspection, .synesthesia, .energizing, .anxiety],
            safetyNotes: [
                "Effects last 8-12 hours; ensure a safe, comfortable environment.",
                "Test substances with reagent kits when possible.",
                "A calm, trusted companion can help navigate difficult moments.",
                "Avoid driving or operating machinery.",
                "Not recommended for individuals with psychotic disorders."
            ],
            jurisdictionStatuses: [
                .colorado: .illegal,
                .oregon: .illegal,
                .california: .illegal,
                .national: .illegal
            ],
            averageRating: 4.6,
            reviewCount: 198,
            imageSymbol: "diamond.fill"
        ),
        Substance(
            id: mdmaID,
            name: "MDMA",
            category: .empathogen,
            about: "MDMA (3,4-methylenedioxymethamphetamine) is an empathogenic compound known for producing feelings of emotional closeness, empathy, and well-being. Originally used in psychotherapy in the 1970s, it has recently completed Phase 3 clinical trials for PTSD treatment with breakthrough therapy designation from the FDA.",
            effects: [.empathy, .euphoria, .emotionalRelease, .energizing, .relaxation, .bodyHigh],
            safetyNotes: [
                "Overheating and dehydration are serious risks—stay cool and hydrated.",
                "Avoid combining with other serotonergic substances.",
                "Allow adequate recovery time between experiences.",
                "Test substances with reagent kits to verify purity.",
                "Not recommended for those with heart conditions or hypertension."
            ],
            jurisdictionStatuses: [
                .colorado: .illegal,
                .oregon: .illegal,
                .california: .illegal,
                .national: .underReview
            ],
            averageRating: 4.4,
            reviewCount: 156,
            imageSymbol: "heart.circle.fill"
        ),
        Substance(
            id: ketamineID,
            name: "Ketamine",
            category: .dissociative,
            about: "Ketamine is a dissociative anesthetic that has gained significant attention for its rapid-acting antidepressant properties. FDA-approved as esketamine (Spravato) nasal spray for treatment-resistant depression, ketamine therapy is now offered at hundreds of clinics across the United States under medical supervision.",
            effects: [.dissociation, .relaxation, .introspection, .euphoria, .bodyHigh, .visualDistortions],
            safetyNotes: [
                "Medical supervision is strongly recommended.",
                "Do not drive or operate heavy machinery after treatment.",
                "Bladder issues can occur with frequent use.",
                "Avoid combining with alcohol or benzodiazepines.",
                "Inform your provider about all current medications."
            ],
            jurisdictionStatuses: [
                .colorado: .medicalOnly,
                .oregon: .medicalOnly,
                .california: .medicalOnly,
                .national: .medicalOnly
            ],
            averageRating: 4.3,
            reviewCount: 211,
            imageSymbol: "waveform.path.ecg"
        )
    ]

    // MARK: - Service Centers
    static let services: [ServiceCenter] = [
        ServiceCenter(
            id: serviceID1,
            name: "Rocky Mountain Mycelium Center",
            city: "Fort Collins",
            state: "CO",
            address: "412 Laurel St, Fort Collins, CO 80521",
            about: "A state-licensed psilocybin service center nestled in the foothills of the Rocky Mountains. Our experienced facilitators provide guided sessions in a serene, nature-inspired setting with comprehensive preparation and integration support.",
            offerings: ["Guided Psilocybin Sessions", "Preparation Counseling", "Integration Therapy", "Group Ceremonies", "Nature Walk Integration"],
            isVerified: true,
            averageRating: 4.9,
            reviewCount: 67,
            distanceMiles: 12,
            imageSymbol: "mountain.2.fill"
        ),
        ServiceCenter(
            id: serviceID2,
            name: "Cascade Healing Arts",
            city: "Portland",
            state: "OR",
            address: "2847 SE Hawthorne Blvd, Portland, OR 97214",
            about: "Oregon's premier psilocybin therapy center offering personalized healing journeys. Our team of licensed facilitators combines evidence-based approaches with compassionate care in a beautifully designed therapeutic space.",
            offerings: ["Individual Psilocybin Therapy", "Couples Sessions", "Integration Circles", "Preparation Workshops", "Aftercare Programs"],
            isVerified: true,
            averageRating: 4.8,
            reviewCount: 93,
            distanceMiles: 1024,
            imageSymbol: "water.waves"
        ),
        ServiceCenter(
            id: serviceID3,
            name: "Aspen Mind Wellness",
            city: "Denver",
            state: "CO",
            address: "1560 Broadway, Suite 300, Denver, CO 80202",
            about: "A modern ketamine-assisted therapy clinic in the heart of Denver. Our board-certified physicians and licensed therapists offer IV ketamine infusions and integration psychotherapy for treatment-resistant depression, anxiety, and PTSD.",
            offerings: ["IV Ketamine Infusions", "Ketamine-Assisted Psychotherapy", "Spravato (Esketamine)", "Integration Therapy", "Psychiatric Evaluation"],
            isVerified: true,
            averageRating: 4.6,
            reviewCount: 124,
            distanceMiles: 50,
            imageSymbol: "brain.head.profile"
        ),
        ServiceCenter(
            id: serviceID4,
            name: "Willamette Valley Retreat",
            city: "Eugene",
            state: "OR",
            address: "890 Willamette St, Eugene, OR 97401",
            about: "A retreat-style psilocybin service center set on 20 acres of forested land. We offer multi-day immersive experiences combining psilocybin sessions with yoga, meditation, and nature-based practices for deep personal transformation.",
            offerings: ["Weekend Retreats", "5-Day Immersive Programs", "Guided Psilocybin Sessions", "Yoga & Meditation", "Forest Bathing"],
            isVerified: false,
            averageRating: 4.7,
            reviewCount: 41,
            distanceMiles: 1089,
            imageSymbol: "tree.fill"
        )
    ]

    // MARK: - Reviews
    static let reviews: [Review] = {
        let cal = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now)! }

        return [
            Review(id: UUID(), authorName: "MountainSeeker", rating: 5, title: "Life-changing experience at Rocky Mountain", body: "I went in feeling lost and came out with a profound sense of clarity. The facilitators were incredibly supportive and the setting was perfect. The nature walk integration the next day really helped cement the insights.", tags: [.spiritualExperience, .introspection, .emotionalRelease], date: daysAgo(2), substanceID: psilocybinID, serviceID: serviceID1, helpfulCount: 24),
            Review(id: UUID(), authorName: "NeuroscienceNerd", rating: 4, title: "Ketamine therapy helped my treatment-resistant depression", body: "After years of trying different SSRIs with limited success, ketamine therapy at Aspen Mind gave me my first real relief. The medical team was professional and attentive. I noticed improvement after the second session.", tags: [.relaxation, .emotionalRelease, .dissociation], date: daysAgo(5), substanceID: ketamineID, serviceID: serviceID3, helpfulCount: 31),
            Review(id: UUID(), authorName: "GardenWanderer", rating: 5, title: "Psilocybin opened doors I didn't know existed", body: "My guided session helped me process grief I'd been carrying for years. The preparation sessions were thorough and made me feel completely safe. Highly recommend having proper support.", tags: [.introspection, .emotionalRelease, .spiritualExperience], date: daysAgo(7), substanceID: psilocybinID, helpfulCount: 18),
            Review(id: UUID(), authorName: "PacificDreamer", rating: 5, title: "Cascade Healing is world-class", body: "The team at Cascade truly cares about every aspect of the experience. From preparation to integration, every detail was thoughtful. The space itself is gorgeous—calming, warm, and intentionally designed.", tags: [.euphoria, .spiritualExperience, .emotionalRelease], date: daysAgo(10), substanceID: psilocybinID, serviceID: serviceID2, helpfulCount: 42),
            Review(id: UUID(), authorName: "DesertSage", rating: 4, title: "San Pedro ceremony was deeply moving", body: "A long but rewarding experience. The connection to nature and to the ceremonial tradition was palpable. The nausea was challenging but passed. I felt a deep sense of peace for weeks afterward.", tags: [.spiritualExperience, .bodyHigh, .nausea, .introspection], date: daysAgo(14), substanceID: mescalineID, helpfulCount: 11),
            Review(id: UUID(), authorName: "CosmicTraveler", rating: 5, title: "LSD helped unlock my creativity", body: "Under safe conditions with a trusted friend, the experience was profoundly creative. I spent hours drawing and writing—ideas flowed effortlessly. The enhanced pattern recognition was remarkable.", tags: [.creativity, .visualDistortions, .synesthesia, .euphoria], date: daysAgo(18), substanceID: lsdID, helpfulCount: 27),
            Review(id: UUID(), authorName: "HealingHeart", rating: 5, title: "MDMA therapy changed my relationship", body: "In a therapeutic context, MDMA allowed me and my partner to communicate with a level of honesty and empathy we'd never reached. It wasn't recreational—it was genuinely therapeutic and deeply healing.", tags: [.empathy, .emotionalRelease, .euphoria], date: daysAgo(21), substanceID: mdmaID, helpfulCount: 36),
            Review(id: UUID(), authorName: "ForestBather", rating: 4, title: "Willamette Valley retreat was peaceful", body: "The multi-day format allowed for deep preparation and integration. The forest setting is stunning. I wish the facilitator-to-participant ratio was a bit lower, but overall a wonderful experience.", tags: [.relaxation, .introspection, .spiritualExperience], date: daysAgo(3), substanceID: psilocybinID, serviceID: serviceID4, helpfulCount: 15),
            Review(id: UUID(), authorName: "MindfulExplorer", rating: 3, title: "Ketamine was helpful but intense", body: "The dissociative effects were stronger than I expected. The clinic staff were responsive and reassuring. Results were positive for my anxiety, though I needed a few sessions to really feel the benefit.", tags: [.dissociation, .anxiety, .relaxation], date: daysAgo(25), substanceID: ketamineID, serviceID: serviceID3, helpfulCount: 19),
            Review(id: UUID(), authorName: "RiverStone", rating: 5, title: "Ayahuasca was the hardest and best thing I've done", body: "Deeply challenging but profoundly transformative. The purging was intense but felt like a real release. I worked through trauma I'd suppressed for decades. Having experienced facilitators was essential.", tags: [.spiritualExperience, .emotionalRelease, .nausea, .dissolution], date: daysAgo(30), substanceID: ayahuascaID, helpfulCount: 53),
            Review(id: UUID(), authorName: "QuantumLeap", rating: 4, title: "Second psilocybin session was even better", body: "Building on insights from my first experience, the second session went deeper. The integration support at Rocky Mountain is excellent—they really help you make sense of everything.", tags: [.introspection, .creativity, .euphoria], date: daysAgo(8), substanceID: psilocybinID, serviceID: serviceID1, helpfulCount: 12),
            Review(id: UUID(), authorName: "StarGazer", rating: 2, title: "Not ready for this intensity", body: "I think I underestimated the preparation needed. The experience was overwhelming and I struggled to integrate it afterward. Doing more preparation work now and may try again when I'm ready.", tags: [.anxiety, .visualDistortions], date: daysAgo(35), substanceID: lsdID, helpfulCount: 44),
            Review(id: UUID(), authorName: "SunflowerChild", rating: 5, title: "Microdosing psilocybin improved my daily life", body: "While not a full journey, working with a guide to develop a mindful microdosing practice has noticeably improved my mood, focus, and creative output over the past three months.", tags: [.creativity, .euphoria, .introspection], date: daysAgo(1), substanceID: psilocybinID, helpfulCount: 29),
            Review(id: UUID(), authorName: "WildSage", rating: 4, title: "MDMA-assisted therapy for PTSD", body: "After two sessions in a clinical setting, my PTSD symptoms have significantly decreased. The empathogenic effects allowed me to revisit traumatic memories without being overwhelmed. Grateful for this option.", tags: [.empathy, .emotionalRelease, .relaxation], date: daysAgo(12), substanceID: mdmaID, helpfulCount: 38)
        ]
    }()
}
