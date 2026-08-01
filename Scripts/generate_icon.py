import shutil
import struct
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "Assets"
ASSETS.mkdir(exist_ok=True)

SIZE = 1024


def load_font(size: int):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def rounded_mask() -> Image.Image:
    mask = Image.new("L", (SIZE, SIZE), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=220, fill=255)
    return mask


def draw_letter_a(draw, cx, top, bottom, color, stroke, crossbar_stroke):
    spread = (bottom - top) * 0.42
    left = cx - spread
    right = cx + spread
    draw.line([(left, bottom), (cx, top)], fill=color, width=stroke, joint="curve")
    draw.line([(cx, top), (right, bottom)], fill=color, width=stroke, joint="curve")
    cross_y = top + (bottom - top) * 0.56
    draw.line([(cx - spread * 0.55, cross_y), (cx + spread * 0.55, cross_y)], fill=color, width=crossbar_stroke)


def app_icon() -> Image.Image:
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    background = Image.new("RGB", (SIZE, SIZE), (22, 22, 24))
    canvas.paste(background, (0, 0), rounded_mask())
    draw = ImageDraw.Draw(canvas, "RGBA")
    font = load_font(560)
    draw.text((340, 490), "A", font=font, fill=(10, 132, 255, 255), anchor="mm")
    draw.text((700, 490), "B", font=font, fill=(255, 255, 255, 255), anchor="mm")
    return canvas


def menu_bar_icon() -> Image.Image:
    image = Image.new("RGBA", (36, 36), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image, "RGBA")
    font = load_font(24)
    draw.text((18, 18), "AB", font=font, fill=(0, 0, 0, 255), anchor="mm")
    return image


def main() -> None:
    canvas = app_icon()

    source = ASSETS / "AppIcon.png"
    canvas.save(source)

    menu_source = ASSETS / "MenuBarIcon.png"
    menu_bar_icon().save(menu_source)

    iconset = ASSETS / "AppIcon.iconset"
    iconset.mkdir(exist_ok=True)
    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for name, size in sizes.items():
        resized = canvas.resize((size, size), Image.LANCZOS)
        resized.save(iconset / name)

    icns_path = ASSETS / "AppIcon.icns"
    png_map = [
        ("icp4", iconset / "icon_16x16.png"),
        ("icp5", iconset / "icon_32x32.png"),
        ("icp6", iconset / "icon_32x32@2x.png"),
        ("ic07", iconset / "icon_128x128.png"),
        ("ic08", iconset / "icon_256x256.png"),
        ("ic09", iconset / "icon_512x512.png"),
        ("ic10", iconset / "icon_512x512@2x.png"),
        ("ic11", iconset / "icon_16x16@2x.png"),
        ("ic12", iconset / "icon_32x32@2x.png"),
        ("ic13", iconset / "icon_128x128@2x.png"),
        ("ic14", iconset / "icon_256x256@2x.png"),
    ]
    with open(icns_path, "wb") as handle:
        total = 8 + sum(8 + png.stat().st_size for _, png in png_map)
        handle.write(b"icns")
        handle.write(struct.pack(">I", total))
        for ostype, png in png_map:
            data = png.read_bytes()
            handle.write(ostype.encode("ascii"))
            handle.write(struct.pack(">I", 8 + len(data)))
            handle.write(data)

    shutil.rmtree(iconset)
    print(f"Generated: {source}")
    print(f"Generated: {menu_source}")
    print(f"Generated: {icns_path}")


if __name__ == "__main__":
    main()
