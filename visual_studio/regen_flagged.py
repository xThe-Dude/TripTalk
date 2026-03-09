#!/usr/bin/env python3
"""CD Round 2: Regenerate 6 flagged assets with refined prompts."""

import json, os, subprocess, time, requests

API_KEY = subprocess.check_output(
    ["security", "find-generic-password", "-s", "openclaw-ideogram-api-key", "-w"], text=True
).strip()

BASE = os.path.join(os.path.dirname(__file__), "..", "TripTalk", "Assets.xcassets")

def gen(name, prompt, folder, aspect="16x9"):
    out_dir = os.path.join(BASE, folder, f"{name}.imageset")
    os.makedirs(out_dir, exist_ok=True)
    img_file = os.path.join(out_dir, f"{name}.png")
    # Remove old version
    if os.path.exists(img_file):
        os.remove(img_file)

    full_prompt = prompt + (
        ". No text, no words, no labels, no letters. "
        "Premium quality, cinematic lighting, 8K detail."
    )

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
    if not resp.ok:
        print(f"  FAIL {name}: {resp.status_code} {resp.text[:200]}")
        return False

    data = resp.json()
    url = data.get("data", [{}])[0].get("url")
    if not url:
        print(f"  FAIL {name}: no URL")
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


REGENS = [
    # Onboarding knowledge — needs clean negative space, less clutter
    ("onboarding_knowledge",
     "Warm soft-focus photograph of a single open book on a wooden table, "
     "gentle warm reading lamp light from the left, a small succulent plant beside it, "
     "clean minimal composition with generous negative space in the upper half for text overlay, "
     "warm amber and cream tones, shallow depth of field, cozy and inviting, "
     "representing knowledge and mindful learning, editorial photography style",
     "Onboarding", "16x9"),

    # Empty reviews — match watercolor + line art style of terrarium/notebook/compass
    ("empty_reviews",
     "Minimal delicate watercolor illustration of two small empty speech bubbles "
     "floating gently like leaves, soft warm cream background, "
     "clean thin line art outlines with gentle sage green and warm gold watercolor washes, "
     "same style as a botanical watercolor sketch, minimal and elegant, "
     "lots of white space, representing conversations waiting to begin",
     "EmptyStates", "1x1"),

    # Empty search — match watercolor style
    ("empty_search",
     "Minimal delicate watercolor illustration of a magnifying glass resting on its side, "
     "small botanical elements like a tiny leaf and seed nearby, "
     "soft warm cream background, clean thin line art outlines with gentle "
     "sage green and warm gold watercolor washes, same style as a botanical sketch, "
     "lots of white space, representing discovery ahead",
     "EmptyStates", "1x1"),

    # Empty welcome — match watercolor style
    ("empty_welcome",
     "Minimal delicate watercolor illustration of a small seedling sprouting from soil "
     "with two tiny leaves unfurling, a single dewdrop on one leaf, "
     "soft warm cream background, clean thin line art outlines with gentle "
     "sage green and warm gold watercolor washes, same style as a botanical sketch, "
     "lots of white space, representing new beginnings and growth",
     "EmptyStates", "1x1"),

    # Home spring — replace mushrooms with nature (no substance reference)
    ("home_spring",
     "Stunning professional landscape photograph of a lush green forest clearing "
     "in spring with wildflowers blooming, soft morning golden light filtering through trees, "
     "dew on grass, fresh and alive, a small stream winding through, "
     "National Geographic quality nature photography, vibrant greens and soft gold highlights, "
     "peaceful and rejuvenating atmosphere",
     "HomeBanners", "16x9"),

    # Home botanical — cleaner, more premium, less cluttered
    ("home_botanical",
     "Professional overhead photograph of a minimal arrangement of three dried botanical specimens "
     "on handmade textured paper, lots of breathing room between specimens, "
     "soft warm studio lighting from above, muted earth tones, "
     "clean minimal composition in the style of Kinfolk magazine, "
     "elegant and refined, scientific yet artistic",
     "HomeBanners", "16x9"),
]

print(f"CD Round 2: Regenerating {len(REGENS)} flagged assets\n")
ok = fail = 0
for i, (name, prompt, folder, aspect) in enumerate(REGENS):
    print(f"[{i+1}/{len(REGENS)}] {name}")
    if gen(name, prompt, folder, aspect):
        ok += 1
    else:
        fail += 1
    time.sleep(2)
print(f"\nDone: {ok} ok, {fail} failed")
