-- ═══════════════════════════════════════
-- TripTalk Seed Data
-- 15 strains + 4 service centers
-- Uses same UUIDs as MockData.swift
-- ═══════════════════════════════════════

-- STRAINS: Psilocybin
INSERT INTO strains (id, name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty) VALUES
('10000000-0000-0000-0000-000000000001', 'Golden Teachers', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'One of the most popular and well-known psilocybin varieties. Golden Teachers are beloved for their reliable, gentle introduction to psychedelic experiences. They produce warm visuals, a sense of connection, and introspective clarity without overwhelming intensity.',
 ARRAY['Visual Distortions','Introspection','Euphoria'], ARRAY['Warm','Light'], ARRAY['Calm','Introspective','Euphoric'],
 '30-60 min', '4-6 hours', 'beginner'),

('10000000-0000-0000-0000-000000000002', 'Albino Penis Envy', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
 'A potent variant of the famous Penis Envy variety with albino coloring. Known for intense visuals, deep physical sensations, and powerful ego dissolution. Not recommended for beginners—this variety demands respect and preparation.',
 ARRAY['Visual Distortions','Ego Dissolution','Body High','Spiritual Experience'], ARRAY['Heavy','Tingly','Warm'], ARRAY['Profound','Euphoric'],
 '20-45 min', '5-7 hours', 'experienced'),

('10000000-0000-0000-0000-000000000003', 'B+', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'B+ is a versatile, forgiving variety known for its warm euphoria and gentle visuals. It''s a fantastic choice for beginners, offering a positive, uplifting experience with minimal body load and a clear-headed quality.',
 ARRAY['Euphoria','Relaxation','Creativity'], ARRAY['Light','Warm','Relaxed'], ARRAY['Calm','Euphoric','Giggly'],
 '30-60 min', '4-5 hours', 'beginner'),

('10000000-0000-0000-0000-000000000004', 'Liberty Caps', 'psilocybin', 'Psilocybe semilanceata', 'strong',
 'Wild-growing across temperate regions, Liberty Caps are one of the most potent naturally occurring psilocybin mushrooms. They produce vivid visuals, deep spiritual states, and a strong sense of awe and wonder at the natural world.',
 ARRAY['Visual Distortions','Spiritual Experience','Introspection'], ARRAY['Tingly','Light','Energetic'], ARRAY['Profound','Introspective'],
 '20-40 min', '4-6 hours', 'intermediate'),

('10000000-0000-0000-0000-000000000005', 'Blue Meanie', 'psilocybin', 'Panaeolus cyanescens', 'strong',
 'Blue Meanies are a potent variety known for intense visual experiences and waves of euphoria. The name comes from their tendency to bruise blue. They produce a more energetic, colorful trip compared to cubensis varieties.',
 ARRAY['Visual Distortions','Euphoria','Energizing'], ARRAY['Energetic','Tingly','Light'], ARRAY['Euphoric','Giggly'],
 '15-30 min', '4-6 hours', 'intermediate'),

('10000000-0000-0000-0000-000000000006', 'Mazatec', 'psilocybin', 'Psilocybe cubensis', 'moderate',
 'Named after the Mazatec people of Oaxaca, Mexico, who have used psilocybin mushrooms ceremonially for centuries. This variety is known for its spiritual depth and introspective quality, often producing profound insights and a sense of sacred connection.',
 ARRAY['Spiritual Experience','Introspection','Emotional Release'], ARRAY['Warm','Relaxed'], ARRAY['Profound','Introspective','Calm'],
 '30-60 min', '4-6 hours', 'intermediate');

-- STRAINS: Ayahuasca
INSERT INTO strains (id, name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty) VALUES
('10000000-0000-0000-0000-000000000007', 'Caapi + Chacruna', 'ayahuasca', 'B. caapi + P. viridis', 'strong',
 'The traditional Amazonian ayahuasca brew combining Banisteriopsis caapi vine with Psychotria viridis (Chacruna) leaves. This is the classic recipe used by indigenous healers, producing deeply spiritual visions, emotional catharsis, and often profound life insights.',
 ARRAY['Spiritual Experience','Visual Distortions','Emotional Release','Nausea'], ARRAY['Heavy','Warm'], ARRAY['Profound','Loving','Introspective'],
 '30-60 min', '4-8 hours', 'experienced'),

('10000000-0000-0000-0000-000000000008', 'Caapi + Mimosa', 'ayahuasca', 'B. caapi + M. hostilis', 'strong',
 'An alternative ayahuasca preparation using Mimosa hostilis root bark instead of Chacruna. Known for producing particularly vivid and colorful visuals with a somewhat shorter duration.',
 ARRAY['Visual Distortions','Introspection','Spiritual Experience','Nausea'], ARRAY['Heavy','Tingly'], ARRAY['Introspective','Profound'],
 '30-60 min', '3-6 hours', 'experienced');

-- STRAINS: Mescaline
INSERT INTO strains (id, name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty) VALUES
('10000000-0000-0000-0000-000000000009', 'San Pedro', 'mescaline', 'Echinopsis pachanoi', 'moderate',
 'San Pedro cactus has been used in Andean spiritual practices for over 3,000 years. The mescaline experience is known for its warmth, visual beauty, and a profound sense of connection to nature.',
 ARRAY['Euphoria','Visual Distortions','Spiritual Experience','Body High'], ARRAY['Warm','Energetic','Light'], ARRAY['Euphoric','Loving','Calm'],
 '1-2 hours', '8-12 hours', 'intermediate'),

