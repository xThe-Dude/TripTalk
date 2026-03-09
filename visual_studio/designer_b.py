#!/usr/bin/env python3
"""Designer B: Substance Category Headers (4), App Store Screenshot Frames (5) = 9 assets."""

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
# DIRECTION 2: Substance Category Headers (4)
# ═══════════════════════════════════════════
CATEGORIES = [
    ("category_psilocybin",
     "Professional macro photograph of various Psilocybe cubensis mushrooms in different growth stages, "
     "from pins to fully opened caps, arranged naturally on a mossy forest floor, "
     "soft diffused natural light, shallow depth of field, rich earth tones, "
     "scientific documentary quality, DSLR bokeh, warm and inviting"),

    ("category_ayahuasca",
     "Professional nature photograph of Banisteriopsis caapi vine spiraling up a tree trunk "
     "in dense Amazonian rainforest, dappled sunlight filtering through canopy, "
     "lush emerald greens, humid atmosphere visible in the air, "
     "National Geographic documentary quality, deep jungle mood"),

    ("category_mescaline",
     "Professional nature photograph of San Pedro and Peruvian Torch cacti growing together "
     "in an arid Andean landscape at golden hour, warm desert light, "
     "dramatic sky, ancient mountains in background, "
     "National Geographic quality, warm earth tones and desert golds"),

    ("category_ketamine",
     "Clean modern medical therapy room interior, comfortable reclining chair "
     "next to a window with soft natural light, a small side table with a glass of water, "
     "warm neutral tones with subtle teal accent wall, potted plant in corner, "
     "professional interior photography, calming and clinical yet warm"),
]

# ═══════════════════════════════════════════
# DIRECTION 4: App Store Screenshot Frames (5)
# ═══════════════════════════════════════════
APPSTORE = [
    ("appstore_bg_explore",
     "Abstract soft gradient background transitioning from deep forest green to warm teal, "
     "subtle organic shapes like gentle leaves or fern fronds barely visible, "
     "clean and premium, suitable as background behind a phone mockup, "
     "minimal and elegant, soft warm highlights at top"),

    ("appstore_bg_catalog",
     "Abstract soft gradient background from deep earth brown to forest green, "
     "very subtle mushroom cap silhouettes barely visible in the texture, "
     "clean and premium, suitable as background behind a phone mockup, "
     "rich and organic feeling"),

    ("appstore_bg_detail",
     "Abstract soft gradient background from deep teal to warm gold, "
     "gentle bokeh light orbs floating softly, "
     "clean and premium, suitable as background behind a phone mockup, "
     "warm and inviting"),

    ("appstore_bg_safety",
     "Abstract soft gradient background from deep navy blue to warm amber, "
     "subtle gentle light rays from upper corner suggesting safety and guidance, "
     "clean and premium, suitable as background behind a phone mockup"),

    ("appstore_bg_community",
     "Abstract soft gradient background from warm earth tones to gentle green, "
     "very subtle circular shapes suggesting gathering and connection, "
     "clean and premium, suitable as background behind a phone mockup, "
     "warm and communal feeling"),
]

def main():
    all_assets = [
        ("Substance Categories", CATEGORIES, "Categories", "16x9"),
        ("App Store Backgrounds", APPSTORE, "AppStore", "9x16"),
    ]

    total = sum(len(items) for _, items, _, _ in all_assets)
    print(f"Designer B: Generating {total} assets across 2 directions\n")

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

    print(f"\n\nDesigner B complete: {ok} ok, {fail} failed")

if __name__ == "__main__":
    main()
