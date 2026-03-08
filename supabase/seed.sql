-- TripTalk Seed Data
-- Comprehensive variety database + service centers

-- ============================================================
-- PSILOCYBIN VARIETIES
-- ============================================================

INSERT INTO varieties (name, substance_type, species, potency, difficulty, description, onset, duration, safety_notes, common_effects, body_feel, emotional_profile, legal_notes) VALUES

('Golden Teachers', 'psilocybin', 'Psilocybe cubensis', 'moderate', 'beginner',
 'One of the most widely recognized and popular psilocybin varieties. Known for producing a balanced experience that combines gentle visuals with introspective, philosophical insights. Often recommended as a starting point for those new to psilocybin due to its forgiving and consistent nature.',
 '30-60 min', '4-6 hours',
 'Start with a lower amount in a comfortable setting. Effects can vary significantly between individuals. Having a trusted companion present is recommended, especially for first experiences.',
 '{"visual", "introspective", "euphoric", "spiritual"}',
 '{"warm", "light", "tingly"}',
 '{"calm", "giggly", "profound", "loving"}',
 'Regulated services available in Oregon and Colorado. Decriminalized in several US cities.'),

('Albino Penis Envy', 'psilocybin', 'Psilocybe cubensis', 'very_strong', 'experienced',
 'A potent albino variant of the famous Penis Envy variety. Known for intense visual experiences and deep emotional processing. The reduced pigmentation does not affect potency — this is considered one of the strongest cubensis varieties available. Not recommended for beginners.',
 '20-45 min', '5-7 hours',
 'This is a high-potency variety. Experienced practitioners recommend starting with significantly less than typical amounts. A trusted sitter is strongly recommended. Ensure a safe, comfortable environment.',
 '{"visual", "euphoric", "spiritual", "introspective"}',
 '{"heavy", "warm", "tingly", "energetic"}',
 '{"profound", "euphoric", "loving", "introspective"}',
 'Regulated services available in Oregon and Colorado.'),

('B+', 'psilocybin', 'Psilocybe cubensis', 'moderate', 'beginner',
 'A versatile and forgiving variety known for its warm, positive character. B+ is widely appreciated for producing consistent, manageable experiences with a gentle body feel and uplifting emotional tone. A popular choice for both newcomers and experienced practitioners.',
 '30-60 min', '4-5 hours',
 'Generally well-tolerated. As with all psilocybin experiences, set and setting play a crucial role. Stay hydrated and have comfort items nearby.',
 '{"euphoric", "calm", "visual"}',
 '{"warm", "light", "relaxed"}',
 '{"calm", "giggly", "euphoric", "loving"}',
 'Regulated services available in Oregon and Colorado.'),

('Liberty Caps', 'psilocybin', 'Psilocybe semilanceata', 'strong', 'intermediate',
 'One of the most potent naturally occurring psilocybin species, found in grasslands across temperate regions worldwide. Liberty Caps produce a distinctly cerebral, visionary experience with rich visual patterns and deep spiritual overtones. The experience tends to feel more "wild" and organic compared to cultivated varieties.',
 '20-40 min', '4-6 hours',
 'Potency can vary significantly between specimens. This species is notably stronger than most cubensis varieties. Careful attention to amount is essential. Never consume wild mushrooms without expert identification.',
 '{"visual", "spiritual", "introspective"}',
 '{"light", "energetic", "tingly"}',
 '{"profound", "introspective", "calm"}',
 'Found wild in many regions. Legal status varies by jurisdiction.'),

('Blue Meanie', 'psilocybin', 'Psilocybe cubensis', 'strong', 'intermediate',
 'Not to be confused with Panaeolus cyanescens (also called Blue Meanies), this cubensis variety is known for intense visual effects and a distinctly euphoric, energetic character. The name comes from the strong bluing reaction when bruised, indicating high psilocybin content.',
 '25-50 min', '5-6 hours',
 'Stronger than average cubensis. Approach with respect and start conservatively. The energetic nature may not suit those prone to anxiety — a calm setting helps.',
 '{"visual", "euphoric", "energetic"}',
 '{"energetic", "tingly", "warm"}',
 '{"euphoric", "giggly", "energetic"}',
 'Regulated services available in Oregon and Colorado.'),

