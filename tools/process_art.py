"""Convert a source artwork into Balatro's required sprite sizes.

Joker mode (default): crops to the card body, makes rounded corners
transparent, writes 71x95 (1x) and 142x190 (2x) to assets/{1x,2x}/j_<key>.png.

Icon mode (--icon): skips the crop (preserves the framed icon as drawn),
makes corners transparent, writes 32x32 (1x) and 64x64 (2x) to
assets/{1x,2x}/modicon.png.

Usage:
    python tools/process_art.py <source>                # j_foole.png
    python tools/process_art.py <source> <key>          # j_<key>.png
    python tools/process_art.py --icon <source>         # modicon.png

Examples:
    python tools/process_art.py infant.jpg foole_infant
    python tools/process_art.py --icon foole-icon.png
"""

import sys
from pathlib import Path
from PIL import Image, ImageDraw

JOKER_SIZE_1X = (71, 95)
JOKER_SIZE_2X = (142, 190)
ICON_SIZE_1X = (32, 32)
ICON_SIZE_2X = (64, 64)

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
    args = sys.argv[1:]
    icon_mode = False
    if args and args[0] == "--icon":
        icon_mode = True
        args = args[1:]
    if len(args) not in (1, 2):
        print(__doc__)
        sys.exit(1)
    src = Path(args[0])
    if not src.exists():
        print(f"Source not found: {src}")
        sys.exit(1)

    if icon_mode:
        size_1x, size_2x = ICON_SIZE_1X, ICON_SIZE_2X
        out_1x = PROJECT_ROOT / "assets" / "1x" / "modicon.png"
        out_2x = PROJECT_ROOT / "assets" / "2x" / "modicon.png"
    else:
        key = args[1] if len(args) == 2 else "foole"
        size_1x, size_2x = JOKER_SIZE_1X, JOKER_SIZE_2X
        out_1x = PROJECT_ROOT / "assets" / "1x" / f"j_{key}.png"
        out_2x = PROJECT_ROOT / "assets" / "2x" / f"j_{key}.png"

    print(f"Loading {src} ...")
    img = Image.open(src)
    print(f"  source size: {img.size}, mode: {img.mode}")

    if not icon_mode:
        print("Cropping to card body ...")
        img = crop_to_card(img)
        print(f"  cropped size: {img.size}")

    print("Making rounded corners transparent ...")
    img = make_corners_transparent(img)

    print(f"Resizing to {size_2x} (2x) ...")
    out_2x.parent.mkdir(parents=True, exist_ok=True)
    img.resize(size_2x, Image.LANCZOS).save(out_2x)
    print(f"  wrote {out_2x}")

    print(f"Resizing to {size_1x} (1x) ...")
    out_1x.parent.mkdir(parents=True, exist_ok=True)
    img.resize(size_1x, Image.LANCZOS).save(out_1x)
    print(f"  wrote {out_1x}")

    print("Done.")


if __name__ == "__main__":
    main()
