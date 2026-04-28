"""Convert a source joker artwork into Balatro's two required sprite sizes.

Reads a single image (PNG/JPG, any size, with or without rounded-corner
background), crops to the card body, makes the rounded corners transparent
via tolerance flood-fill from each corner, then writes both 1x (71x95) and
2x (142x190) versions using Lanczos resampling.

Usage:
    python tools/process_art.py <source>                # writes j_foole.png
    python tools/process_art.py <source> <key>          # writes j_<key>.png

Examples:
    python tools/process_art.py infant.jpg foole_infant
    python tools/process_art.py child.jpg  foole_child
    python tools/process_art.py adult.jpg  foole
"""

import sys
from pathlib import Path
from PIL import Image, ImageDraw

# Balatro sprite dimensions
SIZE_1X = (71, 95)
SIZE_2X = (142, 190)

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Tolerance for "is this pixel part of the dark border?"
# Source has near-black corners; allow some compression noise.
DARK_THRESHOLD = 40  # any RGB channel < this counts as dark


def is_dark(pixel):
    r, g, b = pixel[:3]
    return r < DARK_THRESHOLD and g < DARK_THRESHOLD and b < DARK_THRESHOLD


def crop_to_card(img):
    """Crop to the bounding box of non-dark pixels."""
    rgb = img.convert("RGB")
    pixels = rgb.load()
    w, h = rgb.size
    left, top, right, bottom = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            if not is_dark(pixels[x, y]):
                if x < left: left = x
                if x > right: right = x
                if y < top: top = y
                if y > bottom: bottom = y
    return img.crop((left, top, right + 1, bottom + 1))


def make_corners_transparent(img):
    """Flood-fill from each corner, marking dark pixels transparent."""
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size

    # BFS flood-fill from each corner; only traverse dark pixels.
    from collections import deque
    visited = [[False] * h for _ in range(w)]
    starts = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    q = deque()
    for sx, sy in starts:
        if is_dark(pixels[sx, sy]):
            q.append((sx, sy))
            visited[sx][sy] = True

    while q:
        x, y = q.popleft()
        pixels[x, y] = (0, 0, 0, 0)  # fully transparent
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                if is_dark(pixels[nx, ny]):
                    visited[nx][ny] = True
                    q.append((nx, ny))
    return img


def main():
    if len(sys.argv) not in (2, 3):
        print(__doc__)
        sys.exit(1)
    src = Path(sys.argv[1])
    key = sys.argv[2] if len(sys.argv) == 3 else "foole"
    if not src.exists():
        print(f"Source not found: {src}")
        sys.exit(1)

    out_1x = PROJECT_ROOT / "assets" / "1x" / f"j_{key}.png"
    out_2x = PROJECT_ROOT / "assets" / "2x" / f"j_{key}.png"

    print(f"Loading {src} ...")
    img = Image.open(src)
    print(f"  source size: {img.size}, mode: {img.mode}")

    print("Cropping to card body ...")
    img = crop_to_card(img)
    print(f"  cropped size: {img.size}")

    print("Making rounded corners transparent ...")
    img = make_corners_transparent(img)

    print(f"Resizing to {SIZE_2X} (2x) ...")
    out_2x.parent.mkdir(parents=True, exist_ok=True)
    img.resize(SIZE_2X, Image.LANCZOS).save(out_2x)
    print(f"  wrote {out_2x}")

    print(f"Resizing to {SIZE_1X} (1x) ...")
    out_1x.parent.mkdir(parents=True, exist_ok=True)
    img.resize(SIZE_1X, Image.LANCZOS).save(out_1x)
    print(f"  wrote {out_1x}")

    print("Done.")


if __name__ == "__main__":
    main()