('Mazatec', 'psilocybin', 'Psilocybe cubensis', 'moderate', 'intermediate',
 'Named after the Mazatec people of Oaxaca, Mexico, who have used psilocybin mushrooms ceremonially for centuries. This variety carries a distinctly spiritual, contemplative character. Often described as producing a "teaching" experience with emphasis on emotional insight and connection to nature.',
 '30-60 min', '4-6 hours',
 'Best experienced in a quiet, intentional setting. The introspective nature of this variety can bring up deep emotions — having integration support available is recommended.',
 '{"spiritual", "introspective", "emotional"}',
 '{"warm", "relaxed", "light"}',
 '{"profound", "calm", "loving", "introspective"}',
 'Regulated services available in Oregon and Colorado.'),

('Penis Envy', 'psilocybin', 'Psilocybe cubensis', 'very_strong', 'experienced',
 'One of the most potent cubensis varieties known. Penis Envy produces deeply immersive experiences characterized by intense visual distortions, profound emotional breakthroughs, and strong physical sensations. The distinctively shaped fruiting bodies have above-average psilocybin concentrations.',
 '20-45 min', '5-8 hours',
 'Very high potency — significantly stronger than typical cubensis. This variety demands respect and experience. A trusted sitter and safe environment are essential. Not appropriate for beginners under any circumstances.',
 '{"visual", "spiritual", "euphoric", "introspective"}',
 '{"heavy", "warm", "tingly"}',
 '{"profound", "euphoric", "loving"}',
 'Regulated services available in Oregon and Colorado.'),

('Amazonian', 'psilocybin', 'Psilocybe cubensis', 'strong', 'intermediate',
 'A robust variety originating from the Amazon basin. Known for producing vivid, colorful visuals and a deeply connected, earthy experience. The Amazonian tends to create a strong sense of unity with nature and can produce powerful spiritual experiences.',
 '25-50 min', '5-6 hours',
 'Stronger than average. A nature setting can complement this variety well, but ensure safety and comfort. Stay with trusted companions.',
 '{"visual", "spiritual", "euphoric"}',
 '{"energetic", "warm", "tingly"}',
 '{"euphoric", "profound", "loving"}',
 'Regulated services available in Oregon and Colorado.'),

('Treasure Coast', 'psilocybin', 'Psilocybe cubensis', 'moderate', 'beginner',
 'Originally found on the Treasure Coast of Florida, this variety is known for its reliability and gentle, approachable character. Produces consistent experiences with pleasant visuals and a warm emotional tone. A solid choice for those seeking a predictable, manageable experience.',
 '30-60 min', '4-5 hours',
 'A forgiving variety suitable for beginners. Standard preparation applies — comfortable setting, trusted company, and adequate time set aside.',
 '{"visual", "calm", "euphoric"}',
 '{"warm", "light", "relaxed"}',
 '{"calm", "giggly", "euphoric"}',
 'Regulated services available in Oregon and Colorado.'),

('Albino A+', 'psilocybin', 'Psilocybe cubensis', 'moderate', 'beginner',
 'An albino variety known for its beautiful white appearance and gentle, dreamy experiences. Albino A+ produces soft visuals with a calm, meditative quality. The experience tends to be introspective without being overwhelming, making it approachable for newcomers.',
 '30-60 min', '4-5 hours',
 'A gentle variety well-suited to beginners. The dreamy quality can be enhanced by comfortable, dimly lit environments with soft music.',
 '{"visual", "calm", "introspective"}',
 '{"light", "warm", "relaxed"}',
 '{"calm", "introspective", "peaceful"}',
 'Regulated services available in Oregon and Colorado.');

