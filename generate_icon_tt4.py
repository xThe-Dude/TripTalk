#!/usr/bin/env python3
"""TripTalk icon v4 — iOS squircle shape, massive TT, strong emboss"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops
import math, os, numpy as np

RENDER_SIZE = 2048
SIZE = RENDER_SIZE
# iOS icon corner radius is ~22.37% of icon width
CORNER_RATIO = 0.2237


def draw_squircle_mask(size, corner_radius):
    """Create an iOS-style superellipse (squircle) mask."""
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    # Use rounded_rectangle as approximation — PIL supports it
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=corner_radius, fill=255)
    return mask


def make_icon():
    y_coords, x_coords = np.mgrid[0:SIZE, 0:SIZE]
    corner_r = int(SIZE * CORNER_RATIO)

    # --- Background gradient ---
    t = (x_coords * 0.45 + y_coords * 0.55) / SIZE
    t = np.clip(t, 0, 1)
    t_s = t * t * (3 - 2 * t)

    stops = [
        (0.00, np.array([5, 110, 78])),
        (0.30, np.array([10, 130, 115])),
        (0.55, np.array([12, 105, 150])),
        (0.80, np.array([22, 65, 175])),
        (1.00, np.array([18, 42, 130])),
    ]

    r = np.zeros((SIZE, SIZE), dtype=np.float64)
    g = np.zeros((SIZE, SIZE), dtype=np.float64)
    b = np.zeros((SIZE, SIZE), dtype=np.float64)

    for i in range(len(stops) - 1):
        t0, c0 = stops[i]
        t1, c1 = stops[i + 1]
        mask = (t_s >= t0) & (t_s <= t1)
        lt = np.where(mask, (t_s - t0) / (t1 - t0), 0)
        lt = lt * lt * (3 - 2 * lt)
        r += mask * (c0[0] + (c1[0] - c0[0]) * lt)
        g += mask * (c0[1] + (c1[1] - c0[1]) * lt)
        b += mask * (c0[2] + (c1[2] - c0[2]) * lt)

    # Center glow
    cx, cy = SIZE * 0.48, SIZE * 0.44
    dist = np.sqrt((x_coords - cx)**2 + (y_coords - cy)**2)
    glow = np.clip(1.0 - (dist / (SIZE * 0.42))**1.4, 0, 1) * 0.25
    r += (160 - r) * glow
    g += (200 - g) * glow
    b += (195 - b) * glow

    # Vignette (stronger)
    dist_v = np.sqrt((x_coords - SIZE/2)**2 + (y_coords - SIZE/2)**2)
    vignette = np.clip(dist_v / (SIZE * 0.6) - 0.15, 0, 1) ** 1.5 * 0.5
    r *= (1 - vignette)
    g *= (1 - vignette)
    b *= (1 - vignette)

    # Fine grain texture
    rng = np.random.default_rng(42)
    noise = rng.normal(0, 4.0, (SIZE, SIZE))
    r += noise
    g += noise * 0.9
    b += noise * 0.8

    pixels = np.stack([
        np.clip(r, 0, 255).astype(np.uint8),
        np.clip(g, 0, 255).astype(np.uint8),
        np.clip(b, 0, 255).astype(np.uint8),
        np.full((SIZE, SIZE), 255, dtype=np.uint8)
    ], axis=-1)
    img = Image.fromarray(pixels, 'RGBA')

    # --- Squircle shape with edge shading ---
    squircle = draw_squircle_mask(SIZE, corner_r)

    # Edge highlight (top-left inner edge of squircle)
    sq_shifted_br = Image.new("L", (SIZE, SIZE), 0)
    d_br = ImageDraw.Draw(sq_shifted_br)
    d_br.rounded_rectangle([4, 4, SIZE - 1 + 4, SIZE - 1 + 4], radius=corner_r, fill=255)
    edge_hl_sq = ImageChops.subtract(squircle, sq_shifted_br)
    edge_hl_sq = edge_hl_sq.filter(ImageFilter.GaussianBlur(radius=6))

    # Edge shadow (bottom-right inner edge of squircle)
    sq_shifted_tl = Image.new("L", (SIZE, SIZE), 0)
    d_tl = ImageDraw.Draw(sq_shifted_tl)
    d_tl.rounded_rectangle([-4, -4, SIZE - 1 - 4, SIZE - 1 - 4], radius=corner_r, fill=255)
    edge_sh_sq = ImageChops.subtract(squircle, sq_shifted_tl)
    edge_sh_sq = edge_sh_sq.filter(ImageFilter.GaussianBlur(radius=6))

    # Apply squircle edge highlights
    ehl = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ehl_arr = np.array(ehl)
    ehl_data = np.array(edge_hl_sq).astype(np.float64)
    ehl_arr[:, :, 0] = 255
    ehl_arr[:, :, 1] = 255
    ehl_arr[:, :, 2] = 250
    ehl_arr[:, :, 3] = np.clip(ehl_data * 0.5, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(ehl_arr, "RGBA"))

    # Apply squircle edge shadow
    esh = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    esh_arr = np.array(esh)
    esh_data = np.array(edge_sh_sq).astype(np.float64)
    esh_arr[:, :, 3] = np.clip(esh_data * 0.4, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(esh_arr, "RGBA"))

    # --- Subtle botanical leaves ---
    leaf_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ld_draw = ImageDraw.Draw(leaf_layer)

    def draw_leaf(draw, cx, cy, size, angle, opacity):
        cos_a, sin_a = math.cos(angle), math.sin(angle)
        def rot(lx, ly):
            return (lx * cos_a - ly * sin_a + cx, lx * sin_a + ly * cos_a + cy)
        length, width = size * 2.2, size * 0.55
        outline = []
        for i in range(100):
            tp = i / 99
            ly = (tp - 0.5) * length
            if tp < 0.08: w = width * (tp / 0.08) ** 1.5
            elif tp > 0.92: w = width * ((1 - tp) / 0.08) ** 0.8 * 0.7
            else:
                nt = (tp - 0.08) / 0.84
                w = width * math.sin(nt * math.pi) ** 0.6 * (1 + 0.08 * math.sin(nt * math.pi * 3))
            outline.append(rot(w, ly))
        for i in range(99, -1, -1):
            tp = i / 99
            ly = (tp - 0.5) * length
            if tp < 0.08: w = width * (tp / 0.08) ** 1.5
            elif tp > 0.92: w = width * ((1 - tp) / 0.08) ** 0.8 * 0.7
            else:
                nt = (tp - 0.08) / 0.84
                w = width * math.sin(nt * math.pi) ** 0.6 * (1 - 0.06 * math.sin(nt * math.pi * 3))
            outline.append(rot(-w, ly))
        draw.polygon(outline, fill=(255, 255, 255, int(opacity * 0.8)))
        tip, base = rot(0, -length * 0.5), rot(0, length * 0.48)
        draw.line([tip, base], fill=(255, 255, 255, int(opacity)), width=max(2, size // 35))
        for v in range(6):
            vt = 0.15 + v * 0.12
            ly_v = (vt - 0.5) * length
            origin = rot(0, ly_v)
            if vt < 0.08: wh = width * (vt / 0.08) ** 1.5
            elif vt > 0.92: wh = width * ((1 - vt) / 0.08) ** 0.8 * 0.7
            else: wh = width * math.sin(((vt - 0.08) / 0.84) * math.pi) ** 0.6
            vl = wh * 0.85
            vo = int(opacity * 0.45)
            vao = 0.35 + 0.2 * vt
            draw.line([origin, rot(vl, ly_v - vl * vao)], fill=(255, 255, 255, vo), width=max(1, size // 55))
            draw.line([origin, rot(-vl, ly_v - vl * vao)], fill=(255, 255, 255, vo), width=max(1, size // 55))

    draw_leaf(ld_draw, 160, 1700, 140, math.radians(-25), 65)
    draw_leaf(ld_draw, 70, 1600, 115, math.radians(-50), 50)
    draw_leaf(ld_draw, 260, 1800, 105, math.radians(-8), 45)
    draw_leaf(ld_draw, 1850, 350, 140, math.radians(155), 65)
    draw_leaf(ld_draw, 1920, 440, 115, math.radians(130), 50)
    draw_leaf(ld_draw, 1750, 270, 105, math.radians(172), 45)

    leaf_layer = leaf_layer.filter(ImageFilter.GaussianBlur(radius=4))
    img = Image.alpha_composite(img, leaf_layer)

    # === MASSIVE EMBOSSED TT ===
    font = None
    font_size = 1150  # HUGE — fills the icon
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

    # Tight interlock — nearly overlapping
    tx1 = center_x - tw // 2 - 95 - bbox[0]
    ty1 = center_y - th // 2 - bbox[1] + 30
    tx2 = center_x - tw // 2 + 195 - bbox[0]
    ty2 = ty1

    def render_t_mask(tx, ty):
        m = Image.new("L", (SIZE, SIZE), 0)
        ImageDraw.Draw(m).text((tx, ty), "T", font=font, fill=255)
        return m

    mask1 = render_t_mask(tx1, ty1)
    mask2 = render_t_mask(tx2, ty2)
    combined = ImageChops.lighter(mask1, mask2)
    combined_arr = np.array(combined).astype(np.float64) / 255.0

    # --- STRONG emboss ---
    LIGHT_DX, LIGHT_DY = -8, -8   # light from top-left
    SHADOW_DX, SHADOW_DY = 10, 10  # shadow bottom-right

    # Highlight edge (shifted opposite to light)
    hl_mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(hl_mask).text((tx1 + LIGHT_DX, ty1 + LIGHT_DY), "T", font=font, fill=255)
    ImageDraw.Draw(hl_mask).text((tx2 + LIGHT_DX, ty2 + LIGHT_DY), "T", font=font, fill=255)
    edge_hl = ImageChops.subtract(hl_mask, combined)
    edge_hl = edge_hl.filter(ImageFilter.GaussianBlur(radius=5))

    # Shadow edge
    sh_mask = Image.new("L", (SIZE, SIZE), 0)
    ImageDraw.Draw(sh_mask).text((tx1 + SHADOW_DX, ty1 + SHADOW_DY), "T", font=font, fill=255)
    ImageDraw.Draw(sh_mask).text((tx2 + SHADOW_DX, ty2 + SHADOW_DY), "T", font=font, fill=255)
    edge_sh = ImageChops.subtract(sh_mask, combined)
    edge_sh = edge_sh.filter(ImageFilter.GaussianBlur(radius=6))

    # Inner highlight (top-left inside letter)
    inner_hl = ImageChops.subtract(combined, hl_mask)
    inner_hl = inner_hl.filter(ImageFilter.GaussianBlur(radius=8))

    # Inner shadow (bottom-right inside letter)
    inner_sh = ImageChops.subtract(combined, sh_mask)
    inner_sh = inner_sh.filter(ImageFilter.GaussianBlur(radius=10))

    # 1) Heavy drop shadow
    drop = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    dd = ImageDraw.Draw(drop)
    dd.text((tx1 + 12, ty1 + 14), "T", font=font, fill=(0, 10, 20, 100))
    dd.text((tx2 + 12, ty2 + 14), "T", font=font, fill=(0, 10, 20, 100))
    drop = drop.filter(ImageFilter.GaussianBlur(radius=25))
    img = Image.alpha_composite(img, drop)

    # 2) Outer highlight (STRONG)
    ohl = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ohl_arr = np.array(ohl)
    ehl_d = np.array(edge_hl).astype(np.float64)
    ohl_arr[:, :, 0] = np.clip(ehl_d * 1.0, 0, 255).astype(np.uint8)
    ohl_arr[:, :, 1] = np.clip(ehl_d * 1.0, 0, 255).astype(np.uint8)
    ohl_arr[:, :, 2] = np.clip(ehl_d * 0.95, 0, 255).astype(np.uint8)
    ohl_arr[:, :, 3] = np.clip(ehl_d * 0.85, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(ohl_arr, "RGBA"))

    # 3) Outer shadow (STRONG)
    osh = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    osh_arr = np.array(osh)
    esh_d = np.array(edge_sh).astype(np.float64)
    osh_arr[:, :, 3] = np.clip(esh_d * 0.7, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(osh_arr, "RGBA"))

    # 4) Letter fill — gradient, semi-opaque
    y_grad = 1.0 - (y_coords / SIZE) * 0.35
    fill_r = np.clip(combined_arr * (190 + 60 * y_grad), 0, 255)
    fill_g = np.clip(combined_arr * (205 + 50 * y_grad), 0, 255)
    fill_b = np.clip(combined_arr * (218 + 37 * y_grad), 0, 255)
    fill_a = np.clip(combined_arr * 210, 0, 255)
    fill_pixels = np.stack([fill_r, fill_g, fill_b, fill_a], axis=-1).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(fill_pixels, "RGBA"))

    # 5) Inner highlight (STRONG — raised surface)
    ihl = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ihl_arr = np.array(ihl)
    ihl_d = np.array(inner_hl).astype(np.float64)
    ihl_arr[:, :, 0] = 255
    ihl_arr[:, :, 1] = 255
    ihl_arr[:, :, 2] = 248
    ihl_arr[:, :, 3] = np.clip(ihl_d * combined_arr * 0.55, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(ihl_arr, "RGBA"))

    # 6) Inner shadow (STRONG — carved depth)
    ish = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ish_arr = np.array(ish)
    ish_d = np.array(inner_sh).astype(np.float64)
    ish_arr[:, :, 0] = 0
    ish_arr[:, :, 1] = 8
    ish_arr[:, :, 2] = 15
    ish_arr[:, :, 3] = np.clip(ish_d * combined_arr * 0.50, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(ish_arr, "RGBA"))

    # 7) Champagne top-edge accent
    ch = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ch_arr = np.array(ch)
    ch_arr[:, :, 0] = 255
    ch_arr[:, :, 1] = 230
    ch_arr[:, :, 2] = 180
    ch_arr[:, :, 3] = np.clip(np.array(edge_hl).astype(np.float64) * 0.4, 0, 255).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(ch_arr, "RGBA"))

    # --- Apply squircle mask (clip to iOS shape) ---
    squircle = draw_squircle_mask(SIZE, corner_r)
    # Create final with transparent outside
    final = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    final.paste(img, mask=squircle)

    return final


def save_icon_set(img):
    base = "/Users/coleoehlrich/openclaw-home/workspace/TripTalk/TripTalk/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(base, exist_ok=True)
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
    print("Generating TripTalk embossed TT icon v4...")
    icon = make_icon()
    print("Saving...")
    save_icon_set(icon)
    print("Done ✅")
