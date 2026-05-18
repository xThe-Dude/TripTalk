-- ═══════════════════════════════════════════════════
-- TripTalk New Strains Migration
-- Adds well-known psilocybin varieties with reliable data
-- Safe to run multiple times (ON CONFLICT DO NOTHING)
-- ═══════════════════════════════════════════════════

-- PSILOCYBIN CUBENSIS VARIETIES

INSERT INTO strains (id, name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty) VALUES

-- 1. Penis Envy (original, non-albino)
('10000000-0000-0000-0000-000000000030', 'Penis Envy', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'The original Penis Envy is one of the most potent cubensis varieties. Developed from a culture reportedly collected by Terence McKenna in the Amazon, PE is known for dense, slow-growing fruits with dramatically high psilocybin content. Expect intense visuals, deep ego dissolution, and powerful body sensations. Approach with respect.',
 ARRAY['Ego Dissolution','Visual Distortions','Body High','Spiritual Experience'], ARRAY['Heavy','Warm','Tingly'], ARRAY['Profound','Euphoric','Introspective'],
 '20-45 min', '5-7 hours', 'experienced'),

-- 2. AA+ (Albino A+)
('10000000-0000-0000-0000-000000000031', 'AA+', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Albino A+ is a leucistic variant of the classic A+ strain. Known for its ghostly white appearance and smooth, balanced effects. It offers clear-headed visuals, gentle euphoria, and a contemplative quality that makes it approachable for those with some experience. Less body load than many varieties.',
 ARRAY['Visual Distortions','Euphoria','Introspection'], ARRAY['Light','Relaxed'], ARRAY['Calm','Introspective','Euphoric'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 3. African Transkei
('10000000-0000-0000-0000-000000000032', 'African Transkei', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Originating from the Transkei region of South Africa, this is one of the first documented cubensis strains from the African continent. Known for vivid open-eye visuals, dancing lights, and a highly energetic, social experience. Often described as more visual than introspective, making it a favorite for creative and social settings.',
 ARRAY['Visual Distortions','Euphoria','Energizing','Creativity'], ARRAY['Energetic','Light','Tingly'], ARRAY['Euphoric','Giggly','Loving'],
 '30-45 min', '4-6 hours', 'beginner'),

-- 4. Alacabenzi
('10000000-0000-0000-0000-000000000033', 'Alacabenzi', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'A hybrid of Alabama cubensis and Mexican varieties, Alacabenzi is known for producing a deeply physical, body-centric experience. At lower doses it offers relaxing, almost sedative effects. At higher doses, expect spatial distortion and a strong sense of bodily movement. Popular for its reliability and balanced trip.',
 ARRAY['Relaxation','Body High','Visual Distortions'], ARRAY['Heavy','Warm','Relaxed'], ARRAY['Calm','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 5. Amazon
('10000000-0000-0000-0000-000000000034', 'Amazon', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'Originally collected from the Amazon rainforest, this variety produces large, fleshy fruits and a powerful experience. Known for strong visuals, a spiritual quality, and energetic body sensations. The Amazon strain is aggressive in growth and equally assertive in effects — a solid choice for intermediate users seeking depth.',
 ARRAY['Visual Distortions','Spiritual Experience','Energizing'], ARRAY['Energetic','Warm','Tingly'], ARRAY['Profound','Euphoric','Introspective'],
 '20-45 min', '5-7 hours', 'intermediate'),

-- 6. Avery''s Albino
('10000000-0000-0000-0000-000000000035', 'Avery''s Albino', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'A true albino variety with striking white coloring throughout. Avery''s Albino is known for its above-average potency and a clean, clear-headed experience. Users report vivid geometric visuals, a strong sense of wonder, and emotional openness. More potent than typical cubensis but less overwhelming than PE varieties.',
 ARRAY['Visual Distortions','Euphoria','Introspection'], ARRAY['Light','Tingly','Warm'], ARRAY['Euphoric','Loving','Introspective'],
 '25-50 min', '5-6 hours', 'intermediate'),

-- 7. Ecuadorian
('10000000-0000-0000-0000-000000000036', 'Ecuadorian', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Originating from the highlands of Ecuador, this variety is valued for its clean, spiritual quality. It produces a smooth come-up, moderate visuals, and a sense of peace and grounding. Often described as one of the more "earthy" and meditative cubensis strains. Excellent for nature settings and introspective journeys.',
 ARRAY['Introspection','Spiritual Experience','Visual Distortions'], ARRAY['Warm','Relaxed','Light'], ARRAY['Calm','Profound','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 8. Enigma
('10000000-0000-0000-0000-000000000037', 'Enigma', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'Enigma is a unique blob-like mutation of Tidal Wave that does not produce traditional caps or spores — it grows as dense, coral-like masses. Winner of the Psilocybin Cup for highest tryptamine content. Extremely potent with intense visuals, strong ego dissolution, and a lengthy duration. For experienced users only.',
 ARRAY['Ego Dissolution','Visual Distortions','Spiritual Experience','Body High'], ARRAY['Heavy','Tingly','Warm'], ARRAY['Profound','Euphoric'],
 '15-40 min', '6-8 hours', 'experienced'),

-- 9. Hillbilly
('10000000-0000-0000-0000-000000000038', 'Hillbilly', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'A rustic variety originally found in the hills of Arkansas. Hillbilly is known for its reliable, warm, and uplifting effects. It produces moderate visuals, a comfortable body high, and plenty of laughter. Often recommended as a great "social" strain — the experience is happy and grounded rather than deeply psychedelic.',
 ARRAY['Euphoria','Relaxation','Creativity'], ARRAY['Warm','Light','Relaxed'], ARRAY['Giggly','Euphoric','Calm'],
 '30-60 min', '4-5 hours', 'beginner'),

-- 10. Jack Frost
('10000000-0000-0000-0000-000000000039', 'Jack Frost', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'A cross between Albino Penis Envy and True Albino Teacher, Jack Frost produces stunning white fruits that curl upward like frozen ice. Above-average potency with vivid visuals, euphoria, and a unique clarity that keeps you present during the experience. Increasingly popular for its beauty and reliable intensity.',
 ARRAY['Visual Distortions','Euphoria','Introspection'], ARRAY['Tingly','Light','Energetic'], ARRAY['Euphoric','Introspective','Loving'],
 '20-45 min', '5-7 hours', 'intermediate'),

-- 11. Jedi Mind Fuck
('10000000-0000-0000-0000-000000000040', 'Jedi Mind Fuck', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'Despite the provocative name, JMF is a respected variety known for powerful mental effects and rich philosophical introspection. It produces moderate to strong visuals, a contemplative headspace, and a sense of expanded awareness. The experience tends to be more cerebral than physical — deep thoughts and meaningful insights.',
 ARRAY['Introspection','Visual Distortions','Spiritual Experience'], ARRAY['Light','Tingly'], ARRAY['Profound','Introspective','Calm'],
 '25-50 min', '5-7 hours', 'intermediate'),

-- 12. Koh Samui Super Strain (KSSS)
('10000000-0000-0000-0000-000000000041', 'Koh Samui Super Strain', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'Originally collected from the Thai island of Koh Samui by mycologist John Allen. This enhanced version of the original Koh Samui is known for fast colonization, dense fruits, and a euphoric, energetic trip. Users report warm visuals, social energy, and a positive mood boost with a shorter-than-average duration.',
 ARRAY['Euphoria','Energizing','Visual Distortions'], ARRAY['Energetic','Warm','Light'], ARRAY['Euphoric','Giggly','Loving'],
 '20-40 min', '3-5 hours', 'intermediate'),

-- 13. Malabar Coast
('10000000-0000-0000-0000-000000000042', 'Malabar Coast', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'From the southwestern coast of India, Malabar Coast is a robust variety that produces large fruits and a well-rounded experience. Effects are moderate and balanced — gentle visuals, emotional warmth, and a meditative quality. Known for minimal nausea and a smooth come-up, making it a comfortable choice for most experience levels.',
 ARRAY['Visual Distortions','Relaxation','Introspection'], ARRAY['Warm','Relaxed','Light'], ARRAY['Calm','Loving','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 14. Orissa India
('10000000-0000-0000-0000-000000000043', 'Orissa India', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'One of the tallest-growing cubensis varieties, originating from Orissa state in India. Known for producing some of the largest individual mushrooms in cultivation. The experience is gentle, spiritual, and contemplative with moderate visuals and a strong sense of interconnection. A favorite for meditation and solo journeys.',
 ARRAY['Spiritual Experience','Introspection','Visual Distortions'], ARRAY['Light','Warm','Relaxed'], ARRAY['Profound','Calm','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 15. PES Hawaiian
('10000000-0000-0000-0000-000000000044', 'PES Hawaiian', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Distributed by Pacific Exotica Spora, this Hawaiian-origin variety is known for producing large, dense fruits and a warm, visual experience. The trip is typically uplifting and euphoric with beautiful flowing visuals. Moderate potency makes it accessible, while the quality of the experience keeps experienced users coming back.',
 ARRAY['Euphoria','Visual Distortions','Relaxation'], ARRAY['Warm','Light','Relaxed'], ARRAY['Euphoric','Loving','Calm'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 16. PF Classic
('10000000-0000-0000-0000-000000000045', 'PF Classic', 'psilocybin', 'Psilocybe cubensis', 'mild',
 'The original strain used in the famous PF Tek cultivation method by Robert McPherson (Psilocybe Fanaticus). PF Classic is where modern home cultivation began. It offers a gentle, manageable experience — mild visuals, light euphoria, and a positive mood. Perhaps the most beginner-friendly cubensis variety available.',
 ARRAY['Euphoria','Relaxation','Creativity'], ARRAY['Light','Warm'], ARRAY['Calm','Giggly','Euphoric'],
 '30-60 min', '3-5 hours', 'beginner'),

-- 17. Tidal Wave
('10000000-0000-0000-0000-000000000046', 'Tidal Wave', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'A cross between Penis Envy and B+ created by mycologist Doma. Tidal Wave gained fame when its mutation (Enigma) won the Psilocybin Cup. The standard form is extremely potent — strong visuals, waves of euphoria, and deep ego dissolution. The name reflects the experience: effects come in powerful, rolling waves.',
 ARRAY['Ego Dissolution','Visual Distortions','Euphoria','Body High'], ARRAY['Heavy','Tingly','Warm'], ARRAY['Profound','Euphoric'],
 '15-40 min', '5-7 hours', 'experienced'),

-- 18. Thai Elephant Dung
('10000000-0000-0000-0000-000000000047', 'Thai Elephant Dung', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'Named for its original substrate — elephant dung in Thailand. Despite the unglamorous name, this is a respected variety producing a fast-onset, energetic, and highly visual experience. Popular in Thai full moon party culture. The trip is often described as electric and social, with vivid color enhancement and euphoric energy.',
 ARRAY['Euphoria','Energizing','Visual Distortions'], ARRAY['Energetic','Tingly','Light'], ARRAY['Euphoric','Giggly','Loving'],
 '15-30 min', '4-6 hours', 'intermediate'),

-- 19. Texas Yellow Cap
('10000000-0000-0000-0000-000000000048', 'Texas Yellow Cap', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'A classic American variety found growing on cattle ranches in Texas. Recognizable by its golden-yellow caps and thick stems. Produces a warm, grounded experience with moderate visuals and a strong sense of connection to nature. Effects are reliable and well-balanced — a solid all-around cubensis for any experience level.',
 ARRAY['Euphoria','Relaxation','Visual Distortions'], ARRAY['Warm','Relaxed','Light'], ARRAY['Calm','Euphoric','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 20. White Rabbit
('10000000-0000-0000-0000-000000000049', 'White Rabbit', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'A cross between Albino Penis Envy and Moby Dick, White Rabbit is a newer variety that has quickly gained a reputation for extreme potency. Produces dense, albino fruits and an experience marked by intense visuals, deep ego dissolution, and a long duration. For experienced psychonauts who want to go deep.',
 ARRAY['Ego Dissolution','Visual Distortions','Spiritual Experience','Body High'], ARRAY['Heavy','Tingly','Warm'], ARRAY['Profound','Euphoric'],
 '15-40 min', '6-8 hours', 'experienced'),

-- 21. APE Revert
('10000000-0000-0000-0000-000000000050', 'APE Revert', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'When Albino Penis Envy reverts to producing spores (the original APE does not), the result is APE Revert. It retains much of APE''s potency while being easier to cultivate. Strong visuals, significant body effects, and meaningful introspection. A practical way to access PE-level intensity with more forgiving cultivation.',
 ARRAY['Visual Distortions','Body High','Introspection'], ARRAY['Heavy','Warm','Tingly'], ARRAY['Profound','Introspective','Euphoric'],
 '20-45 min', '5-7 hours', 'experienced'),

-- 22. Blue Magnolia
('10000000-0000-0000-0000-000000000051', 'Blue Magnolia', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'Originally discovered growing wild in Mississippi, Blue Magnolia Rust is named for its tendency to bruise deep blue and its rusty spore color. Above-average potency with a dreamy, flowing quality to the visuals. The experience is often described as warm and emotionally opening — good for creative exploration and emotional processing.',
 ARRAY['Visual Distortions','Creativity','Emotional Release'], ARRAY['Warm','Light','Tingly'], ARRAY['Loving','Euphoric','Introspective'],
 '25-50 min', '5-6 hours', 'intermediate'),

-- 23. Stargazer
('10000000-0000-0000-0000-000000000052', 'Stargazer', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'A lesser-known but increasingly popular variety prized for its strongly visual character. Stargazer produces rich open-eye and closed-eye visuals — fractal patterns, color shifting, and a sense of cosmic perspective. The name fits: users often report feeling drawn to look at the sky and contemplate their place in the universe.',
 ARRAY['Visual Distortions','Spiritual Experience','Introspection'], ARRAY['Light','Tingly','Energetic'], ARRAY['Profound','Introspective','Calm'],
 '25-50 min', '5-7 hours', 'intermediate'),

-- 24. Golden Halo
('10000000-0000-0000-0000-000000000053', 'Golden Halo', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'A variant of Golden Teacher with a distinctive halo-like ring on the cap margin. Golden Halo preserves the beloved characteristics of its parent — warm visuals, gentle introspection, and emotional clarity — while often producing slightly larger fruits. An excellent variety for those who love Golden Teachers and want a subtle variation.',
 ARRAY['Visual Distortions','Euphoria','Introspection'], ARRAY['Warm','Light','Relaxed'], ARRAY['Calm','Euphoric','Loving'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 25. Trinity
('10000000-0000-0000-0000-000000000054', 'Trinity', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'A triple cross of Penis Envy, Aztec God, and Tidal Wave. Trinity combines the potency of PE genetics with unique visual and emotional depth. Extremely strong — dense fruits pack intense psilocybin content. The experience is multidimensional: deep visuals, physical waves, and profound spiritual states. For experienced users only.',
 ARRAY['Ego Dissolution','Visual Distortions','Spiritual Experience','Body High'], ARRAY['Heavy','Tingly','Warm'], ARRAY['Profound','Euphoric'],
 '15-40 min', '6-8 hours', 'experienced'),

-- 26. Corumba Brazil
('10000000-0000-0000-0000-000000000055', 'Corumba Brazil', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Collected near Corumbá, Brazil, in a subtropical cattle-grazing region. This South American variety produces a warm, grounded trip with moderate visuals and a strong connection to nature. Known for a smooth come-up and a generally comfortable experience. The emotional tone is positive and exploratory.',
 ARRAY['Euphoria','Visual Distortions','Relaxation'], ARRAY['Warm','Light','Relaxed'], ARRAY['Calm','Euphoric','Loving'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 27. Mexican (Oaxacan)
('10000000-0000-0000-0000-000000000056', 'Mexican', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'One of the oldest known cultivated psilocybin varieties, with deep roots in Oaxacan indigenous ceremony. Mexican cubensis offers a spiritual, introspective experience — moderate visuals, a sense of reverence, and emotional depth. This is the lineage used by María Sabina and the Mazatec healers who introduced psilocybin to the Western world.',
 ARRAY['Spiritual Experience','Introspection','Visual Distortions'], ARRAY['Warm','Light'], ARRAY['Profound','Calm','Introspective'],
 '30-60 min', '4-6 hours', 'beginner'),

-- 28. Melmak
('10000000-0000-0000-0000-000000000057', 'Melmak', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'Believed to be an original Penis Envy isolation predating modern PE genetics. Melmak produces distinctive alien-looking fruits with wavy caps and thick, often split stems. Potency rivals standard PE — expect strong visuals, significant body effects, and deep psychological terrain. A piece of mycological history.',
 ARRAY['Ego Dissolution','Visual Distortions','Body High'], ARRAY['Heavy','Warm','Tingly'], ARRAY['Profound','Introspective'],
 '20-45 min', '5-7 hours', 'experienced'),

-- 29. Great White Monster
('10000000-0000-0000-0000-000000000058', 'Great White Monster', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'A leucistic variety known for producing large, dense, white fruits. Great White Monster delivers above-average potency with vivid visuals and a euphoric, slightly energetic quality. The experience is well-rounded — visual enough to be interesting, introspective enough to be meaningful, without the overwhelming intensity of PE varieties.',
 ARRAY['Visual Distortions','Euphoria','Energizing'], ARRAY['Warm','Tingly','Energetic'], ARRAY['Euphoric','Introspective'],
 '25-50 min', '5-6 hours', 'intermediate'),

-- 30. Rusty Whyte
('10000000-0000-0000-0000-000000000059', 'Rusty Whyte', 'psilocybin', 'Psilocybe cubensis', 'strong',
 'A leucistic variety with distinctive rusty-brown spores against white flesh. Rusty Whyte produces a clean, euphoric experience with beautiful visual enhancement and a warm emotional tone. Above-average potency but with a forgiving character — the trip builds gently and maintains a positive trajectory throughout.',
 ARRAY['Euphoria','Visual Distortions','Creativity'], ARRAY['Warm','Light','Tingly'], ARRAY['Euphoric','Loving','Giggly'],
 '25-50 min', '5-6 hours', 'intermediate'),

-- NON-CUBENSIS PSILOCYBIN SPECIES

-- 31. P. natalensis
('10000000-0000-0000-0000-000000000060', 'Natal Super Strength', 'psilocybin', 'Psilocybe natalensis', 'strong',
 'A distinct species from South Africa (not a cubensis variety). Psilocybe natalensis has gained popularity for its unique tryptamine profile and reportedly smoother experience compared to cubensis. Effects include clean visuals, emotional warmth, and a clear-headed quality. Some users report less nausea than cubensis varieties.',
 ARRAY['Visual Distortions','Euphoria','Introspection'], ARRAY['Light','Warm','Energetic'], ARRAY['Euphoric','Calm','Loving'],
 '20-45 min', '4-6 hours', 'intermediate')

ON CONFLICT (name) DO NOTHING;


-- ═══════════════════════════════════════════════════
-- Done! 31 new strains added (6 existing + 31 new = 37 total psilocybin)
-- All data based on widely documented community reports.
-- ═══════════════════════════════════════════════════