-- ============================================================
-- AYAHUASCA VARIETIES
-- ============================================================

INSERT INTO varieties (name, substance_type, species, potency, difficulty, description, onset, duration, safety_notes, common_effects, body_feel, emotional_profile, legal_notes) VALUES

('Caapi + Chacruna', 'ayahuasca', 'Banisteriopsis caapi + Psychotria viridis', 'strong', 'experienced',
 'The traditional Amazonian preparation combining Banisteriopsis caapi vine with Chacruna leaves (Psychotria viridis). This is the most common and traditional ayahuasca combination, used by indigenous peoples for centuries in ceremonial contexts. Known for producing vivid visions, deep emotional processing, and profound spiritual experiences.',
 '30-60 min', '4-6 hours',
 'Should only be experienced in a supervised ceremonial or clinical setting with trained facilitators. Dietary restrictions (MAOI interactions) must be strictly followed for at least 2 weeks prior. Medical screening is essential — contraindicated with many medications including SSRIs.',
 '{"visual", "spiritual", "emotional", "introspective"}',
 '{"heavy", "warm"}',
 '{"profound", "loving", "introspective"}',
 'Legal in religious contexts in some jurisdictions. Retreat centers operate in various countries.'),

('Caapi + Mimosa', 'ayahuasca', 'Banisteriopsis caapi + Mimosa hostilis', 'strong', 'experienced',
 'An alternative ayahuasca preparation using Mimosa hostilis root bark instead of Chacruna. This combination tends to produce more intensely visual experiences with vivid geometric patterns and color fields. Some practitioners describe it as having a "sharper" visual quality compared to the traditional Chacruna preparation.',
 '20-45 min', '3-5 hours',
 'Same safety precautions as traditional ayahuasca apply. Supervised setting mandatory. Strict MAOI dietary restrictions required. Medical screening essential. Generally produces a slightly shorter but potentially more intense experience.',
 '{"visual", "introspective", "spiritual"}',
 '{"heavy", "tingly"}',
 '{"profound", "introspective", "calm"}',
 'Legal status varies. Retreat centers available internationally.'),

('Caapi + Chaliponga', 'ayahuasca', 'Banisteriopsis caapi + Diplopterys cabrerana', 'very_strong', 'experienced',
 'A powerful ayahuasca combination using Chaliponga leaves, which contain both DMT and 5-MeO-DMT. This preparation is known for producing exceptionally intense visionary experiences with strong somatic effects. Used in specific indigenous traditions, this is considered one of the most powerful ayahuasca preparations.',
 '30-60 min', '4-7 hours',
 'Extremely potent preparation — experienced practitioners only. Supervised ceremonial setting absolutely required. Full medical screening mandatory. The dual alkaloid content produces a uniquely intense experience that demands significant preparation and integration support.',
 '{"visual", "spiritual", "emotional"}',
 '{"heavy", "warm", "tingly"}',
 '{"profound", "spiritual", "introspective"}',
 'Legal status varies by jurisdiction.');

-- ============================================================
-- MESCALINE VARIETIES
-- ============================================================

INSERT INTO varieties (name, substance_type, species, potency, difficulty, description, onset, duration, safety_notes, common_effects, body_feel, emotional_profile, legal_notes) VALUES

('San Pedro', 'mescaline', 'Echinopsis pachanoi', 'moderate', 'intermediate',
 'San Pedro (Huachuma) is a columnar cactus native to the Andes that has been used in traditional ceremonies for over 3,000 years. Known for producing a gentle, heart-opening experience with beautiful visual enhancement and a strong sense of connection to nature. Often described as the "gentler" mescaline experience.',
 '1-2 hours', '8-12 hours',
 'The long duration requires planning — set aside a full day. Nausea during onset is common. A natural outdoor setting is traditional and often recommended. Stay hydrated. The gradual onset means patience is important — do not take more because effects seem slow.',
 '{"visual", "euphoric", "spiritual", "emotional"}',
 '{"warm", "energetic", "light"}',
 '{"euphoric", "loving", "calm", "profound"}',
 'San Pedro cactus is legal to grow as an ornamental in many jurisdictions. Extraction of mescaline is illegal in most places.'),

