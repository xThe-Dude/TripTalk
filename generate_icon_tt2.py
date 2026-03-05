#!/usr/bin/env python3
"""TripTalk icon — Interlocking TT, artistic gradient background"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math, os, numpy as np

RENDER_SIZE = 2048  # Supersample at 2x then downscale for crisp anti-aliasing
SIZE = RENDER_SIZE


def make_icon():
    y_coords, x_coords = np.mgrid[0:SIZE, 0:SIZE]

    # --- Artistic multi-layer gradient ---
    # Base: rich emerald→deep blue diagonal
    t = (x_coords * 0.5 + y_coords * 0.5) / SIZE
    t = np.clip(t, 0, 1)
    t_smooth = t * t * (3 - 2 * t)

    stops = [
        (0.00, np.array([2, 120, 80])),      # deep emerald
        (0.25, np.array([8, 145, 120])),      # rich teal
        (0.50, np.array([15, 130, 170])),     # ocean blue-teal
        (0.75, np.array([30, 80, 200])),      # deep blue
        (1.00, np.array([25, 55, 160])),      # indigo-blue
    ]

    r = np.zeros((SIZE, SIZE), dtype=np.float64)
    g = np.zeros((SIZE, SIZE), dtype=np.float64)
    b = np.zeros((SIZE, SIZE), dtype=np.float64)

    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        mask = (t_smooth >= t0) & (t_smooth <= t1)
        lt = np.where(mask, (t_smooth - t0) / (t1 - t0), 0)
        lt = lt * lt * (3 - 2 * lt)
        r += mask * (c0[0] + (c1[0] - c0[0]) * lt)
        g += mask * (c0[1] + (c1[1] - c0[1]) * lt)
        b += mask * (c0[2] + (c1[2] - c0[2]) * lt)

    # Aurora-like wave overlay (sinusoidal color shift)
    wave1 = np.sin(y_coords * 2 * np.pi / SIZE * 3.0 + x_coords * 0.003) * 0.5 + 0.5
    wave2 = np.sin(x_coords * 2 * np.pi / SIZE * 2.5 + y_coords * 0.004 + 1.5) * 0.5 + 0.5
    aurora = wave1 * wave2
    # Add warm teal-green aurora band
    r += aurora * 12
    g += aurora * 35
    b += aurora * 20

    # Organic noise texture (subtle)
    np.random.seed(42)
    noise = np.random.randn(SIZE // 8, SIZE // 8) * 6
    noise_img = Image.fromarray(noise.astype(np.float32), mode='F')
    noise_img = noise_img.resize((SIZE, SIZE), Image.BILINEAR)
    noise_arr = np.array(noise_img)
    r += noise_arr
    g += noise_arr * 0.8
    b += noise_arr * 0.6

    # Multiple radial glows for depth
    # Main center glow (warm white)
    cx, cy = SIZE * 0.50, SIZE * 0.45
    dist = np.sqrt((x_coords - cx)**2 + (y_coords - cy)**2)
    glow = np.clip(1.0 - (dist / (SIZE * 0.40))**1.5, 0, 1) * 0.35
    r += (240 - r) * glow
    g += (255 - g) * glow
    b += (250 - b) * glow

    # Secondary glow top-left (green-teal accent)
    cx2, cy2 = SIZE * 0.15, SIZE * 0.15
    dist2 = np.sqrt((x_coords - cx2)**2 + (y_coords - cy2)**2)
    glow2 = np.clip(1.0 - (dist2 / (SIZE * 0.45))**2, 0, 1) * 0.15
    g += (200 - g) * glow2
    b += (180 - b) * glow2

    # Tertiary glow bottom-right (blue accent)
    cx3, cy3 = SIZE * 0.85, SIZE * 0.85
    dist3 = np.sqrt((x_coords - cx3)**2 + (y_coords - cy3)**2)
    glow3 = np.clip(1.0 - (dist3 / (SIZE * 0.40))**2, 0, 1) * 0.12
    b += (220 - b) * glow3

    # Soft vignette (darken edges)
    cx_v, cy_v = SIZE * 0.5, SIZE * 0.5
    dist_v = np.sqrt((x_coords - cx_v)**2 + (y_coords - cy_v)**2)
    vignette = np.clip(dist_v / (SIZE * 0.7) - 0.3, 0, 1) ** 1.5 * 0.35
    r *= (1 - vignette)
    g *= (1 - vignette)
    b *= (1 - vignette)

    pixels = np.stack([
        np.clip(r, 0, 255).astype(np.uint8),
        np.clip(g, 0, 255).astype(np.uint8),
        np.clip(b, 0, 255).astype(np.uint8),
        np.full((SIZE, SIZE), 255, dtype=np.uint8)
    ], axis=-1)

    img = Image.fromarray(pixels, 'RGBA')

    # --- Botanical leaves (more organic, scattered) ---
    leaf_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ld = ImageDraw.Draw(leaf_layer)

    def draw_leaf(draw, cx, cy, size, angle, opacity):
        """Draw a realistic leaf with pointed tip, curved edges, midrib and branching veins."""
        cos_a, sin_a = math.cos(angle), math.sin(angle)

        def rot(lx, ly):
            return (lx * cos_a - ly * sin_a + cx, lx * sin_a + ly * cos_a + cy)

        # Leaf outline: asymmetric, pointed tip, rounded base
        # Using cubic bezier-approximated shape
        length = size * 2.2
        width = size * 0.55
        n_pts = 120
        outline = []
        for i in range(n_pts):
            t_param = i / (n_pts - 1)  # 0→1 along leaf length
            # Y position along leaf (tip to base)
            ly = (t_param - 0.5) * length
            # Width profile: widest at ~35% from base, tapers to sharp tip
            # Use a combo of sine and power curve
            if t_param < 0.08:
                # Sharp tip
                w = width * (t_param / 0.08) ** 1.5
            elif t_param > 0.92:
                # Rounded base (slightly narrower)
                w = width * ((1.0 - t_param) / 0.08) ** 0.8 * 0.7
            else:
                # Main body — asymmetric bell
                norm_t = (t_param - 0.08) / 0.84
                w = width * math.sin(norm_t * math.pi) ** 0.6
                # Slight asymmetry
                w *= (1.0 + 0.08 * math.sin(norm_t * math.pi * 3))

            outline.append(rot(w, ly))

        # Return path (other side, mirrored with slight variation)
        for i in range(n_pts - 1, -1, -1):
            t_param = i / (n_pts - 1)
            ly = (t_param - 0.5) * length
            if t_param < 0.08:
                w = width * (t_param / 0.08) ** 1.5
            elif t_param > 0.92:
                w = width * ((1.0 - t_param) / 0.08) ** 0.8 * 0.7
            else:
                norm_t = (t_param - 0.08) / 0.84
                w = width * math.sin(norm_t * math.pi) ** 0.6
                w *= (1.0 - 0.06 * math.sin(norm_t * math.pi * 3))
            outline.append(rot(-w, ly))

        # Fill leaf body
        fill_opacity = min(255, int(opacity * 0.85))
        draw.polygon(outline, fill=(255, 255, 255, fill_opacity))

        # Midrib (central vein) — slightly brighter
        vein_opacity = min(255, int(opacity * 1.2))
        tip = rot(0, -length * 0.5)
        base = rot(0, length * 0.48)
        draw.line([tip, base], fill=(255, 255, 255, vein_opacity), width=max(2, size // 40))

        # Branching veins — 5-7 pairs angling out from midrib
        n_veins = 6
        for v in range(n_veins):
            vt = 0.15 + v * 0.70 / (n_veins - 1)  # position along midrib (0.15→0.85)
            ly_v = (vt - 0.5) * length
            # Vein origin on midrib
            origin = rot(0, ly_v)

            # Width at this point
            if vt < 0.08:
                w_here = width * (vt / 0.08) ** 1.5
            elif vt > 0.92:
                w_here = width * ((1.0 - vt) / 0.08) ** 0.8 * 0.7
            else:
                norm_t = (vt - 0.08) / 0.84
                w_here = width * math.sin(norm_t * math.pi) ** 0.6

            # Veins angle toward tip (upward)
            vein_angle_offset = 0.35 + 0.2 * vt  # steeper near tip
            vein_len = w_here * 0.85
            v_opacity = min(255, int(opacity * 0.6))

            # Right vein
            end_r = rot(vein_len, ly_v - vein_len * vein_angle_offset)
            draw.line([origin, end_r], fill=(255, 255, 255, v_opacity), width=max(1, size // 60))

            # Left vein
            end_l = rot(-vein_len, ly_v - vein_len * vein_angle_offset)
            draw.line([origin, end_l], fill=(255, 255, 255, v_opacity), width=max(1, size // 60))

    # Bottom-left cluster (reduced opacity — whisper, not shout)
    draw_leaf(ld, 130, 810, 130, math.radians(-25), 95)
    draw_leaf(ld, 60, 740, 110, math.radians(-50), 80)
    draw_leaf(ld, 200, 880, 100, math.radians(-5), 72)
    draw_leaf(ld, 25, 840, 90, math.radians(-65), 64)
    draw_leaf(ld, 230, 780, 75, math.radians(-40), 56)
    draw_leaf(ld, 80, 900, 85, math.radians(-75), 52)
    draw_leaf(ld, 170, 740, 60, math.radians(-15), 44)

    # Top-right cluster
    draw_leaf(ld, 890, 210, 130, math.radians(155), 95)
    draw_leaf(ld, 955, 260, 110, math.radians(130), 80)
    draw_leaf(ld, 825, 140, 100, math.radians(175), 72)
    draw_leaf(ld, 810, 240, 75, math.radians(145), 56)
    draw_leaf(ld, 940, 150, 85, math.radians(165), 60)
    draw_leaf(ld, 860, 290, 60, math.radians(135), 44)

    # Sparse accent leaves
    draw_leaf(ld, 50, 500, 50, math.radians(-80), 28)
    draw_leaf(ld, 970, 520, 50, math.radians(100), 28)

    leaf_layer = leaf_layer.filter(ImageFilter.GaussianBlur(radius=3))
    img = Image.alpha_composite(img, leaf_layer)

    # --- Interlocking TT (luxury treatment) ---
    font = None
    font_size = 520
    for fp in [
        "/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf",
        "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
    ]:
        if os.path.exists(fp):
            try:
                font = ImageFont.truetype(fp, font_size)
                print(f"Using font: {fp}")
                break
            except:
                continue

    temp_draw = ImageDraw.Draw(Image.new("RGBA", (SIZE, SIZE)))
    bbox = temp_draw.textbbox((0, 0), "T", font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    center_x = SIZE // 2
    center_y = SIZE // 2

    # Positions: no rotation, clean interlock
    tx1 = center_x - tw // 2 - 65 - bbox[0]
    ty1 = center_y - th // 2 - bbox[1] + 15
    tx2 = center_x - tw // 2 + 115 - bbox[0]
    ty2 = ty1

    # --- Layer 1: Wide ambient shadow (floating effect) ---
    ambient_shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    asd = ImageDraw.Draw(ambient_shadow)
    asd.text((tx1 + 2, ty1 + 10), "T", font=font, fill=(0, 15, 30, 35))
    asd.text((tx2 + 2, ty2 + 10), "T", font=font, fill=(0, 15, 30, 35))
    ambient_shadow = ambient_shadow.filter(ImageFilter.GaussianBlur(radius=30))
    img = Image.alpha_composite(img, ambient_shadow)

    # --- Layer 2: Tight contact shadow (definition) ---
    tight_shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    tsd = ImageDraw.Draw(tight_shadow)
    tsd.text((tx1 + 3, ty1 + 4), "T", font=font, fill=(0, 20, 40, 55))
    tsd.text((tx2 + 3, ty2 + 4), "T", font=font, fill=(0, 20, 40, 55))
    tight_shadow = tight_shadow.filter(ImageFilter.GaussianBlur(radius=8))
    img = Image.alpha_composite(img, tight_shadow)

    # --- Layer 3: Luminous glow ---
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    gd.text((tx1, ty1), "T", font=font, fill=(255, 255, 255, 50))
    gd.text((tx2, ty2), "T", font=font, fill=(255, 255, 255, 50))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=25))
    img = Image.alpha_composite(img, glow_layer)

    # --- Layer 4: Light hairline stroke (luxury thin outline) ---
    def render_light_stroke(img_base, tx, ty, font, stroke_w=3, stroke_color=(200, 230, 240, 70)):
        """Thin luminous outline — luxury hairline effect."""
        stroke_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        sd = ImageDraw.Draw(stroke_layer)
        for dx in range(-stroke_w, stroke_w + 1):
            for dy in range(-stroke_w, stroke_w + 1):
                dist_sq = dx * dx + dy * dy
                if dist_sq <= stroke_w * stroke_w and dist_sq > (stroke_w - 2) * (stroke_w - 2):
                    # Only the outer ring of the stroke — creates a thin line, not a fat blob
                    sd.text((tx + dx, ty + dy), "T", font=font, fill=stroke_color)
        return Image.alpha_composite(img_base, stroke_layer)

    # --- Layer 5: Back T (frosted glass effect) ---
    # Stroke
    img = render_light_stroke(img, tx2, ty2, font, stroke_w=4, stroke_color=(180, 220, 240, 65))

    # Frosted fill: semi-transparent white with a subtle cool gradient
    back_t_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    btd = ImageDraw.Draw(back_t_layer)
    btd.text((tx2, ty2), "T", font=font, fill=(220, 235, 255, 170))

    # Gold/champagne highlight on top edge of back T
    back_highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bhd = ImageDraw.Draw(back_highlight)
    bhd.text((tx2, ty2 - 2), "T", font=font, fill=(255, 245, 210, 40))
    back_highlight = back_highlight.filter(ImageFilter.GaussianBlur(radius=6))
    # Mask to only show highlight on top third
    highlight_mask = Image.new("L", (SIZE, SIZE), 0)
    hmd = ImageDraw.Draw(highlight_mask)
    crossbar_bottom = ty1 + int(th * 0.28)
    hmd.rectangle([0, 0, SIZE, crossbar_bottom], fill=255)
    # Feather the mask
    highlight_mask = highlight_mask.filter(ImageFilter.GaussianBlur(radius=20))
    back_highlight.putalpha(Image.composite(
        back_highlight.split()[3], Image.new("L", (SIZE, SIZE), 0), highlight_mask
    ))

    img = Image.alpha_composite(img, back_t_layer)
    img = Image.alpha_composite(img, back_highlight)

    # --- Layer 6: Front T (frosted glass + gold highlight) ---
    # Stroke
    img = render_light_stroke(img, tx1, ty1, font, stroke_w=4, stroke_color=(190, 230, 235, 75))

    # Frosted fill: warmer white, slightly more opaque than back T
    front_t_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ftd = ImageDraw.Draw(front_t_layer)
    ftd.text((tx1, ty1), "T", font=font, fill=(250, 250, 248, 235))

    # Gold/champagne highlight on top edge of front T (stronger)
    front_highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fhd = ImageDraw.Draw(front_highlight)
    fhd.text((tx1, ty1 - 2), "T", font=font, fill=(255, 240, 195, 55))
    front_highlight = front_highlight.filter(ImageFilter.GaussianBlur(radius=5))
    front_highlight.putalpha(Image.composite(
        front_highlight.split()[3], Image.new("L", (SIZE, SIZE), 0), highlight_mask
    ))

    img = Image.alpha_composite(img, front_t_layer)
    img = Image.alpha_composite(img, front_highlight)

    # --- Layer 6b: Champagne/gold thin outline on both T's ---
    def render_champagne_outline(img_base, tx, ty, font, width=3):
        """Thin warm champagne outline — only the outermost edge ring."""
        outline = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        od = ImageDraw.Draw(outline)
        # Outer fill
        for dx in range(-width, width + 1):
            for dy in range(-width, width + 1):
                dist_sq = dx * dx + dy * dy
                if dist_sq <= width * width:
                    od.text((tx + dx, ty + dy), "T", font=font, fill=(225, 200, 150, 90))
        # Knock out interior by compositing the T shape as eraser
        knockout = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        kd = ImageDraw.Draw(knockout)
        kd.text((tx, ty), "T", font=font, fill=(255, 255, 255, 255))
        # Where knockout is opaque, make outline transparent
        outline_arr = np.array(outline).astype(np.float32)
        knock_arr = np.array(knockout).astype(np.float32)
        # Reduce outline alpha where knockout exists
        mask = knock_arr[:, :, 3] / 255.0
        outline_arr[:, :, 3] *= (1.0 - mask * 0.85)  # keep thin edge visible
        result = Image.fromarray(outline_arr.astype(np.uint8), "RGBA")
        return Image.alpha_composite(img_base, result)

    img = render_champagne_outline(img, tx2, ty2, font, width=3)
    img = render_champagne_outline(img, tx1, ty1, font, width=3)

    # --- Layer 7: Restrained luminous orbs (fewer, intentional) ---
    particle_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    pd_draw = ImageDraw.Draw(particle_layer)
    rng = np.random.default_rng(seed=77)

    # Only soft orbs — no dust (luxury = restraint)
    placed = 0
    attempts = 0
    while placed < 10 and attempts < 80:
        attempts += 1
        px = int(rng.uniform(60, SIZE - 60))
        py = int(rng.uniform(60, SIZE - 60))
        dist_center = math.sqrt((px - center_x)**2 + (py - center_y)**2)
        if dist_center < SIZE * 0.25:
            continue
        pr = rng.uniform(5, 12)
        p_opacity = int(rng.uniform(35, 85))
        pd_draw.ellipse(
            [px - pr, py - pr, px + pr, py + pr],
            fill=(255, 255, 255, p_opacity)
        )
        placed += 1

    # Soft glow halo on orbs
    orb_glow = particle_layer.copy()
    orb_glow = orb_glow.filter(ImageFilter.GaussianBlur(radius=10))
    particle_layer = particle_layer.filter(ImageFilter.GaussianBlur(radius=3))
    img = Image.alpha_composite(img, orb_glow)
    img = Image.alpha_composite(img, particle_layer)

    return img


def save_icon_set(img):
    base = "/Users/coleoehlrich/openclaw-home/workspace/TripTalk/TripTalk/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(base, exist_ok=True)
    # Downscale from RENDER_SIZE to target sizes with LANCZOS for max quality
    # iOS App Store requires 1024x1024; other sizes for legacy/compatibility
    for s in [1024, 180, 167, 152, 120, 87, 80, 76, 60, 58, 40, 29, 20]:
        resized = img.resize((s, s), Image.LANCZOS)
        resized.save(os.path.join(base, f"icon_{s}x{s}.png"), optimize=True)
        print(f"  icon_{s}x{s}.png ✓")
    with open(os.path.join(base, "Contents.json"), "w") as f:
        f.write("""{
  "images" : [
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}""")


if __name__ == "__main__":
    print("Generating TripTalk interlocking TT icon...")
    icon = make_icon()
    print("Saving...")
    save_icon_set(icon)
    print("Done ✅")
