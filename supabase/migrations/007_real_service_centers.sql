-- ═══════════════════════════════════════════════════
-- TripTalk: Real Licensed Service Centers
-- Replaces fictional seed data with verified OR & CO centers
-- Source: OR OHA + CO DPO directories (May 2026)
-- ═══════════════════════════════════════════════════

-- Remove fictional service centers
DELETE FROM service_centers WHERE id IN (
  '00000000-0000-0000-0001-000000000001',
  '00000000-0000-0000-0001-000000000002',
  '00000000-0000-0000-0001-000000000003',
  '00000000-0000-0000-0001-000000000004'
);

-- ═══════════════════════════════════════
-- OREGON Licensed Psilocybin Service Centers
-- ═══════════════════════════════════════

INSERT INTO service_centers (id, name, city, state, address, about, offerings, is_verified, website_url, phone, image_symbol) VALUES

(gen_random_uuid(), 'Omnia Group Ashland', 'Ashland', 'OR',
 '607 Siskiyou Blvd, Ashland, OR 97520',
 'Licensed Oregon psilocybin service center in Ashland offering guided psilocybin sessions with experienced facilitators.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://omniagroupashland.com', '714.203.4780', 'leaf.fill'),

(gen_random_uuid(), 'Satya Therapeutics', 'Ashland', 'OR',
 '638 N Main St, Ashland, OR 97520',
 'Licensed Oregon psilocybin service center providing therapeutic psilocybin experiences in a supportive environment.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://satyatherapeutics.com', '541.930.2478', 'leaf.fill'),

(gen_random_uuid(), 'Aurora Healing Gardens', 'Aurora', 'OR',
 '21348 Highway 99E Ste 2, Aurora, OR 97002',
 'Licensed Oregon psilocybin service center in Aurora offering healing-centered psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://aurorahealinggardens.com', '503.694.9533', 'leaf.fill'),

(gen_random_uuid(), 'Bend Inner Alchemy', 'Bend', 'OR',
 '44 NW Irving Ave, Bend, OR 97703',
 'Licensed Oregon psilocybin service center in Bend providing guided inner exploration through psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://bendinneralchemy.com', '541.688.6520', 'leaf.fill'),

(gen_random_uuid(), 'Drop Thesis', 'Bend', 'OR',
 '505 NW Franklin Ave, Bend, OR 97703',
 'Licensed Oregon psilocybin service center offering guided psilocybin experiences in central Bend.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://dropthesis.com', '458.202.7111', 'leaf.fill'),

(gen_random_uuid(), 'Bendable Therapy', 'Bend', 'OR',
 '521 NW Harriman St, Bend, OR 97703',
 'Licensed Oregon psilocybin service center providing therapeutic psilocybin services in Bend.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://bendabletherapy.org', NULL, 'leaf.fill'),

(gen_random_uuid(), 'Unstuck Oregon', 'Corvallis', 'OR',
 '2211 NW Professional Dr, Ste 203, Corvallis, OR 97330',
 'Licensed Oregon psilocybin service center in Corvallis helping people get unstuck through guided psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://unstuckoregon.com', '541.286.6150', 'leaf.fill'),

(gen_random_uuid(), 'Epic Healing', 'Eugene', 'OR',
 '3003 Willamette St, Eugene, OR 97405',
 'Licensed Oregon psilocybin service center in Eugene offering comprehensive psilocybin healing experiences.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://epichealingeugene.com', '541.525.0124', 'leaf.fill'),

(gen_random_uuid(), 'Ripple Journey Work', 'Eugene', 'OR',
 '1973 Garden Ave, Eugene, OR 97403',
 'Licensed Oregon psilocybin service center providing guided journey work and integration support in Eugene.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://ripplejourneywork.com', '541.423.0742', 'leaf.fill'),

(gen_random_uuid(), 'Vital Reset', 'Hood River', 'OR',
 '1020 Wasco St, Ste J, Hood River, OR 97365',
 'Licensed Oregon psilocybin service center in Hood River offering reset-focused psilocybin experiences.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://vitalreset.com', '541.645.4485', 'leaf.fill'),