('Peyote', 'mescaline', 'Lophophora williamsii', 'strong', 'experienced',
 'A small, spineless cactus native to the deserts of Mexico and southern Texas. Peyote has been central to Native American spiritual practices for thousands of years and remains a sacrament in the Native American Church. Known for producing deeply spiritual, visionary experiences with a strong teaching quality.',
 '1-2 hours', '10-12 hours',
 'Sacred to many indigenous peoples — approach with deep cultural respect. The experience is typically more intense than San Pedro. Nausea is very common and considered part of the traditional experience. Extended duration requires full-day commitment and a safe setting.',
 '{"spiritual", "visual", "introspective"}',
 '{"heavy", "warm"}',
 '{"profound", "spiritual", "introspective", "calm"}',
 'Protected for religious use by the Native American Church under federal law. Otherwise Schedule I in the US. Conservation concerns — peyote is slow-growing and threatened.'),

('Peruvian Torch', 'mescaline', 'Echinopsis peruviana', 'moderate', 'intermediate',
 'A close relative of San Pedro, the Peruvian Torch cactus produces a similar but distinctly more energetic and visual experience. Native to the western slopes of the Andes, it has a long history of traditional use. Often described as having a "brighter" quality compared to San Pedro.',
 '1-2 hours', '8-10 hours',
 'Similar safety considerations to San Pedro. Long duration requires planning. Nausea during onset is common. The more stimulating character may not suit those prone to anxiety. A comfortable setting with nature access is ideal.',
 '{"visual", "euphoric", "energetic"}',
 '{"energetic", "tingly", "warm"}',
 '{"euphoric", "energetic", "calm"}',
 'Legal to grow as ornamental in many jurisdictions. Mescaline extraction is illegal in most places.');

-- ============================================================
-- KETAMINE FORMS
-- ============================================================

INSERT INTO varieties (name, substance_type, species, potency, difficulty, description, onset, duration, safety_notes, common_effects, body_feel, emotional_profile, legal_notes) VALUES

('IV Infusion', 'ketamine', 'Ketamine HCl', 'strong', 'experienced',
 'Administered intravenously in a clinical setting, typically over 40 minutes. IV infusion provides the most precise dosing control and is the most studied route for treatment-resistant depression. The experience is closely monitored by medical professionals throughout, with vital signs tracked continuously.',
 'Immediate', '45-60 min + afterglow',
 'Clinical setting with medical supervision required. Do not eat for 4-6 hours prior. Arrange transportation — do not drive after treatment. Some clinics offer integration therapy sessions. Side effects may include nausea, elevated blood pressure, and dissociation.',
 '{"dissociative", "introspective", "calm"}',
 '{"heavy", "warm", "floating"}',
 '{"calm", "introspective", "profound"}',
 'Legal with prescription. Available at licensed ketamine clinics across the US.'),

('Sublingual Troche', 'ketamine', 'Ketamine HCl', 'moderate', 'intermediate',
 'A lozenge that dissolves under the tongue over 15-20 minutes. The most common form for at-home therapeutic use under medical supervision. Sublingual administration has lower bioavailability than IV, producing a gentler experience. Typically prescribed as part of an ongoing treatment protocol with regular check-ins.',
 '15-30 min', '1-2 hours',
 'Only use as prescribed by a licensed provider. Do not combine with alcohol or other substances. Have someone present for your first experience. Stay in a safe, comfortable environment. Follow your providers protocol for frequency and integration.',
 '{"calm", "introspective", "emotional"}',
 '{"warm", "relaxed", "light"}',
 '{"calm", "introspective", "peaceful"}',
 'Legal with prescription. Commonly prescribed through telehealth ketamine therapy services.'),

