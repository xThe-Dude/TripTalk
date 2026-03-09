#!/usr/bin/env python3
"""Regenerate mushroom strains with photorealistic documentary style."""

import json, os, subprocess, sys, time, requests

API_KEY = os.environ.get("IDEOGRAM_API_KEY")
if not API_KEY:
    try:
        API_KEY = subprocess.check_output(
            ["security", "find-generic-password", "-s", "openclaw-ideogram-api-key", "-w"], text=True
        ).strip()
    except: API_KEY = None
if not API_KEY:
    print("ERROR: No API key"); sys.exit(1)

OUT_DIR = os.path.join(os.path.dirname(__file__), "TripTalk", "Assets.xcassets", "StrainHeroes")

STYLE = (
    "Professional nature documentary photograph, DSLR macro photography, photorealistic, "
    "razor sharp focus, natural lighting, shallow depth of field with creamy bokeh, "
    "scientifically accurate, high fidelity to real species appearance, "
    "no text, no words, no labels, no digital effects, no neon glow, no bioluminescence, "
    "National Geographic quality, 8K resolution, natural colors only"
)

MUSHROOMS = [
    ("golden_teachers",
     "Cluster of real Psilocybe cubensis Golden Teacher mushrooms, golden-brown convex caps with lighter edges, "
     "white sturdy stems with slight bluish bruising at base, growing from brown rice flour substrate, "
     "warm natural daylight, earthy forest floor setting with leaf litter"),

    ("albino_penis_envy",
     "Real Albino Penis Envy Psilocybe cubensis mushrooms, distinctive thick bulbous white stems with small round caps, "
     "waxy pale white coloring throughout, dense meaty texture visible, slight blue bruising on stems, "
     "studio-quality macro photo on dark natural background"),

    ("b_plus",
     "Real B+ Psilocybe cubensis mushrooms, light caramel-tan colored caps that are broad and flat when mature, "
     "tall white stems, classic cubensis proportions, healthy specimens growing in cluster, "
     "warm soft natural light, clean earthy background"),

    ("liberty_caps",
     "Real Psilocybe semilanceata Liberty Cap mushrooms growing wild in grass, small distinctive pointed conical caps "
     "with nipple-like umbo on top, olive-brown to tan coloring, thin delicate pale stems, "
     "morning dew on grass, misty temperate meadow, overcast natural lighting, autumn atmosphere"),

    ("blue_meanie",
     "Real Panaeolus cyanescens Blue Meanie mushrooms, small to medium specimens with light gray-brown caps "
     "that darken when moist, thin pale stems with distinctive blue-green bruising where handled, "
     "growing from dung substrate in tropical setting, humid natural atmosphere, soft diffused daylight"),

    ("mazatec",
     "Real Psilocybe cubensis Mazatec strain mushrooms, medium golden-brown caps with white stems, "
     "classic cubensis shape, growing in natural cluster, "
     "warm atmospheric lighting suggesting Oaxacan highland forest, rich earth tones, "
     "respectful documentary style photograph"),
]

def generate_one(name, subject_prompt):
    out_path = os.path.join(OUT_DIR, f"{name}.imageset")
    os.makedirs(out_path, exist_ok=True)
    img_file = os.path.join(out_path, f"{name}.png")

    full_prompt = f"{subject_prompt}. {STYLE}"
    resp = requests.post(
        "https://api.ideogram.ai/v1/ideogram-v3/generate",
        headers={"Api-Key": API_KEY},
        files={
            "prompt": (None, full_prompt),
            "rendering_speed": (None, "TURBO"),
            "aspect_ratio": (None, "16x9"),
        },
        timeout=120,
    )
    if not resp.ok:
        print(f"  FAIL {name}: {resp.status_code} {resp.text[:200]}"); return False

    data = resp.json()
    image_url = data.get("data", [{}])[0].get("url")
    if not image_url:
        print(f"  FAIL {name}: no URL"); return False

    img_resp = requests.get(image_url, timeout=60)
    if not img_resp.ok:
        print(f"  FAIL {name}: download failed"); return False

    with open(img_file, "wb") as f:
        f.write(img_resp.content)

    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(out_path, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

    print(f"  OK   {name} ({len(img_resp.content)/1024:.0f} KB)")
    return True

print(f"Regenerating {len(MUSHROOMS)} mushroom strains (photorealistic)...\n")
ok = fail = 0
for i, (name, prompt) in enumerate(MUSHROOMS):
    print(f"[{i+1}/{len(MUSHROOMS)}] {name}")
    if generate_one(name, prompt): ok += 1
    else: fail += 1
    if i < len(MUSHROOMS) - 1: time.sleep(2)
print(f"\nDone: {ok} ok, {fail} failed")
