#!/usr/bin/env python3
"""Designer A: Onboarding (3), Empty States (6), Home Banners (8) = 17 assets."""

import json, os, subprocess, sys, time, requests

API_KEY = subprocess.check_output(
    ["security", "find-generic-password", "-s", "openclaw-ideogram-api-key", "-w"], text=True
).strip()

BASE = os.path.dirname(__file__)
ASSETS = os.path.join(BASE, "..", "TripTalk", "Assets.xcassets")

def gen(name, prompt, folder, aspect="16x9", retries=2):
    out_dir = os.path.join(ASSETS, folder, f"{name}.imageset")
    os.makedirs(out_dir, exist_ok=True)
    img_file = os.path.join(out_dir, f"{name}.png")
    if os.path.exists(img_file):
        print(f"  SKIP {name}")
        return True

    full_prompt = prompt + (
        ". No text, no words, no labels, no letters. "
        "Premium quality, cinematic lighting, 8K detail."
    )

    for attempt in range(retries + 1):
        resp = requests.post(
            "https://api.ideogram.ai/v1/ideogram-v3/generate",
            headers={"Api-Key": API_KEY},
            files={
                "prompt": (None, full_prompt),
                "rendering_speed": (None, "TURBO"),
                "aspect_ratio": (None, aspect),
            },
            timeout=120,
        )
        if resp.ok:
            break
        if attempt < retries:
            print(f"  RETRY {name} (attempt {attempt+2})")
            time.sleep(3)
    
    if not resp.ok:
        print(f"  FAIL {name}: {resp.status_code} {resp.text[:200]}")
        return False

    data = resp.json()
    url = data.get("data", [{}])[0].get("url")
    if not url:
        print(f"  FAIL {name}: no URL in response")
        return False

    img = requests.get(url, timeout=60)
    with open(img_file, "wb") as f:
        f.write(img.content)

    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(out_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print(f"  OK   {name} ({len(img.content)/1024:.0f} KB)")
    return True


# ═══════════════════════════════════════════
# DIRECTION 1: Onboarding Illustrations (3)
# ═══════════════════════════════════════════
ONBOARDING = [
    ("onboarding_knowledge",
     "Warm editorial illustration of an open botanical field guide surrounded by natural specimens, "
     "pressed leaves, and a magnifying glass on a wooden desk, soft warm lamplight, "
     "cozy educational atmosphere, muted earth tones with green and gold accents, "
     "representing knowledge and learning about the natural world, "
     "soft watercolor-meets-photography hybrid style"),

    ("onboarding_safety",
     "Warm editorial illustration of two hands gently cradling a small glowing lantern "
     "in a peaceful forest clearing at dusk, soft golden light emanating outward, "
     "representing safety and harm reduction, protective and nurturing mood, "
     "muted greens and warm ambers, painterly soft focus style"),

    ("onboarding_community",
     "Warm editorial illustration of a diverse circle of people sitting together "
     "around a small campfire in a forest clearing at twilight, seen from above at an angle, "
     "warm golden firelight on faces, sense of connection and support, "
     "soft painterly style with warm earth tones and gentle bokeh lights"),
]

# ═══════════════════════════════════════════
# DIRECTION 3: Empty State Illustrations (6)
# ═══════════════════════════════════════════
EMPTY_STATES = [
    ("empty_saved",
     "Minimal soft illustration of an empty glass terrarium with a single small fern inside, "
     "gentle warm light, clean white-to-cream background, representing a collection waiting to grow, "
     "delicate line art with soft watercolor wash, muted green and gold"),

    ("empty_reports",
     "Minimal soft illustration of a blank open journal with a pen resting on it, "
     "a small dried flower pressed between pages, warm soft light from the side, "
     "clean cream background, representing stories waiting to be written, "
     "delicate line art with soft watercolor wash"),

    ("empty_reviews",
     "Minimal soft illustration of empty speech bubbles floating gently upward like bubbles, "
     "soft gradient background from warm cream to pale green, "
     "representing conversations waiting to happen, "
     "delicate line art with soft watercolor wash"),

    ("empty_search",
     "Minimal soft illustration of a magnifying glass over a misty landscape, "
     "nothing visible through the lens yet, soft morning fog, "
     "clean cream to white background, representing discovery ahead, "
     "delicate line art with soft watercolor wash, muted teal accents"),

    ("empty_services",
     "Minimal soft illustration of a compass resting on a blank map, "
     "warm golden light catching the compass needle, clean cream background, "
     "representing journeys and guidance waiting to be found, "
     "delicate line art with soft watercolor wash"),

    ("empty_welcome",
     "Minimal soft illustration of a door slightly ajar with warm golden light "
     "spilling through the crack into a dim room, a small plant beside the doorframe, "
     "clean background, representing new beginnings and welcome, "
     "delicate line art with soft watercolor wash, warm gold and green"),
]

# ═══════════════════════════════════════════
# DIRECTION 5: Home Screen Rotating Banners (8)
# ═══════════════════════════════════════════
HOME_BANNERS = [
    ("home_spring",
     "Lush spring forest floor with new mushrooms emerging through moss and wildflowers, "
     "morning golden light filtering through canopy, dew drops, fresh and alive, "
     "professional nature photography, National Geographic quality, vibrant greens and golds"),

    ("home_summer",
     "Sun-drenched desert landscape with blooming San Pedro cacti and wildflowers, "
     "golden hour warm light, vast open sky with soft clouds, "
     "professional nature photography, warm earth tones and sky blues"),

    ("home_autumn",
     "Misty autumn forest with fallen leaves and mushrooms growing on a mossy log, "
     "soft diffused light through fog, rich amber and copper tones, "
     "professional nature photography, contemplative and peaceful"),

    ("home_winter",
     "Snow-dusted evergreen forest at dawn with soft pink-gold sky, "
     "peaceful and still, a frozen creek in foreground, "
     "professional nature photography, cool blues and warm sky highlights"),

    ("home_mindfulness",
     "Still mountain lake at dawn with perfect mirror reflection, "
     "single small boat, mist rising, profound calm and stillness, "
     "professional landscape photography, teal and gold palette"),

    ("home_botanical",
     "Overhead flat-lay of dried botanical specimens arranged artfully on aged paper, "
     "pressed flowers, leaves, seeds, a small brass compass, "
     "warm studio lighting, rich earth tones, scientific yet beautiful"),

    ("home_healing",
     "Warm therapy room with a comfortable chair by a window, "
     "soft natural light, a small potted plant, minimalist and safe feeling, "
     "clean modern interior photography, warm neutrals with green accent"),

    ("home_stargazing",
     "Clear night sky with Milky Way visible over a peaceful mountain meadow, "
     "a single warm lantern glowing on the ground, vast and awe-inspiring, "
     "professional astrophotography, deep blues and warm lantern glow"),
]

def main():
    all_assets = [
        ("Onboarding", ONBOARDING, "Onboarding", "16x9"),
        ("Empty States", EMPTY_STATES, "EmptyStates", "1x1"),
        ("Home Banners", HOME_BANNERS, "HomeBanners", "16x9"),
    ]

    total = sum(len(items) for _, items, _, _ in all_assets)
    print(f"Designer A: Generating {total} assets across 3 directions\n")

    ok = fail = 0
    for section_name, items, folder, aspect in all_assets:
        print(f"\n{'='*50}")
        print(f"  {section_name} ({len(items)} assets, {aspect})")
        print(f"{'='*50}")
        for i, (name, prompt) in enumerate(items):
            print(f"[{i+1}/{len(items)}] {name}")
            if gen(name, prompt, folder, aspect):
                ok += 1
            else:
                fail += 1
            time.sleep(2)

    print(f"\n\nDesigner A complete: {ok} ok, {fail} failed")

if __name__ == "__main__":
    main()