('Nasal Spray (Spravato)', 'ketamine', 'Esketamine', 'moderate', 'intermediate',
 'FDA-approved esketamine (Spravato) nasal spray, administered in certified healthcare settings for treatment-resistant depression. This is the S-enantiomer of ketamine and must be taken under direct medical observation. Patients remain at the clinic for at least 2 hours after administration for monitoring.',
 '5-15 min', '1-2 hours',
 'Only available through the Spravato REMS program at certified treatment centers. Administered under medical supervision — you cannot take this home. Do not eat for 2 hours or drink liquids for 30 minutes before treatment. Arrange transportation.',
 '{"calm", "dissociative", "emotional"}',
 '{"light", "floating", "relaxed"}',
 '{"calm", "emotional", "peaceful"}',
 'FDA-approved (2019) for treatment-resistant depression. Covered by many insurance plans. Available at certified REMS treatment centers.'),

('Intramuscular (IM)', 'ketamine', 'Ketamine HCl', 'strong', 'experienced',
 'Injected into muscle tissue in clinical settings. IM administration produces a faster onset and more intense experience than sublingual, with higher bioavailability. Used in both therapeutic and research contexts. The experience tends to be more immersive and dissociative than other routes.',
 '5-10 min', '1-1.5 hours',
 'Clinical supervision required. The rapid onset and intensity mean this route is best suited for those with prior ketamine experience. Fasting beforehand is recommended. The more dissociative nature of IM administration may be challenging for some — discuss with your provider.',
 '{"dissociative", "visual", "introspective"}',
 '{"heavy", "floating", "warm"}',
 '{"profound", "introspective", "calm"}',
 'Legal with prescription. Available at licensed ketamine clinics.');

-- ============================================================
-- SERVICE CENTERS
-- ============================================================

INSERT INTO service_centers (name, description, address, city, state, zip, offerings, substance_types, is_verified, is_claimed, is_published) VALUES

('InnerVision Psilocybin Services', 
 'Licensed psilocybin service center offering facilitated sessions in a warm, nature-inspired setting. Our trained facilitators guide you through preparation, the experience itself, and integration. We serve adults seeking personal growth, emotional healing, and spiritual exploration.',
 '2847 Pearl St', 'Boulder', 'Colorado', '80302',
 '{"Facilitated sessions", "Preparation", "Integration", "Group ceremonies"}',
 '{"psilocybin"}', true, true, true),

('Clarity Ketamine Clinic',
 'Medical ketamine clinic specializing in IV infusion therapy for treatment-resistant depression, anxiety, PTSD, and chronic pain. Our board-certified anesthesiologists provide personalized treatment protocols in a safe, comfortable clinical environment.',
 '1560 Broadway Suite 200', 'Denver', 'Colorado', '80202',
 '{"IV Infusion", "Spravato (Esketamine)", "Integration therapy", "Ongoing protocols"}',
 '{"ketamine"}', true, true, true),

('Sacred Roots Healing Center',
 'Oregon-licensed psilocybin service center rooted in harm reduction and therapeutic principles. Our facilitators hold Oregon Psilocybin Services certifications and offer sessions tailored to individual intentions — from emotional processing to spiritual exploration.',
 '4215 SE Hawthorne Blvd', 'Portland', 'Oregon', '97215',
 '{"Facilitated sessions", "Preparation", "Integration", "Group experiences"}',
 '{"psilocybin"}', true, true, true),

('Mindful Horizons Wellness',
 'Comprehensive psychedelic-assisted wellness center offering ketamine therapy and psilocybin preparation/integration services. Our multidisciplinary team includes psychiatrists, therapists, and certified facilitators working together to support your journey.',
 '890 Main St Suite 100', 'Eugene', 'Oregon', '97401',
 '{"Ketamine therapy", "Preparation coaching", "Integration therapy", "Group integration circles"}',
 '{"ketamine", "psilocybin"}', true, true, true),

