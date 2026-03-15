# TripTalk — Data Taxonomy

## Entity Relationship

```
SubstanceType (4)
  └── Strain (15)
        ├── [EffectTag] (15 possible)
        ├── [BodyFeel] (6 possible)
        ├── [EmotionalTag] (7 possible)
        ├── Potency (4 levels)
        ├── Difficulty (3 levels)
        ├── TripReport (many)
        │     ├── TripSetting (5 types)
        │     ├── [MoodTag] (8 possible)
        │     └── Intensity ratings (visual/body/emotional, 1-5)
        └── Review (many)
              ├── Rating (1-5 stars)
              └── [EffectTag]
```

## Tables & Fields

### Strain (primary browsable entity)
| Field | Type | Values |
|---|---|---|
| name | String | "Golden Teachers", "Albino Penis Envy", etc. |
| parentSubstance | SubstanceType | psilocybin, ayahuasca, mescaline, ketamine |
| species | String | "Psilocybe cubensis", "B. caapi + P. viridis", "Ketamine HCl", etc. |
| potency | Potency | mild (1), moderate (2), strong (3), veryStrong (4) |
| description | String | Long-form educational description |
| commonEffects | [EffectTag] | Array of 3-5 effects per strain |
| bodyFeel | [BodyFeel] | Array of 2-3 body sensations |
| emotionalProfile | [EmotionalTag] | Array of 2-3 emotional states |
| onset | String | "30-60 min", "Immediate", etc. |
| duration | String | "4-6 hours", "45-60 min + afterglow", etc. |
| difficulty | Difficulty | beginner, intermediate, experienced |
| averageRating | Double | 4.2 – 4.9 |
| reviewCount | Int | 16 – 89 |
| communityPhotoCount | Int | Placeholder |

### SubstanceType (4 categories + Other)
| Value | Icon | Color | Category Image |
|---|---|---|---|
| Psilocybin | leaf.fill | green | category_psilocybin |
| Ayahuasca | drop.fill | purple | category_ayahuasca |
| Mescaline | sun.max.fill | orange | category_mescaline |
| Ketamine | waveform.path.ecg | teal | category_ketamine |

### EffectTag (15 values)
| Tag | Color Domain |
|---|---|
| Euphoria, Relaxation, Energizing, Creativity | General (ttGlow) |
| Visual Distortions, Synesthesia | Visual (ttVisual) |
| Body High, Nausea | Body (ttBody) |
| Empathy, Emotional Release, Anxiety | Emotional (ttEmotional) |
| Introspection, Spiritual Experience, Ego Dissolution | Spiritual (ttSpiritual) |
| Dissociation | General (ttGlow) |

### BodyFeel (6 values)
Warm, Heavy, Tingly, Light, Energetic, Relaxed

### EmotionalTag (7 values)
Calm, Giggly, Profound, Anxious, Euphoric, Loving, Introspective

### Potency (4 levels)
| Level | Label | Color |
|---|---|---|
| 1 | Mild | Green |
| 2 | Moderate | Yellow |
| 3 | Strong | Orange |
| 4 | Very Strong | Red |

### Difficulty (3 levels)
| Label | Color |
|---|---|
| Beginner Friendly | Green |
| Intermediate | Yellow |
| Experienced | Red |

### TripReport
| Field | Type |
|---|---|
| strainID | UUID (→ Strain) |
| authorName | String |
| date | Date |
| setting | TripSetting (Nature/Home/Ceremony/Social/Festival) |
| moods | [MoodTag] |
| visualIntensity | Int (1-5) |
| bodyIntensity | Int (1-5) |
| emotionalIntensity | Int (1-5) |
| highlights | String |
| rating | Int (1-5) |
| wouldRepeat | Bool |

### Review
| Field | Type |
|---|---|
| strainID | UUID (→ Strain) |
| authorName | String |
| date | Date |
| title | String |
| body | String |
| rating | Int (1-5) |
| tags | [EffectTag] |
| helpfulCount | Int |

### TripSetting (5 values)
| Value | Icon |
|---|---|
| Nature | leaf.fill |
| Home | house.fill |
| Ceremony | flame.fill |
| Social | person.3.fill |
| Festival | music.note |

### MoodTag (8 values)
Euphoric, Calm, Anxious, Giggly, Profound, Peaceful, Energetic, Loving
