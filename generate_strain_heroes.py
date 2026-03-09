#!/usr/bin/env python3
"""Generate hero images for all TripTalk strains using Ideogram API."""

import json
import os
import subprocess
import sys
import time
import requests

API_KEY = os.environ.get("IDEOGRAM_API_KEY")
if not API_KEY:
    try:
        API_KEY = subprocess.check_output(
            ["security", "find-generic-password", "-s", "openclaw-ideogram-api-key", "-w"],
            text=True,
        ).strip()
    except Exception:
        API_KEY = None

if not API_KEY:
    print("ERROR: No IDEOGRAM_API_KEY found"); sys.exit(1)

OUT_DIR = os.path.join(os.path.dirname(__file__), "TripTalk", "Assets.xcassets", "StrainHeroes")
os.makedirs(OUT_DIR, exist_ok=True)

# Consistent style prefix for all strains
STYLE = (
    "Premium botanical illustration, dark moody background with subtle bioluminescent glow, "
    "rich jewel tones, detailed scientific illustration style mixed with ethereal psychedelic art, "
    "no text, no words, no letters, no labels, "
    "cinematic lighting, 4K detail, suitable as app hero image, "
    "aspect ratio 16:9, wide format"
)

STRAINS = [
    ("golden_teachers", "A cluster of golden-capped Psilocybe cubensis mushrooms with warm amber glow, delicate gills visible underneath, growing from rich dark substrate, golden light rays filtering through, earthy and mystical atmosphere"),
    ("albino_penis_envy", "Ghostly white albino Psilocybe cubensis mushrooms with thick dense stems and small round caps, deep blue bruising on surfaces, ethereal ice-blue bioluminescent glow, powerful and mysterious presence"),
    ("b_plus", "Friendly warm-toned Psilocybe cubensis mushrooms with caramel-brown caps and sturdy white stems, soft warm lighting, welcoming and approachable, gentle golden bokeh background"),
    ("liberty_caps", "Delicate pointed conical Liberty Cap mushrooms (Psilocybe semilanceata) growing in wild grass, morning dew drops, misty meadow atmosphere, cool green and silver tones, wild and natural"),
    ("blue_meanie", "Vibrant Panaeolus cyanescens mushrooms with intense blue bruising, electric blue bioluminescent veins, energetic composition, vivid cyan and cobalt color palette, dynamic and powerful"),
    ("mazatec", "Sacred ceremonial mushrooms in Oaxacan setting, Psilocybe cubensis surrounded by copal smoke wisps and marigold petals, warm amber and deep purple tones, ancient spiritual atmosphere, reverent and sacred"),
    ("caapi_chacruna", "Intertwined Banisteriopsis caapi vine with heart-shaped Psychotria viridis leaves, Amazonian rainforest atmosphere, deep emerald greens with ayahuasca-vision serpentine patterns in the background, mystical jungle"),
    ("caapi_mimosa", "Banisteriopsis caapi vine spiraling around Mimosa hostilis branch with feathery leaves and pink fluffy flowers, vivid rainbow prismatic light, more colorful and electric than traditional ayahuasca, jungle atmosphere"),
    ("san_pedro", "Tall San Pedro cactus (Echinopsis pachanoi) with white star-shaped flowers, Andean mountain backdrop at golden hour, warm desert light, sacred and ancient feeling, earthy terracotta and gold tones"),
    ("peyote", "Small round Peyote cactus (Lophophora williamsii) with intricate geometric button pattern and delicate pink flower on top, desert sand, sacred Native American ceremonial feeling, turquoise and warm earth tones"),
    ("peruvian_torch", "Tall ribbed Peruvian Torch cactus (Echinopsis peruviana) with electric-blue spines catching light, desert landscape with stars, energetic and electric atmosphere, vibrant teal and orange sunset tones"),
    ("ketamine_iv", "Abstract clinical art: a luminous IV drip with crystalline liquid catching prismatic light, clean modern aesthetic, cool blue and white tones, sterile yet beautiful, medical precision meets transcendence"),
    ("ketamine_troche", "Abstract art: a translucent diamond-shaped lozenge dissolving with gentle waves of warm light emanating outward, soft lavender and warm gold tones, intimate and calm, home therapeutic setting suggested by warm ambient light"),
    ("ketamine_spravato", "Abstract art: fine crystalline mist spray dispersing into prismatic light particles, clean clinical white space with subtle blue accents, modern pharmaceutical meets ethereal, precise and controlled"),
    ("ketamine_im", "Abstract art: a single luminous point radiating concentric waves of deep indigo and silver light, clinical precision, powerful and concentrated energy, deep space feeling with medical undertones"),
]

def generate_one(name, subject_prompt):
    """Generate a single strain hero image."""
    out_path = os.path.join(OUT_DIR, f"{name}.imageset")
    os.makedirs(out_path, exist_ok=True)
    
    img_file = os.path.join(out_path, f"{name}.png")
    if os.path.exists(img_file):
        print(f"  SKIP {name} (already exists)")
        return True
    
    full_prompt = f"{subject_prompt}. {STYLE}"
    
    url = "https://api.ideogram.ai/v1/ideogram-v3/generate"
    resp = requests.post(
        url,
        headers={"Api-Key": API_KEY},
        files={
            "prompt": (None, full_prompt),
            "rendering_speed": (None, "TURBO"),
            "aspect_ratio": (None, "16x9"),
        },
        timeout=120,
    )
    
    if not resp.ok:
        print(f"  FAIL {name}: {resp.status_code} {resp.text[:200]}")
        return False
    
    data = resp.json()
    image_url = data.get("data", [{}])[0].get("url")
    if not image_url:
        print(f"  FAIL {name}: no URL in response")
        print(f"  Response keys: {list(data.keys())}")
        if "data" in data and data["data"]:
            print(f"  Data[0] keys: {list(data['data'][0].keys())}")
        return False
    
    # Download image
    img_resp = requests.get(image_url, timeout=60)
    if not img_resp.ok:
        print(f"  FAIL {name}: download failed {img_resp.status_code}")
        return False
    
    with open(img_file, "wb") as f:
        f.write(img_resp.content)
    
    # Write Contents.json for Xcode asset catalog
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}],
        "info": {"author": "xcode", "version": 1}
    }
    with open(os.path.join(out_path, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    
    size_kb = len(img_resp.content) / 1024
    print(f"  OK   {name} ({size_kb:.0f} KB)")
    return True


def main():
    # Start from a specific index if provided
    start = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    
    print(f"Generating {len(STRAINS)} strain hero images...")
    print(f"Output: {OUT_DIR}\n")
    
    ok = 0
    fail = 0
    for i, (name, prompt) in enumerate(STRAINS):
        if i < start:
            continue
        print(f"[{i+1}/{len(STRAINS)}] {name}")
        if generate_one(name, prompt):
            ok += 1
        else:
            fail += 1
        # Rate limit
        if i < len(STRAINS) - 1:
            time.sleep(2)
    
    print(f"\nDone: {ok} ok, {fail} failed")


if __name__ == "__main__":
    main()