('10000000-0000-0000-0000-000000000010', 'Peyote', 'mescaline', 'Lophophora williamsii', 'strong',
 'Sacred to many Native American traditions, Peyote contains mescaline and has been used ceremonially for thousands of years. It produces profound spiritual visions, a deep sense of interconnection, and powerful emotional experiences.',
 ARRAY['Spiritual Experience','Visual Distortions','Introspection','Nausea'], ARRAY['Heavy','Warm','Tingly'], ARRAY['Profound','Introspective','Loving'],
 '1-2 hours', '8-12 hours', 'experienced'),

('10000000-0000-0000-0000-000000000011', 'Peruvian Torch', 'mescaline', 'Echinopsis peruviana', 'moderate',
 'Peruvian Torch is a mescaline-containing cactus closely related to San Pedro. It tends to produce a more energetic, visually active experience with enhanced color perception and a sense of vitality.',
 ARRAY['Visual Distortions','Energizing','Euphoria','Creativity'], ARRAY['Energetic','Tingly','Light'], ARRAY['Euphoric','Giggly'],
 '1-2 hours', '8-10 hours', 'intermediate');

-- STRAINS: Ketamine
INSERT INTO strains (id, name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty) VALUES
('10000000-0000-0000-0000-000000000020', 'IV Infusion', 'ketamine', 'Ketamine HCl', 'strong',
 'Administered intravenously in a clinical setting, typically over 40 minutes. Provides precise dosing control.',
 ARRAY['Dissociation','Introspection','Relaxation'], ARRAY['Heavy','Warm','Relaxed'], ARRAY['Calm','Introspective','Profound'],
 'Immediate', '45-60 min + afterglow', 'experienced'),

('10000000-0000-0000-0000-000000000021', 'Sublingual Troche', 'ketamine', 'Ketamine HCl', 'moderate',
 'Dissolves under the tongue over 15-20 minutes. Common for at-home therapeutic use under medical supervision.',
 ARRAY['Relaxation','Introspection','Emotional Release'], ARRAY['Warm','Relaxed'], ARRAY['Calm','Introspective','Loving'],
 '15-30 min', '1-2 hours', 'intermediate'),

('10000000-0000-0000-0000-000000000022', 'Nasal Spray (Spravato)', 'ketamine', 'Esketamine', 'moderate',
 'FDA-approved esketamine nasal spray. Administered in certified healthcare settings for treatment-resistant depression.',
 ARRAY['Relaxation','Emotional Release','Dissociation'], ARRAY['Light','Relaxed'], ARRAY['Calm','Loving','Introspective'],
 '5-15 min', '1-2 hours', 'intermediate'),

('10000000-0000-0000-0000-000000000023', 'Intramuscular', 'ketamine', 'Ketamine HCl', 'strong',
 'Injected into muscle tissue in clinical settings. Faster onset than sublingual, used in therapeutic contexts.',
 ARRAY['Dissociation','Visual Distortions','Introspection'], ARRAY['Heavy','Warm','Tingly'], ARRAY['Profound','Introspective','Calm'],
 '5-10 min', '1-1.5 hours', 'experienced');

-- SERVICE CENTERS
INSERT INTO service_centers (id, name, city, state, address, about, offerings, is_verified, latitude, longitude, website_url, phone, image_symbol) VALUES
('00000000-0000-0000-0001-000000000001', 'Rocky Mountain Mycelium Center', 'Fort Collins', 'CO',
 '412 Laurel St, Fort Collins, CO 80521',
 'A state-licensed psilocybin service center nestled in the foothills of the Rocky Mountains. Our experienced facilitators provide guided sessions in a serene, nature-inspired setting with comprehensive preparation and integration support.',
 ARRAY['Guided Psilocybin Sessions','Preparation Counseling','Integration Therapy','Group Ceremonies','Nature Walk Integration'],
 true, 40.5853, -105.0844, NULL, NULL, 'mountain.2.fill'),

('00000000-0000-0000-0001-000000000002', 'Cascade Healing Arts', 'Portland', 'OR',
 '2847 SE Hawthorne Blvd, Portland, OR 97214',
 'Oregon''s premier psilocybin therapy center offering personalized healing journeys. Our team of licensed facilitators combines evidence-based approaches with compassionate care in a beautifully designed therapeutic space.',
 ARRAY['Individual Psilocybin Therapy','Couples Sessions','Integration Circles','Preparation Workshops','Aftercare Programs'],
 true, 45.5122, -122.6587, NULL, NULL, 'water.waves'),

('00000000-0000-0000-0001-000000000003', 'Aspen Mind Wellness', 'Denver', 'CO',
 '1560 Broadway, Suite 300, Denver, CO 80202',
 'A modern ketamine-assisted therapy clinic in the heart of Denver. Our board-certified physicians and licensed therapists offer IV ketamine infusions and integration psychotherapy for treatment-resistant depression, anxiety, and PTSD.',
 ARRAY['IV Ketamine Infusions','Ketamine-Assisted Psychotherapy','Spravato (Esketamine)','Integration Therapy','Psychiatric Evaluation'],
 true, 39.7392, -104.9903, NULL, NULL, 'brain.head.profile'),

('00000000-0000-0000-0001-000000000004', 'Willamette Valley Retreat', 'Eugene', 'OR',
 '890 Willamette St, Eugene, OR 97401',
 'A retreat-style psilocybin service center set on 20 acres of forested land. We offer multi-day immersive experiences combining psilocybin sessions with yoga, meditation, and nature-based practices for deep personal transformation.',
 ARRAY['Weekend Retreats','5-Day Immersive Programs','Guided Psilocybin Sessions','Yoga & Meditation','Forest Bathing'],
 false, 44.0521, -123.0868, NULL, NULL, 'tree.fill');
