-- ═══════════════════════════════════════
-- TripTalk Seed Data Migration 004
-- ═══════════════════════════════════════

-- Seed 15 strains
INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Golden Teachers', 'psilocybin', 'Psilocybe cubensis', 'moderate',
  'One of the most popular and well-known psilocybin varieties. Golden Teachers are beloved for their reliable, gentle introduction to psychedelic experiences. They produce warm visuals, a sense of connection, and introspective clarity without overwhelming intensity.',
  '{visualDistortions,introspection,euphoria}', '{warm,light}', '{calm,introspective,euphoric}',
  '30-60 min', '4-6 hours', 'beginner');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Albino Penis Envy', 'psilocybin', 'Psilocybe cubensis', 'very_strong',
  'A potent variant of the famous Penis Envy variety with albino coloring. Known for intense visuals, deep physical sensations, and powerful ego dissolution. Not recommended for beginners—this variety demands respect and preparation.',
  '{visualDistortions,dissolution,bodyHigh,spiritualExperience}', '{heavy,tingly,warm}', '{profound,euphoric}',
  '20-45 min', '5-7 hours', 'experienced');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('B+', 'psilocybin', 'Psilocybe cubensis', 'moderate',
  'B+ is a versatile, forgiving variety known for its warm euphoria and gentle visuals. It''s a fantastic choice for beginners, offering a positive, uplifting experience with minimal body load and a clear-headed quality.',
  '{euphoria,relaxation,creativity}', '{light,warm,relaxed}', '{calm,euphoric,giggly}',
  '30-60 min', '4-5 hours', 'beginner');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Liberty Caps', 'psilocybin', 'Psilocybe semilanceata', 'strong',
  'Wild-growing across temperate regions, Liberty Caps are one of the most potent naturally occurring psilocybin mushrooms. They produce vivid visuals, deep spiritual states, and a strong sense of awe and wonder at the natural world.',
  '{visualDistortions,spiritualExperience,introspection}', '{tingly,light,energetic}', '{profound,introspective}',
  '20-40 min', '4-6 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Blue Meanie', 'psilocybin', 'Panaeolus cyanescens', 'strong',
  'Blue Meanies are a potent variety known for intense visual experiences and waves of euphoria. The name comes from their tendency to bruise blue. They produce a more energetic, colorful trip compared to cubensis varieties.',
  '{visualDistortions,euphoria,energizing}', '{energetic,tingly,light}', '{euphoric,giggly}',
  '15-30 min', '4-6 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Mazatec', 'psilocybin', 'Psilocybe cubensis', 'moderate',
  'Named after the Mazatec people of Oaxaca, Mexico, who have used psilocybin mushrooms ceremonially for centuries. This variety is known for its spiritual depth and introspective quality, often producing profound insights and a sense of sacred connection.',
  '{spiritualExperience,introspection,emotionalRelease}', '{warm,relaxed}', '{profound,introspective,calm}',
  '30-60 min', '4-6 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Caapi + Chacruna', 'ayahuasca', 'B. caapi + P. viridis', 'strong',
  'The traditional Amazonian ayahuasca brew combining Banisteriopsis caapi vine with Psychotria viridis (Chacruna) leaves. This is the classic recipe used by indigenous healers, producing deeply spiritual visions, emotional catharsis, and often profound life insights.',
  '{spiritualExperience,visualDistortions,emotionalRelease,nausea}', '{heavy,warm}', '{profound,loving,introspective}',
  '30-60 min', '4-8 hours', 'experienced');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Caapi + Mimosa', 'ayahuasca', 'B. caapi + M. hostilis', 'strong',
  'An alternative ayahuasca preparation using Mimosa hostilis root bark instead of Chacruna. Known for producing particularly vivid and colorful visuals with a somewhat shorter duration. The experience tends to be more visually oriented than the traditional Chacruna brew.',
  '{visualDistortions,introspection,spiritualExperience,nausea}', '{heavy,tingly}', '{introspective,profound}',
  '30-60 min', '3-6 hours', 'experienced');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('San Pedro', 'mescaline', 'Echinopsis pachanoi', 'moderate',
  'San Pedro cactus has been used in Andean spiritual practices for over 3,000 years. The mescaline experience is known for its warmth, visual beauty, and a profound sense of connection to nature. The come-up can be slow with some nausea, but the plateau is often described as blissful.',
  '{euphoria,visualDistortions,spiritualExperience,bodyHigh}', '{warm,energetic,light}', '{euphoric,loving,calm}',
  '1-2 hours', '8-12 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Peyote', 'mescaline', 'Lophophora williamsii', 'strong',
  'Sacred to many Native American traditions, Peyote contains mescaline and has been used ceremonially for thousands of years. It produces profound spiritual visions, a deep sense of interconnection, and powerful emotional experiences. Approach with the utmost cultural respect.',
  '{spiritualExperience,visualDistortions,introspection,nausea}', '{heavy,warm,tingly}', '{profound,introspective,loving}',
  '1-2 hours', '8-12 hours', 'experienced');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Peruvian Torch', 'mescaline', 'Echinopsis peruviana', 'moderate',
  'Peruvian Torch is a mescaline-containing cactus closely related to San Pedro. It tends to produce a more energetic, visually active experience with enhanced color perception and a sense of vitality. Often described as more ''electric'' than San Pedro.',
  '{visualDistortions,energizing,euphoria,creativity}', '{energetic,tingly,light}', '{euphoric,giggly}',
  '1-2 hours', '8-10 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('IV Infusion', 'ketamine', 'Ketamine HCl', 'strong',
  'Administered intravenously in a clinical setting, typically over 40 minutes. Provides precise dosing control.',
  '{dissociation,introspection,relaxation}', '{heavy,warm,relaxed}', '{calm,introspective,profound}',
  'Immediate', '45-60 min + afterglow', 'experienced');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Sublingual Troche', 'ketamine', 'Ketamine HCl', 'moderate',
  'Dissolves under the tongue over 15-20 minutes. Common for at-home therapeutic use under medical supervision.',
  '{relaxation,introspection,emotionalRelease}', '{warm,relaxed}', '{calm,introspective,loving}',
  '15-30 min', '1-2 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Nasal Spray (Spravato)', 'ketamine', 'Esketamine', 'moderate',
  'FDA-approved esketamine nasal spray. Administered in certified healthcare settings for treatment-resistant depression.',
  '{relaxation,emotionalRelease,dissociation}', '{light,relaxed}', '{calm,loving,introspective}',
  '5-15 min', '1-2 hours', 'intermediate');

