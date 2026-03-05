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

    // MARK: - Strain IDs
    static let goldenTeachersID = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let albinoPEID = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    static let bPlusID = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
    static let libertyCapsID = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
    static let blueMeanieID = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!
    static let mazatecID = UUID(uuidString: "10000000-0000-0000-0000-000000000006")!
    static let caapiCharunaID = UUID(uuidString: "10000000-0000-0000-0000-000000000007")!
    static let caapiMimosaID = UUID(uuidString: "10000000-0000-0000-0000-000000000008")!
    static let sanPedroID = UUID(uuidString: "10000000-0000-0000-0000-000000000009")!
    static let peyoteID = UUID(uuidString: "10000000-0000-0000-0000-000000000010")!
    static let peruvianTorchID = UUID(uuidString: "10000000-0000-0000-0000-000000000011")!
    static let standardTabID = UUID(uuidString: "10000000-0000-0000-0000-000000000012")!
    static let microdoseID = UUID(uuidString: "10000000-0000-0000-0000-000000000013")!

    // MARK: - Strains
    static let strains: [Strain] = [
        Strain(id: goldenTeachersID, name: "Golden Teachers", parentSubstance: .psilocybin, species: "Psilocybe cubensis", potency: .moderate, description: "One of the most popular and well-known psilocybin strains. Golden Teachers are beloved for their reliable, gentle introduction to psychedelic experiences. They produce warm visuals, a sense of connection, and introspective clarity without overwhelming intensity.", commonEffects: [.visualDistortions, .introspection, .euphoria], bodyFeel: [.warm, .light], emotionalProfile: [.calm, .introspective, .euphoric], onset: "30-60 min", duration: "4-6 hours", difficulty: .beginner, averageRating: 4.7, reviewCount: 89, communityPhotoCount: 34),
        Strain(id: albinoPEID, name: "Albino Penis Envy", parentSubstance: .psilocybin, species: "Psilocybe cubensis", potency: .veryStrong, description: "A potent variant of the famous Penis Envy strain with albino coloring. Known for intense visuals, deep physical sensations, and powerful ego dissolution. Not recommended for beginners—this strain demands respect and preparation.", commonEffects: [.visualDistortions, .dissolution, .bodyHigh, .spiritualExperience], bodyFeel: [.heavy, .tingly, .warm], emotionalProfile: [.profound, .euphoric], onset: "20-45 min", duration: "5-7 hours", difficulty: .experienced, averageRating: 4.8, reviewCount: 56, communityPhotoCount: 22),
        Strain(id: bPlusID, name: "B+", parentSubstance: .psilocybin, species: "Psilocybe cubensis", potency: .moderate, description: "B+ is a versatile, forgiving strain known for its warm euphoria and gentle visuals. It's a fantastic choice for beginners, offering a positive, uplifting experience with minimal body load and a clear-headed quality.", commonEffects: [.euphoria, .relaxation, .creativity], bodyFeel: [.light, .warm, .relaxed], emotionalProfile: [.calm, .euphoric, .giggly], onset: "30-60 min", duration: "4-5 hours", difficulty: .beginner, averageRating: 4.5, reviewCount: 72, communityPhotoCount: 18),
        Strain(id: libertyCapsID, name: "Liberty Caps", parentSubstance: .psilocybin, species: "Psilocybe semilanceata", potency: .strong, description: "Wild-growing across temperate regions, Liberty Caps are one of the most potent naturally occurring psilocybin mushrooms. They produce vivid visuals, deep spiritual states, and a strong sense of awe and wonder at the natural world.", commonEffects: [.visualDistortions, .spiritualExperience, .introspection], bodyFeel: [.tingly, .light, .energetic], emotionalProfile: [.profound, .introspective], onset: "20-40 min", duration: "4-6 hours", difficulty: .intermediate, averageRating: 4.6, reviewCount: 41, communityPhotoCount: 12),
        Strain(id: blueMeanieID, name: "Blue Meanie", parentSubstance: .psilocybin, species: "Panaeolus cyanescens", potency: .strong, description: "Blue Meanies are a potent strain known for intense visual experiences and waves of euphoria. The name comes from their tendency to bruise blue. They produce a more energetic, colorful trip compared to cubensis varieties.", commonEffects: [.visualDistortions, .euphoria, .energizing], bodyFeel: [.energetic, .tingly, .light], emotionalProfile: [.euphoric, .giggly], onset: "15-30 min", duration: "4-6 hours", difficulty: .intermediate, averageRating: 4.4, reviewCount: 38, communityPhotoCount: 15),
        Strain(id: mazatecID, name: "Mazatec", parentSubstance: .psilocybin, species: "Psilocybe cubensis", potency: .moderate, description: "Named after the Mazatec people of Oaxaca, Mexico, who have used psilocybin mushrooms ceremonially for centuries. This strain is known for its spiritual depth and introspective quality, often producing profound insights and a sense of sacred connection.", commonEffects: [.spiritualExperience, .introspection, .emotionalRelease], bodyFeel: [.warm, .relaxed], emotionalProfile: [.profound, .introspective, .calm], onset: "30-60 min", duration: "4-6 hours", difficulty: .intermediate, averageRating: 4.6, reviewCount: 29, communityPhotoCount: 8),
        Strain(id: caapiCharunaID, name: "Caapi + Chacruna", parentSubstance: .ayahuasca, species: "B. caapi + P. viridis", potency: .strong, description: "The traditional Amazonian ayahuasca brew combining Banisteriopsis caapi vine with Psychotria viridis (Chacruna) leaves. This is the classic recipe used by indigenous healers, producing deeply spiritual visions, emotional catharsis, and often profound life insights.", commonEffects: [.spiritualExperience, .visualDistortions, .emotionalRelease, .nausea], bodyFeel: [.heavy, .warm], emotionalProfile: [.profound, .loving, .introspective], onset: "30-60 min", duration: "4-8 hours", difficulty: .experienced, averageRating: 4.9, reviewCount: 47, communityPhotoCount: 6),
        Strain(id: caapiMimosaID, name: "Caapi + Mimosa", parentSubstance: .ayahuasca, species: "B. caapi + M. hostilis", potency: .strong, description: "An alternative ayahuasca preparation using Mimosa hostilis root bark instead of Chacruna. Known for producing particularly vivid and colorful visuals with a somewhat shorter duration. The experience tends to be more visually oriented than the traditional Chacruna brew.", commonEffects: [.visualDistortions, .introspection, .spiritualExperience, .nausea], bodyFeel: [.heavy, .tingly], emotionalProfile: [.introspective, .profound], onset: "30-60 min", duration: "3-6 hours", difficulty: .experienced, averageRating: 4.7, reviewCount: 23, communityPhotoCount: 4),
        Strain(id: sanPedroID, name: "San Pedro", parentSubstance: .mescaline, species: "Echinopsis pachanoi", potency: .moderate, description: "San Pedro cactus has been used in Andean spiritual practices for over 3,000 years. The mescaline experience is known for its warmth, visual beauty, and a profound sense of connection to nature. The come-up can be slow with some nausea, but the plateau is often described as blissful.", commonEffects: [.euphoria, .visualDistortions, .spiritualExperience, .bodyHigh], bodyFeel: [.warm, .energetic, .light], emotionalProfile: [.euphoric, .loving, .calm], onset: "1-2 hours", duration: "8-12 hours", difficulty: .intermediate, averageRating: 4.5, reviewCount: 31, communityPhotoCount: 10),
        Strain(id: peyoteID, name: "Peyote", parentSubstance: .mescaline, species: "Lophophora williamsii", potency: .strong, description: "Sacred to many Native American traditions, Peyote contains mescaline and has been used ceremonially for thousands of years. It produces profound spiritual visions, a deep sense of interconnection, and powerful emotional experiences. Approach with the utmost cultural respect.", commonEffects: [.spiritualExperience, .visualDistortions, .introspection, .nausea], bodyFeel: [.heavy, .warm, .tingly], emotionalProfile: [.profound, .introspective, .loving], onset: "1-2 hours", duration: "8-12 hours", difficulty: .experienced, averageRating: 4.8, reviewCount: 19, communityPhotoCount: 3),
        Strain(id: peruvianTorchID, name: "Peruvian Torch", parentSubstance: .mescaline, species: "Echinopsis peruviana", potency: .moderate, description: "Peruvian Torch is a mescaline-containing cactus closely related to San Pedro. It tends to produce a more energetic, visually active experience with enhanced color perception and a sense of vitality. Often described as more 'electric' than San Pedro.", commonEffects: [.visualDistortions, .energizing, .euphoria, .creativity], bodyFeel: [.energetic, .tingly, .light], emotionalProfile: [.euphoric, .giggly], onset: "1-2 hours", duration: "8-10 hours", difficulty: .intermediate, averageRating: 4.3, reviewCount: 16, communityPhotoCount: 5),
        Strain(id: standardTabID, name: "Standard Tab", parentSubstance: .lsd, species: "Lysergic acid diethylamide", potency: .strong, description: "A standard dose of LSD (typically 100-150μg) produces a full psychedelic experience with vivid visual distortions, enhanced pattern recognition, deep introspection, and altered perception of time. The experience is often described as cerebral and expansive.", commonEffects: [.visualDistortions, .creativity, .introspection, .synesthesia, .euphoria], bodyFeel: [.energetic, .tingly], emotionalProfile: [.euphoric, .introspective, .giggly], onset: "30-60 min", duration: "8-12 hours", difficulty: .intermediate, averageRating: 4.6, reviewCount: 104, communityPhotoCount: 28),
        Strain(id: microdoseID, name: "Microdose", parentSubstance: .lsd, species: "Lysergic acid diethylamide", potency: .mild, description: "A sub-perceptual dose of LSD (typically 5-20μg) taken on a schedule for functional enhancement. Users report improved mood, focus, creativity, and social fluidity without overt psychedelic effects. Popular for productivity and wellbeing.", commonEffects: [.creativity, .euphoria, .energizing], bodyFeel: [.light, .energetic], emotionalProfile: [.calm, .euphoric], onset: "30-60 min", duration: "6-8 hours", difficulty: .beginner, averageRating: 4.4, reviewCount: 67, communityPhotoCount: 2),
    ]

    // MARK: - Trip Reports
    static let tripReports: [TripReport] = {
        let cal = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now)! }

        return [
            TripReport(id: UUID(), strainId: goldenTeachersID, rating: 5, setting: .nature, intention: "Connect with nature and process recent life changes", experienceTypes: [.visual, .emotional, .spiritual], visualIntensity: 3, bodyIntensity: 2, emotionalIntensity: 4, moods: [.euphoric, .peaceful, .loving], highlights: "Spent the afternoon in a meadow watching the grass breathe. Had a profound realization about letting go of control. The sunset was the most beautiful thing I've ever seen—colors I didn't know existed.", safetyNotes: "Bring plenty of water and have a sober sitter nearby. Stay on marked trails.", wouldRepeat: true, authorName: "MountainSeeker", date: daysAgo(2)),
            TripReport(id: UUID(), strainId: goldenTeachersID, rating: 4, setting: .home, intention: "Creative exploration and journaling", experienceTypes: [.visual, .emotional], visualIntensity: 3, bodyIntensity: 2, emotionalIntensity: 3, moods: [.calm, .giggly, .euphoric], highlights: "Set up my living room with soft lighting and music. Spent hours drawing—the pen seemed to move on its own. Laughed a lot at how beautiful simple things are. My cat was the best trip sitter.", safetyNotes: "Having familiar comforts nearby (blankets, tea) made a big difference.", wouldRepeat: true, authorName: "ArtfulWanderer", date: daysAgo(5)),
            TripReport(id: UUID(), strainId: albinoPEID, rating: 5, setting: .home, intention: "Deep inner work and ego exploration", experienceTypes: [.visual, .spiritual, .emotional, .physical], visualIntensity: 5, bodyIntensity: 4, emotionalIntensity: 5, moods: [.profound, .euphoric, .calm], highlights: "This was the most intense experience of my life. Complete ego dissolution around the 2-hour mark—I ceased to exist as a separate entity and merged with everything. Coming back was like being reborn. Cried tears of gratitude.", safetyNotes: "Do NOT underestimate this strain. Have an experienced sitter. I was glad I had nothing planned for 2 days after.", wouldRepeat: true, authorName: "CosmicTraveler", date: daysAgo(8)),
            TripReport(id: UUID(), strainId: albinoPEID, rating: 3, setting: .home, intention: "Exploring consciousness", experienceTypes: [.visual, .physical, .emotional], visualIntensity: 5, bodyIntensity: 5, emotionalIntensity: 4, moods: [.anxious, .profound, .calm], highlights: "Extremely intense. The visuals were overwhelming at peak—couldn't tell what was real. Body load was very heavy. Eventually surrendered and found peace, but the come-up was terrifying.", safetyNotes: "Start lower than you think. This strain is no joke. I wish I'd taken half as much.", wouldRepeat: false, authorName: "StarGazer", date: daysAgo(15)),
            TripReport(id: UUID(), strainId: bPlusID, rating: 5, setting: .social, intention: "Bond with close friends", experienceTypes: [.emotional, .visual], visualIntensity: 2, bodyIntensity: 1, emotionalIntensity: 4, moods: [.giggly, .loving, .euphoric], highlights: "Perfect group experience. We laughed for hours, shared deep conversations, and felt incredibly close. Mild visuals—everything had a warm glow. One of the best nights of my life.", safetyNotes: "Great beginner strain. Keep the group small and trusted.", wouldRepeat: true, authorName: "SunflowerChild", date: daysAgo(3)),
            TripReport(id: UUID(), strainId: bPlusID, rating: 4, setting: .nature, intention: "Gentle nature walk", experienceTypes: [.visual, .emotional], visualIntensity: 2, bodyIntensity: 1, emotionalIntensity: 3, moods: [.peaceful, .calm, .euphoric], highlights: "Walked through a botanical garden. Flowers were impossibly beautiful. Felt deeply grateful for being alive. Very manageable intensity—perfect for a first experience.", safetyNotes: "Sunglasses help if you're in public. Stay hydrated.", wouldRepeat: true, authorName: "GardenWanderer", date: daysAgo(12)),
            TripReport(id: UUID(), strainId: libertyCapsID, rating: 5, setting: .nature, intention: "Spiritual connection with the land", experienceTypes: [.visual, .spiritual], visualIntensity: 4, bodyIntensity: 3, emotionalIntensity: 4, moods: [.profound, .peaceful, .euphoric], highlights: "Picked these wild and consumed them where they grew. The experience felt ancient—like connecting with something far older than humanity. Vivid open-eye visuals of geometric patterns overlaid on the landscape.", safetyNotes: "ONLY consume wild mushrooms if you're 100% certain of identification. Bring a field guide and ideally go with an expert.", wouldRepeat: true, authorName: "ForestBather", date: daysAgo(20)),
            TripReport(id: UUID(), strainId: blueMeanieID, rating: 4, setting: .home, intention: "Music exploration", experienceTypes: [.visual, .physical], visualIntensity: 4, bodyIntensity: 3, emotionalIntensity: 3, moods: [.euphoric, .energetic, .giggly], highlights: "Put on headphones and was transported. The music became three-dimensional—I could see each instrument as a thread of color weaving through space. Very energetic body high, almost electric.", safetyNotes: "These are stronger than regular cubensis. Start low.", wouldRepeat: true, authorName: "QuantumLeap", date: daysAgo(7)),
            TripReport(id: UUID(), strainId: mazatecID, rating: 5, setting: .ceremony, intention: "Ceremonial healing journey", experienceTypes: [.spiritual, .emotional], visualIntensity: 3, bodyIntensity: 2, emotionalIntensity: 5, moods: [.profound, .loving, .peaceful], highlights: "Participated in a small ceremony with an experienced guide. The setting was sacred and intentional. Connected with deep grief I'd been carrying and finally found release. Felt held by something larger than myself.", safetyNotes: "Ceremony provides incredible container for the experience. Having a guide changed everything.", wouldRepeat: true, authorName: "HealingHeart", date: daysAgo(25)),
            TripReport(id: UUID(), strainId: caapiCharunaID, rating: 5, setting: .ceremony, intention: "Deep healing and life direction", experienceTypes: [.spiritual, .emotional, .visual], visualIntensity: 4, bodyIntensity: 4, emotionalIntensity: 5, moods: [.profound, .loving, .calm], highlights: "The hardest and most transformative experience of my life. Purging was intense but felt like years of pain leaving my body. Visions showed me patterns in my life I'd been blind to. The icaros (songs) were like medicine themselves.", safetyNotes: "Requires strict MAOI diet 2 weeks before. DO NOT mix with SSRIs—this is life-threatening. Only do with experienced facilitators.", wouldRepeat: true, authorName: "RiverStone", date: daysAgo(30)),
            TripReport(id: UUID(), strainId: caapiMimosaID, rating: 4, setting: .ceremony, intention: "Visual exploration and creativity", experienceTypes: [.visual, .spiritual, .emotional], visualIntensity: 5, bodyIntensity: 3, emotionalIntensity: 4, moods: [.euphoric, .profound], highlights: "Incredibly vivid visuals—fractal jungles, spiraling mandalas, beings made of light. More visually intense than the Chacruna brew I tried before. Shorter duration was actually appreciated.", safetyNotes: "Same dietary restrictions as traditional ayahuasca. Have a bucket nearby.", wouldRepeat: true, authorName: "DesertSage", date: daysAgo(18)),
            TripReport(id: UUID(), strainId: sanPedroID, rating: 4, setting: .nature, intention: "Connect with ancestral traditions", experienceTypes: [.visual, .emotional, .spiritual], visualIntensity: 3, bodyIntensity: 3, emotionalIntensity: 4, moods: [.euphoric, .peaceful, .loving], highlights: "Slow, warm come-up over 2 hours. Then the world became incredibly beautiful—colors saturated, edges softened. Felt a deep love for everything and everyone. The long duration meant I got to experience sunset, which was transcendent.", safetyNotes: "Plan for the full day—this lasts 10+ hours. The nausea in the first hour was rough but passed. Stay hydrated.", wouldRepeat: true, authorName: "WildSage", date: daysAgo(14)),
            TripReport(id: UUID(), strainId: peyoteID, rating: 5, setting: .ceremony, intention: "Sacred ceremony with elders", experienceTypes: [.spiritual, .emotional, .visual], visualIntensity: 4, bodyIntensity: 3, emotionalIntensity: 5, moods: [.profound, .peaceful, .loving], highlights: "Honored to participate in a NAC ceremony. The prayers, the fire, the drum—everything was medicine. Peyote showed me my place in the web of life. Most humbling experience I've ever had.", safetyNotes: "Peyote is sacred medicine. Only participate in authorized ceremonies with genuine indigenous leadership. Approach with deep respect.", wouldRepeat: true, authorName: "MindfulExplorer", date: daysAgo(45)),
            TripReport(id: UUID(), strainId: standardTabID, rating: 4, setting: .nature, intention: "Hiking and nature appreciation", experienceTypes: [.visual, .physical], visualIntensity: 4, bodyIntensity: 2, emotionalIntensity: 3, moods: [.euphoric, .energetic, .giggly], highlights: "Hiked to a mountain lake. The reflections on the water were indescribable—fractals within fractals. Felt very energetic and clear-headed. Everything was funny and beautiful at the same time.", safetyNotes: "Keep the hike easy and well-marked. Depth perception can be off. Bring snacks and water.", wouldRepeat: true, authorName: "NeuroscienceNerd", date: daysAgo(10)),
            TripReport(id: UUID(), strainId: standardTabID, rating: 5, setting: .home, intention: "Creative music production", experienceTypes: [.visual, .emotional, .spiritual], visualIntensity: 4, bodyIntensity: 2, emotionalIntensity: 4, moods: [.euphoric, .calm, .profound], highlights: "Spent 10 hours making music. Ideas flowed effortlessly—I could hear entire compositions in my head and translate them to my instruments. Synesthesia kicked in hard; every note had a vivid color.", safetyNotes: "Clear your schedule for the full 12 hours. Have food prepared in advance.", wouldRepeat: true, authorName: "CosmicTraveler", date: daysAgo(22)),
            TripReport(id: UUID(), strainId: microdoseID, rating: 4, setting: .social, intention: "Enhance focus and social connection at a dinner", experienceTypes: [.emotional], visualIntensity: 0, bodyIntensity: 1, emotionalIntensity: 2, moods: [.calm, .loving, .euphoric], highlights: "Subtle but noticeable. Conversations felt more genuine and flowing. Colors seemed slightly more vivid. Felt centered and present without any overt psychedelic effects. Perfect for a social evening.", safetyNotes: "Find your sweet spot dose—too much and you'll feel 'off' in public. Less is more.", wouldRepeat: true, authorName: "SunflowerChild", date: daysAgo(1)),
            TripReport(id: UUID(), strainId: peruvianTorchID, rating: 4, setting: .nature, intention: "Desert hike and meditation", experienceTypes: [.visual, .physical], visualIntensity: 3, bodyIntensity: 3, emotionalIntensity: 3, moods: [.energetic, .euphoric, .peaceful], highlights: "More electric than San Pedro—felt buzzing with energy. The desert landscape was alive with color and pattern. Did a long meditation at the peak and felt deeply connected to the earth beneath me.", safetyNotes: "The energy can be restless. Have an activity planned. Bring shade and lots of water if outdoors.", wouldRepeat: true, authorName: "DesertSage", date: daysAgo(35)),
        ]
    }()

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
            jurisdictionStatuses: [.colorado: .decriminalized, .oregon: .legal, .california: .decriminalized, .national: .illegal],
            averageRating: 4.7, reviewCount: 142, imageSymbol: "leaf.fill"
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
            jurisdictionStatuses: [.colorado: .illegal, .oregon: .underReview, .california: .illegal, .national: .illegal],
            averageRating: 4.8, reviewCount: 87, imageSymbol: "drop.fill"
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
            jurisdictionStatuses: [.colorado: .illegal, .oregon: .illegal, .california: .illegal, .national: .illegal],
            averageRating: 4.5, reviewCount: 34, imageSymbol: "sun.max.fill"
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
            jurisdictionStatuses: [.colorado: .illegal, .oregon: .illegal, .california: .illegal, .national: .illegal],
            averageRating: 4.6, reviewCount: 198, imageSymbol: "diamond.fill"
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
            jurisdictionStatuses: [.colorado: .illegal, .oregon: .illegal, .california: .illegal, .national: .underReview],
            averageRating: 4.4, reviewCount: 156, imageSymbol: "heart.circle.fill"
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
            jurisdictionStatuses: [.colorado: .medicalOnly, .oregon: .medicalOnly, .california: .medicalOnly, .national: .medicalOnly],
            averageRating: 4.3, reviewCount: 211, imageSymbol: "waveform.path.ecg"
        )
    ]

    // MARK: - Service Centers
    static let services: [ServiceCenter] = [
        ServiceCenter(id: serviceID1, name: "Rocky Mountain Mycelium Center", city: "Fort Collins", state: "CO", address: "412 Laurel St, Fort Collins, CO 80521", about: "A state-licensed psilocybin service center nestled in the foothills of the Rocky Mountains. Our experienced facilitators provide guided sessions in a serene, nature-inspired setting with comprehensive preparation and integration support.", offerings: ["Guided Psilocybin Sessions", "Preparation Counseling", "Integration Therapy", "Group Ceremonies", "Nature Walk Integration"], isVerified: true, averageRating: 4.9, reviewCount: 67, distanceMiles: 12, imageSymbol: "mountain.2.fill"),
        ServiceCenter(id: serviceID2, name: "Cascade Healing Arts", city: "Portland", state: "OR", address: "2847 SE Hawthorne Blvd, Portland, OR 97214", about: "Oregon's premier psilocybin therapy center offering personalized healing journeys. Our team of licensed facilitators combines evidence-based approaches with compassionate care in a beautifully designed therapeutic space.", offerings: ["Individual Psilocybin Therapy", "Couples Sessions", "Integration Circles", "Preparation Workshops", "Aftercare Programs"], isVerified: true, averageRating: 4.8, reviewCount: 93, distanceMiles: 1024, imageSymbol: "water.waves"),
        ServiceCenter(id: serviceID3, name: "Aspen Mind Wellness", city: "Denver", state: "CO", address: "1560 Broadway, Suite 300, Denver, CO 80202", about: "A modern ketamine-assisted therapy clinic in the heart of Denver. Our board-certified physicians and licensed therapists offer IV ketamine infusions and integration psychotherapy for treatment-resistant depression, anxiety, and PTSD.", offerings: ["IV Ketamine Infusions", "Ketamine-Assisted Psychotherapy", "Spravato (Esketamine)", "Integration Therapy", "Psychiatric Evaluation"], isVerified: true, averageRating: 4.6, reviewCount: 124, distanceMiles: 50, imageSymbol: "brain.head.profile"),
        ServiceCenter(id: serviceID4, name: "Willamette Valley Retreat", city: "Eugene", state: "OR", address: "890 Willamette St, Eugene, OR 97401", about: "A retreat-style psilocybin service center set on 20 acres of forested land. We offer multi-day immersive experiences combining psilocybin sessions with yoga, meditation, and nature-based practices for deep personal transformation.", offerings: ["Weekend Retreats", "5-Day Immersive Programs", "Guided Psilocybin Sessions", "Yoga & Meditation", "Forest Bathing"], isVerified: false, averageRating: 4.7, reviewCount: 41, distanceMiles: 1089, imageSymbol: "tree.fill")
    ]

    // MARK: - Reviews (legacy)
    static let reviews: [Review] = {
        let cal = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { cal.date(byAdding: .day, value: -n, to: now)! }

        return [
            Review(id: UUID(), authorName: "MountainSeeker", rating: 5, title: "Life-changing experience at Rocky Mountain", body: "I went in feeling lost and came out with a profound sense of clarity. The facilitators were incredibly supportive and the setting was perfect.", tags: [.spiritualExperience, .introspection, .emotionalRelease], date: daysAgo(2), substanceID: psilocybinID, serviceID: serviceID1, helpfulCount: 24),
            Review(id: UUID(), authorName: "NeuroscienceNerd", rating: 4, title: "Ketamine therapy helped my treatment-resistant depression", body: "After years of trying different SSRIs with limited success, ketamine therapy at Aspen Mind gave me my first real relief.", tags: [.relaxation, .emotionalRelease, .dissociation], date: daysAgo(5), substanceID: ketamineID, serviceID: serviceID3, helpfulCount: 31),
            Review(id: UUID(), authorName: "GardenWanderer", rating: 5, title: "Psilocybin opened doors I didn't know existed", body: "My guided session helped me process grief I'd been carrying for years.", tags: [.introspection, .emotionalRelease, .spiritualExperience], date: daysAgo(7), substanceID: psilocybinID, helpfulCount: 18),
            Review(id: UUID(), authorName: "PacificDreamer", rating: 5, title: "Cascade Healing is world-class", body: "The team at Cascade truly cares about every aspect of the experience.", tags: [.euphoria, .spiritualExperience, .emotionalRelease], date: daysAgo(10), substanceID: psilocybinID, serviceID: serviceID2, helpfulCount: 42),
            Review(id: UUID(), authorName: "DesertSage", rating: 4, title: "San Pedro ceremony was deeply moving", body: "A long but rewarding experience. The connection to nature and to the ceremonial tradition was palpable.", tags: [.spiritualExperience, .bodyHigh, .nausea, .introspection], date: daysAgo(14), substanceID: mescalineID, helpfulCount: 11),
            Review(id: UUID(), authorName: "CosmicTraveler", rating: 5, title: "LSD helped unlock my creativity", body: "Under safe conditions with a trusted friend, the experience was profoundly creative.", tags: [.creativity, .visualDistortions, .synesthesia, .euphoria], date: daysAgo(18), substanceID: lsdID, helpfulCount: 27),
            Review(id: UUID(), authorName: "HealingHeart", rating: 5, title: "MDMA therapy changed my relationship", body: "In a therapeutic context, MDMA allowed me and my partner to communicate with a level of honesty and empathy we'd never reached.", tags: [.empathy, .emotionalRelease, .euphoria], date: daysAgo(21), substanceID: mdmaID, helpfulCount: 36),
            Review(id: UUID(), authorName: "ForestBather", rating: 4, title: "Willamette Valley retreat was peaceful", body: "The multi-day format allowed for deep preparation and integration.", tags: [.relaxation, .introspection, .spiritualExperience], date: daysAgo(3), substanceID: psilocybinID, serviceID: serviceID4, helpfulCount: 15),
            Review(id: UUID(), authorName: "MindfulExplorer", rating: 3, title: "Ketamine was helpful but intense", body: "The dissociative effects were stronger than I expected.", tags: [.dissociation, .anxiety, .relaxation], date: daysAgo(25), substanceID: ketamineID, serviceID: serviceID3, helpfulCount: 19),
            Review(id: UUID(), authorName: "RiverStone", rating: 5, title: "Ayahuasca was the hardest and best thing I've done", body: "Deeply challenging but profoundly transformative.", tags: [.spiritualExperience, .emotionalRelease, .nausea, .dissolution], date: daysAgo(30), substanceID: ayahuascaID, helpfulCount: 53),
        ]
    }()
}