('Emerge Ketamine & Wellness',
 'Patient-centered ketamine clinic offering IV infusions and sublingual protocols for depression, anxiety, and PTSD. Our compassionate team creates a serene healing environment with personalized treatment plans and ongoing support.',
 '3300 S College Ave', 'Fort Collins', 'Colorado', '80525',
 '{"IV Infusion", "Sublingual protocols", "Integration support", "Telehealth follow-up"}',
 '{"ketamine"}', true, true, true),

('The Journeywork Collective',
 'A community-oriented psilocybin service center in Bend, Oregon. We offer both individual and small group facilitated sessions in a beautiful natural setting surrounded by the Cascade Mountains. Our approach emphasizes connection to nature, community, and personal intention.',
 '1200 NW Wall St', 'Bend', 'Oregon', '97703',
 '{"Facilitated sessions", "Group ceremonies", "Nature sessions", "Integration circles"}',
 '{"psilocybin"}', true, true, true);

-- Set initial ratings for display (will be overwritten by real reviews)
UPDATE varieties SET average_rating = 4.7, review_count = 23 WHERE name = 'Golden Teachers';
UPDATE varieties SET average_rating = 4.8, review_count = 15 WHERE name = 'Albino Penis Envy';
UPDATE varieties SET average_rating = 4.5, review_count = 19 WHERE name = 'B+';
UPDATE varieties SET average_rating = 4.6, review_count = 8 WHERE name = 'Liberty Caps';
UPDATE varieties SET average_rating = 4.4, review_count = 12 WHERE name = 'Blue Meanie';
UPDATE varieties SET average_rating = 4.5, review_count = 7 WHERE name = 'Mazatec';
UPDATE varieties SET average_rating = 4.9, review_count = 21 WHERE name = 'Penis Envy';
UPDATE varieties SET average_rating = 4.3, review_count = 9 WHERE name = 'Amazonian';
UPDATE varieties SET average_rating = 4.4, review_count = 11 WHERE name = 'Treasure Coast';
UPDATE varieties SET average_rating = 4.3, review_count = 6 WHERE name = 'Albino A+';
UPDATE varieties SET average_rating = 4.9, review_count = 14 WHERE name = 'Caapi + Chacruna';
UPDATE varieties SET average_rating = 4.7, review_count = 8 WHERE name = 'Caapi + Mimosa';
UPDATE varieties SET average_rating = 4.8, review_count = 5 WHERE name = 'Caapi + Chaliponga';
UPDATE varieties SET average_rating = 4.6, review_count = 11 WHERE name = 'San Pedro';
UPDATE varieties SET average_rating = 4.8, review_count = 6 WHERE name = 'Peyote';
UPDATE varieties SET average_rating = 4.4, review_count = 7 WHERE name = 'Peruvian Torch';
UPDATE varieties SET average_rating = 4.5, review_count = 18 WHERE name = 'IV Infusion';
UPDATE varieties SET average_rating = 4.3, review_count = 25 WHERE name = 'Sublingual Troche';
UPDATE varieties SET average_rating = 4.4, review_count = 13 WHERE name = 'Nasal Spray (Spravato)';
UPDATE varieties SET average_rating = 4.6, review_count = 9 WHERE name = 'Intramuscular (IM)';

UPDATE service_centers SET average_rating = 4.8, review_count = 34 WHERE name = 'InnerVision Psilocybin Services';
UPDATE service_centers SET average_rating = 4.7, review_count = 52 WHERE name = 'Clarity Ketamine Clinic';
UPDATE service_centers SET average_rating = 4.9, review_count = 28 WHERE name = 'Sacred Roots Healing Center';
UPDATE service_centers SET average_rating = 4.5, review_count = 19 WHERE name = 'Mindful Horizons Wellness';
UPDATE service_centers SET average_rating = 4.6, review_count = 41 WHERE name = 'Emerge Ketamine & Wellness';
UPDATE service_centers SET average_rating = 4.7, review_count = 15 WHERE name = 'The Journeywork Collective';
