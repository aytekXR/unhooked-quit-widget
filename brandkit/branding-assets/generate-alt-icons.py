#!/usr/bin/env python3
# Session 22 E6.3 — generates the two DRAFT discreet alternates per
# frontend-brandkit §4.3 + the Brand panel's 1024 spec; operator-vetoable.
"""Stdlib-only (zlib + struct + math) generator for the two discreet alternate
app icons. Renders BOTH as 1024x1024 OPAQUE RGB (PNG colortype 2, NO alpha),
deterministically, and writes byte-identical copies into the asset catalog and
into brandkit/branding-assets/icons/ (asset provenance beside the primary set).

CALENDAR (AppIconCalendar): vertical gradient #FBFAF8 -> #ECEAE5, a 4x4 dot grid
(centers at {224,416,608,800}, radius 53.5), 15 dots #C9CDD3 + today-dot at
(608,416) in #3D6C9E, analytic anti-aliased circles.

TIMER (AppIconTimer): solid #23262B field, a centered ring (centerline dia 619px:
outer r 323, inner r 296, ~27px stroke) in #8A9097, plus one 27x128px index mark
in #C9CDD3 at the ring top. Both edges anti-aliased.

Pattern proven in the burn-lab png_encoder.py critic spike."""
import zlib, struct, math, os, time


# ---- PNG encode / verify (stdlib only) --------------------------------------

def png_chunk(tag, data):
    c = tag + data
    return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xffffffff)


def encode_png(rows, w, h):
    # rows: list of h bytearrays, each w*3 bytes (RGB 8-bit). Filter 0 per scanline.
    raw = bytearray()
    for row in rows:
        raw.append(0)
        raw.extend(row)
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)  # 8-bit, colortype 2 (RGB), no alpha
    out = b"\x89PNG\r\n\x1a\n"
    out += png_chunk(b"IHDR", ihdr)
    out += png_chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    out += png_chunk(b"IEND", b"")
    return out


def verify(data):
    # Re-read every chunk, recompute CRC, confirm structure from stdlib alone.
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "bad signature"
    off, chunks = 8, []
    while off < len(data):
        length = struct.unpack(">I", data[off:off + 4])[0]
        tag = data[off + 4:off + 8]
        body = data[off + 8:off + 8 + length]
        crc_stored = struct.unpack(">I", data[off + 8 + length:off + 12 + length])[0]
        crc_calc = zlib.crc32(tag + body) & 0xffffffff
        assert crc_stored == crc_calc, f"CRC mismatch in {tag!r}"
        chunks.append((tag.decode(), length))
        off += 12 + length
    ihdr = chunks[0]
    assert ihdr[0] == "IHDR", "IHDR not first"
    return chunks


# ---- helpers ----------------------------------------------------------------

def clamp(v, lo, hi):
    return lo if v < lo else hi if v > hi else v


def lerp(a, b, t):
    return int(round(a + (b - a) * t))


def blend(row, px, color, cov):
    if cov <= 0.0:
        return
    if cov >= 1.0:
        i = px * 3
        row[i], row[i + 1], row[i + 2] = color
        return
    i = px * 3
    row[i] = lerp(row[i], color[0], cov)
    row[i + 1] = lerp(row[i + 1], color[1], cov)
    row[i + 2] = lerp(row[i + 2], color[2], cov)


# ---- renderers --------------------------------------------------------------