INSERT INTO strains (name, parent_substance, species, potency, description, common_effects, body_feel, emotional_profile, onset, duration, difficulty)
VALUES ('Intramuscular', 'ketamine', 'Ketamine HCl', 'strong',
  'Injected into muscle tissue in clinical settings. Faster onset than sublingual, used in therapeutic contexts.',
  '{dissociation,visualDistortions,introspection}', '{heavy,warm,tingly}', '{profound,introspective,calm}',
  '5-10 min', '1-1.5 hours', 'experienced');

-- Seed service centers
INSERT INTO service_centers (name, city, state, address, about, offerings, is_verified, image_symbol)
VALUES ('Rocky Mountain Mycelium Center', 'Fort Collins', 'CO', '412 Laurel St, Fort Collins, CO 80521',
  'A state-licensed psilocybin service center nestled in the foothills of the Rocky Mountains. Our experienced facilitators provide guided sessions in a serene, nature-inspired setting with comprehensive preparation and integration support.',
  '{Guided Psilocybin Sessions,Preparation Counseling,Integration Therapy,Group Ceremonies,Nature Walk Integration}', true, 'mountain.2.fill');

INSERT INTO service_centers (name, city, state, address, about, offerings, is_verified, image_symbol)
VALUES ('Cascade Healing Arts', 'Portland', 'OR', '2847 SE Hawthorne Blvd, Portland, OR 97214',
  'Oregon''s premier psilocybin therapy center offering personalized healing journeys. Our team of licensed facilitators combines evidence-based approaches with compassionate care in a beautifully designed therapeutic space.',
  '{Individual Psilocybin Therapy,Couples Sessions,Integration Circles,Preparation Workshops,Aftercare Programs}', true, 'water.waves');

INSERT INTO service_centers (name, city, state, address, about, offerings, is_verified, image_symbol)
VALUES ('Aspen Mind Wellness', 'Denver', 'CO', '1560 Broadway, Suite 300, Denver, CO 80202',
  'A modern ketamine-assisted therapy clinic in the heart of Denver. Our board-certified physicians and licensed therapists offer IV ketamine infusions and integration psychotherapy for treatment-resistant depression, anxiety, and PTSD.',
  '{IV Ketamine Infusions,Ketamine-Assisted Psychotherapy,Spravato (Esketamine),Integration Therapy,Psychiatric Evaluation}', true, 'brain.head.profile');

INSERT INTO service_centers (name, city, state, address, about, offerings, is_verified, image_symbol)
VALUES ('Willamette Valley Retreat', 'Eugene', 'OR', '890 Willamette St, Eugene, OR 97401',
  'A retreat-style psilocybin service center set on 20 acres of forested land. We offer multi-day immersive experiences combining psilocybin sessions with yoga, meditation, and nature-based practices for deep personal transformation.',
  '{Weekend Retreats,5-Day Immersive Programs,Guided Psilocybin Sessions,Yoga & Meditation,Forest Bathing}', false, 'tree.fill');

-- Seed complete