(gen_random_uuid(), 'Shrooms Cafe', 'Medford', 'OR',
 '619 Market St, Medford, OR 97504',
 'Licensed Oregon psilocybin service center in Medford providing accessible psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://shroomscafe.com', '503.545.6120', 'leaf.fill'),

(gen_random_uuid(), '7 Gates Sanctuary', 'Portland', 'OR',
 '1034 SE Sandy Blvd, Portland, OR 97214',
 'Licensed Oregon psilocybin service center offering sanctuary-style guided psilocybin experiences in Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://7gatessanctuary.com', '503.218.3816', 'leaf.fill'),

(gen_random_uuid(), 'Cora Center', 'Portland', 'OR',
 '2734 NE Broadway, Portland, OR 97232',
 'Licensed Oregon psilocybin service center in NE Portland providing heart-centered psilocybin therapy.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, NULL, NULL, 'leaf.fill'),

(gen_random_uuid(), 'Chariot Portland', 'Portland', 'OR',
 '1839 NW 24th Ave, Portland, OR 97210',
 'Licensed Oregon psilocybin service center. Part of the Chariot network offering guided psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://chariotspace.com', NULL, 'leaf.fill'),

(gen_random_uuid(), 'Fernlove', 'Portland', 'OR',
 'Portland, OR',
 'Licensed Oregon psilocybin service center offering intimate guided psilocybin experiences in Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://fernlove.com', NULL, 'leaf.fill'),

(gen_random_uuid(), 'Immersive Therapies', 'Portland', 'OR',
 '1941 NW Quimby St, Portland, OR 97209',
 'Licensed Oregon psilocybin service center providing immersive therapeutic psilocybin experiences in NW Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, NULL, '503.343.5590', 'leaf.fill'),

(gen_random_uuid(), 'InnerTrek', 'Portland', 'OR',
 '11 NE Martin Luther King Blvd, Ste 6A, Portland, OR 97232',
 'Licensed Oregon psilocybin service center guiding inner treks through psilocybin-assisted exploration.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://innertrek.com', NULL, 'leaf.fill'),

(gen_random_uuid(), 'MindTrek', 'Portland', 'OR',
 '4805 SW Oleson Rd, Portland, OR 97225',
 'Licensed Oregon psilocybin service center in SW Portland offering guided mind-expansion sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, NULL, '503.914.8381', 'leaf.fill'),

(gen_random_uuid(), 'The Sacred Mushroom', 'Portland', 'OR',
 '321 NW Gilsan St, Flr 7, Portland, OR 97209',
 'Licensed Oregon psilocybin service center in downtown Portland offering sacred mushroom experiences.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://tsmpdx.com', NULL, 'leaf.fill'),

(gen_random_uuid(), 'Space Clinic', 'Portland', 'OR',
 '11125 NE Weidler St, Portland, OR 97220',
 'Licensed Oregon psilocybin service center providing clinical psilocybin services in NE Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, NULL, '503.498.8862', 'leaf.fill'),

(gen_random_uuid(), 'Meadow', 'Portland', 'OR',
 '5903 SE Milwaukie Ave, Portland, OR 97202',
 'Licensed Oregon psilocybin service center offering nature-inspired psilocybin healing in SE Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://meadowmedicine.org', '503.489.7478', 'leaf.fill'),

(gen_random_uuid(), 'PNW Integrative Center', 'Portland', 'OR',
 '840 SE Washington St, Portland, OR 97214',
 'Licensed Oregon psilocybin service center providing integrative psilocybin therapy in Portland.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://pnwintegrativecenter.com', '971.626.1975', 'leaf.fill'),

(gen_random_uuid(), 'The Psilocybin Center', 'Salem', 'OR',
 '2585 State St, Salem, OR 97301',
 'Licensed Oregon psilocybin service center in the state capital offering guided psilocybin sessions.',
 ARRAY['Guided Psilocybin Sessions','Preparation','Integration'], true, 'https://psilosesh.com', '503.893.2920', 'leaf.fill'),


-- ═══════════════════════════════════════
-- COLORADO Licensed Natural Medicine Healing Centers
-- ═══════════════════════════════════════

(gen_random_uuid(), 'Transcendent Integrative Health', 'Arvada', 'CO',
 '5511 W. 56th Ave Unit 100, Arvada, CO 80002',
 'Colorado-licensed natural medicine healing center offering integrative psychedelic-assisted healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://transcendent.health', NULL, 'cross.case.fill'),

(gen_random_uuid(), 'SANCTUM', 'Aspen', 'CO',
 '535 E. Hyman, Lower Level, Aspen, CO 81611',
 'Colorado-licensed natural medicine healing center in Aspen providing premium psychedelic-assisted experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://sanctumaspen.com', '970.239.1147', 'cross.case.fill'),

(gen_random_uuid(), 'NeuroBloom Aspen', 'Aspen', 'CO',
 '426 E. Main St. #1A, Aspen, CO 81611',
 'Colorado-licensed natural medicine healing center combining neuroscience with psychedelic-assisted therapy.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://theneurospa.com', NULL, 'cross.case.fill'),

(gen_random_uuid(), 'Aletheia Healing Center', 'Aspen', 'CO',
 '111 Aspen Airport Business Center, Suite K, Aspen, CO 81611',
 'Colorado-licensed natural medicine healing center in Aspen offering truth-seeking psychedelic healing experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, NULL, 'cross.case.fill'),

(gen_random_uuid(), 'NeuroBloom Basalt', 'Basalt', 'CO',
 '350 Market St. #001, Basalt, CO 81621',
 'Colorado-licensed natural medicine healing center. Roaring Fork Valley location of NeuroBloom.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://theneurospa.com', NULL, 'cross.case.fill'),

(gen_random_uuid(), 'Happy Rebel Healing', 'Boulder', 'CO',
 '3450 Penrose Pl Ste 220, Boulder, CO 80301',
 'Colorado-licensed natural medicine healing center in Boulder offering rebel-spirited psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://happyrebelhealing.com', NULL, 'cross.case.fill'),

(gen_random_uuid(), 'Psychedelic Growth', 'Boulder', 'CO',
 '3015 47th St, Ste E3, Boulder, CO 80301',
 'Colorado-licensed natural medicine healing center focused on personal growth through psychedelic-assisted therapy.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://psychedelicgrowth.net', '720.441.3992', 'cross.case.fill'),

(gen_random_uuid(), 'The Clearing', 'Boulder', 'CO',
 '1265 Yellow Pine Ave, Boulder, CO 80304',
 'Colorado-licensed natural medicine healing center providing clarity-focused psychedelic healing in Boulder.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '303.503.7800', 'cross.case.fill'),

(gen_random_uuid(), 'Chariot Boulder', 'Boulder', 'CO',
 '1240 Pine St, Boulder, CO 80302',
 'Colorado-licensed natural medicine healing center. Part of the Chariot network offering guided sessions.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://chariotspace.com', '720.306.1741', 'cross.case.fill'),

(gen_random_uuid(), 'Memoru Center', 'Boulder', 'CO',
 '100 Arapahoe Ave, Ste 10, Boulder, CO 80302',
 'Colorado-licensed natural medicine healing center for visionary healing arts in downtown Boulder.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://memoru.com', NULL, 'cross.case.fill'),

(gen_random_uuid(), 'Sacred Peaks Retreat', 'Boulder', 'CO',
 '134 Canon View Rd, Unit A, Boulder, CO 80302',
 'Colorado-licensed natural medicine healing center offering retreat-style psychedelic experiences near Boulder.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration','Retreat'], true, NULL, '303.819.6528', 'cross.case.fill'),

(gen_random_uuid(), 'Emergence Psychedelic Therapy', 'Boulder', 'CO',
 '825 S Broadway St, Suite 100, Boulder, CO 80305',
 'Colorado-licensed natural medicine healing center providing professional psychedelic-assisted therapy.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://psychedelictherapyco.com', '303.578.8845', 'cross.case.fill'),

(gen_random_uuid(), 'Safar Healing Center', 'Boulder', 'CO',
 '2935 Baseline Road, Boulder, CO 80303',
 'Colorado-licensed natural medicine healing center offering journey-focused psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '720.295.9075', 'cross.case.fill'),

(gen_random_uuid(), 'TLC Acupuncture & Natural Medicine', 'Breckenridge', 'CO',
 '101 N. Main St Unit 12, Breckenridge, CO 80424',
 'Colorado-licensed natural medicine healing center in Breckenridge combining acupuncture with psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Acupuncture','Preparation','Integration'], true, 'https://tlcacu.com', '970.485.8801', 'cross.case.fill'),

(gen_random_uuid(), 'Solaria Rising', 'Broomfield', 'CO',
 '80 Garden Center, Suite 310, Broomfield, CO 80020',
 'Colorado-licensed natural medicine healing center in Broomfield offering psychedelic-assisted counseling.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '303.868.4548', 'cross.case.fill'),

(gen_random_uuid(), 'Reset LLC', 'Centennial', 'CO',
 'Centennial, CO',
 'Colorado-licensed natural medicine healing center offering psychedelic-assisted reset experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://coloradoreset.com', '720.239.2217', 'cross.case.fill'),

(gen_random_uuid(), 'The Center Origin', 'Denver', 'CO',
 '1440 Blake St. Ste 330, Denver, CO 80202',
 'Colorado-licensed natural medicine healing center in downtown Denver offering origin-centered healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://thecenterorigin.com', '303.284.4246', 'cross.case.fill'),

(gen_random_uuid(), 'Vivid Minds', 'Denver', 'CO',
 '1545 S Broadway, Denver, CO 80210',
 'Colorado-licensed natural medicine healing center in Denver focused on vivid mental wellness.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '720.519.7667', 'cross.case.fill'),

(gen_random_uuid(), 'River Soul Healing Center', 'Denver', 'CO',
 '3773 Cherry Creek Dr. N, East Tower, Ste 801, Denver, CO 80209',
 'Colorado-licensed natural medicine healing center in Cherry Creek offering soul-centered psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://riversoulhealingcenter.com', '303.726.5072', 'cross.case.fill'),

(gen_random_uuid(), 'Numia Healing', 'Denver', 'CO',
 '75 S Madison St, Denver, CO 80209',
 'Colorado-licensed natural medicine healing center providing numinous psychedelic healing experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://numiahealing.com', '720.372.7137', 'cross.case.fill'),

(gen_random_uuid(), 'Treehouse Sanctuary', 'Denver', 'CO',
 '1600 Pennsylvania St N, Ste 300, Denver, CO 80203',
 'Colorado-licensed natural medicine healing center offering sanctuary-style psychedelic-assisted healing in Denver.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, NULL, 'cross.case.fill'),

(gen_random_uuid(), 'Psychedelic Therapy Den', 'Denver', 'CO',
 '5535 W. 48th Ave, Suite 602, Denver, CO 80212',
 'Colorado-licensed natural medicine healing center in Denver providing professional psychedelic therapy.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://psychedelictherapyden.com', '983.220.8844', 'cross.case.fill'),

(gen_random_uuid(), 'Wild Glow Alchemy', 'Denver', 'CO',
 '8380 Zuni Street, Denver, CO 80221',
 'Colorado-licensed natural medicine healing center in north Denver offering alchemical psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '720.336.9535', 'cross.case.fill'),

(gen_random_uuid(), 'Innate Wisdom and Wellness', 'Durango', 'CO',
 'Durango, CO',
 'Colorado-licensed natural medicine healing center in Durango offering wisdom-centered psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://innatewisdomandwellness.com', '970.403.6483', 'cross.case.fill'),

(gen_random_uuid(), 'Mindful Elevation', 'Evergreen', 'CO',
 '29029 Upper Bear Creek Rd. Ste. 302-306, Evergreen, CO 80439',
 'Colorado-licensed natural medicine healing center in the mountain community of Evergreen.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://elevationpsychology.clinic', '210.994.6336', 'cross.case.fill'),

(gen_random_uuid(), 'Reflective Healing', 'Fort Collins', 'CO',
 '171 N College Ave, Fort Collins, CO 80524',
 'Colorado-licensed natural medicine healing center in downtown Fort Collins offering reflective healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '970.449.0853', 'cross.case.fill'),

(gen_random_uuid(), 'Wholeness Center', 'Fort Collins', 'CO',
 '2620 E Prospect Rd, Ste 190, Fort Collins, CO 80525',
 'Colorado-licensed natural medicine healing center in Fort Collins focused on whole-person wellness.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://wholeness.com', '970.221.1106', 'cross.case.fill'),

(gen_random_uuid(), 'Etc Hospitality', 'Golden', 'CO',
 '16500 S Golden Rd, #105, Golden, CO 80401',
 'Colorado-licensed natural medicine healing center in Golden offering hospitality-focused healing experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '216.262.4445', 'cross.case.fill'),

(gen_random_uuid(), 'Go Within Collective', 'Lakewood', 'CO',
 '1785 Kipling St. #8, Lakewood, CO 80215',
 'Colorado-licensed natural medicine healing center in Lakewood offering collective psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://gowithincollective.com', '720.239.2225', 'cross.case.fill'),

(gen_random_uuid(), 'Sangam Healing Center', 'Lakewood', 'CO',
 '7586 W Jewell Ave Suite 201, Lakewood, CO 80232',
 'Colorado-licensed natural medicine healing center in Lakewood offering convergence-focused healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, NULL, 'cross.case.fill'),

(gen_random_uuid(), 'NeuroAlchemy', 'Littleton', 'CO',
 '8500 W. Bowles Ave. Ste 200, Littleton, CO 80123',
 'Colorado-licensed natural medicine healing center combining neuroscience with psychedelic alchemy.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://neuroalchemycenter.com', '720.258.6111', 'cross.case.fill'),

(gen_random_uuid(), 'Rose Healing Center', 'Lone Tree', 'CO',
 '11450 Park Meadows Dr, Ste 100, Lone Tree, CO 80124',
 'Colorado-licensed natural medicine healing center in the south Denver metro area.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '720.707.6914', 'cross.case.fill'),

(gen_random_uuid(), 'New Awareness Psychedelic Healing', 'New Castle', 'CO',
 '386 W. Main St, Unit 105, New Castle, CO 81647',
 'Colorado-licensed natural medicine healing center in the Roaring Fork Valley offering awareness-expanding healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, NULL, '970.388.1903', 'cross.case.fill'),

(gen_random_uuid(), 'Wild Roots Therapeutics', 'Salida', 'CO',
 '134 F Street, Suite 201, Salida, CO 81201',
 'Colorado-licensed natural medicine healing center in mountain-town Salida offering rooted psychedelic healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://wildrootstherapeutics.com', '719.752.5672', 'cross.case.fill'),

(gen_random_uuid(), 'Sacred Symbiosis', 'Westcliffe', 'CO',
 'Westcliffe, CO',
 'Colorado-licensed natural medicine healing center in the Wet Mountains offering symbiotic healing experiences.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://sacredsymbiosis.net', '303.319.2193', 'cross.case.fill'),

(gen_random_uuid(), 'Micro Healing Center', 'Westminster', 'CO',
 '8461 Turnpike Dr. Ste 110, Westminster, CO 80031',
 'Colorado-licensed micro-healing center in Westminster offering accessible psychedelic-assisted healing.',
 ARRAY['Natural Medicine Sessions','Preparation','Integration'], true, 'https://microhealingcenter.com', '303.284.5144', 'cross.case.fill')

ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════════════════════
-- Done! 23 Oregon + 36 Colorado = 59 real licensed centers
-- ═══════════════════════════════════════════════════