def render_calendar():
    W = H = 1024
    top = (0xFB, 0xFA, 0xF8)   # #FBFAF8
    bot = (0xEC, 0xEA, 0xE5)   # #ECEAE5
    dot_gray = (0xC9, 0xCD, 0xD3)   # #C9CDD3
    dot_today = (0x3D, 0x6C, 0x9E)  # #3D6C9E
    centers = (224, 416, 608, 800)
    today = (608, 416)  # (x, y): row 2, col 3
    r = 53.5            # diameter 107px

    # full-bleed vertical gradient — colour depends on y only, fill row at once
    rows = []
    for y in range(H):
        t = y / (H - 1)
        bg = bytes((lerp(top[0], bot[0], t), lerp(top[1], bot[1], t), lerp(top[2], bot[2], t)))
        rows.append(bytearray(bg * W))

    # analytic anti-aliased dots: coverage = clamp(0.5 + (r - dist), 0, 1)
    pad = 2
    for cyc in centers:
        for cxc in centers:
            color = dot_today if (cxc, cyc) == today else dot_gray
            x0 = max(0, int(math.floor(cxc - r - pad)))
            x1 = min(W, int(math.ceil(cxc + r + pad)))
            y0 = max(0, int(math.floor(cyc - r - pad)))
            y1 = min(H, int(math.ceil(cyc + r + pad)))
            for py in range(y0, y1):
                row = rows[py]
                dy = py + 0.5 - cyc
                for px in range(x0, x1):
                    dx = px + 0.5 - cxc
                    dist = math.hypot(dx, dy)
                    cov = clamp(0.5 + (r - dist), 0.0, 1.0)
                    blend(row, px, color, cov)
    return rows, W, H


def render_timer():
    W = H = 1024
    field = (0x23, 0x26, 0x2B)  # #23262B
    ring = (0x8A, 0x90, 0x97)   # #8A9097
    mark = (0xC9, 0xCD, 0xD3)   # #C9CDD3
    cx = cy = 512.0
    outer_r = 323.0   # centerline dia 619 -> centerline r 309.5, stroke 27 -> +/-13.5
    inner_r = 296.0

    rows = [bytearray(bytes(field) * W) for _ in range(H)]

    # anti-aliased annulus: cov = inside(outer) - inside(inner)
    pad = 2
    x0 = max(0, int(math.floor(cx - outer_r - pad)))
    x1 = min(W, int(math.ceil(cx + outer_r + pad)))
    y0 = max(0, int(math.floor(cy - outer_r - pad)))
    y1 = min(H, int(math.ceil(cy + outer_r + pad)))
    for py in range(y0, y1):
        row = rows[py]
        dy = py + 0.5 - cy
        for px in range(x0, x1):
            dx = px + 0.5 - cx
            dist = math.hypot(dx, dy)
            cov_out = clamp(0.5 + (outer_r - dist), 0.0, 1.0)
            cov_in = clamp(0.5 + (inner_r - dist), 0.0, 1.0)
            cov = cov_out - cov_in
            blend(row, px, ring, cov)

    # single index mark: axis-aligned rect x[498.5,525.5] y[178,306], drawn over the ring
    mx0, mx1 = 498.5, 525.5
    my0, my1 = 178.0, 306.0
    for py in range(int(math.floor(my0)) - 1, int(math.ceil(my1)) + 1):
        if py < 0 or py >= H:
            continue
        covy = clamp(min(py + 1.0, my1) - max(float(py), my0), 0.0, 1.0)
        if covy <= 0.0:
            continue
        row = rows[py]
        for px in range(int(math.floor(mx0)) - 1, int(math.ceil(mx1)) + 1):
            if px < 0 or px >= W:
                continue
            covx = clamp(min(px + 1.0, mx1) - max(float(px), mx0), 0.0, 1.0)
            blend(row, px, mark, covx * covy)
    return rows, W, H


# ---- drive ------------------------------------------------------------------

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
ASSETS = os.path.join(REPO, "App", "Resources", "Assets.xcassets")
ICONS = os.path.join(HERE, "icons")

TARGETS = [
    ("AppIconCalendar", render_calendar),
    ("AppIconTimer", render_timer),
]


def main():
    t_all = time.time()
    for name, fn in TARGETS:
        t0 = time.time()
        rows, w, h = fn()
        data = encode_png(rows, w, h)
        chunks = verify(data)
        set_dir = os.path.join(ASSETS, name + ".appiconset")
        os.makedirs(set_dir, exist_ok=True)
        os.makedirs(ICONS, exist_ok=True)
        fname = f"{name}-1024.png"
        for path in (os.path.join(set_dir, fname), os.path.join(ICONS, fname)):
            with open(path, "wb") as f:
                f.write(data)
        print(f"{name}: {w}x{h} bytes={len(data)} chunks={chunks} "
              f"render+encode={time.time() - t0:.2f}s CRCs=OK")
    print(f"TOTAL {time.time() - t_all:.2f}s")


if __name__ == "__main__":
    main()
