from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "Assets" / "AgentIcons"
OUT.mkdir(parents=True, exist_ok=True)

SOURCES = {
    "qwen": Path.home() / "Downloads" / "qwen.png",
    "gemini": Path.home() / "Downloads" / "gemini.png",
    "deepseek": Path.home() / "Downloads" / "deepseek.png",
}


def to_rgba(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    return rgba.crop((left, top, left + side, top + side))


def main() -> None:
    for name, source in SOURCES.items():
        image = to_rgba(Image.open(source))
        png_path = OUT / f"{name}.png"
        image.save(png_path)
        ico_path = OUT / f"{name}.ico"
        image.save(
            ico_path,
            format="ICO",
            sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)],
        )
        print(f"Generated: {png_path}")
        print(f"Generated: {ico_path}")


if __name__ == "__main__":
    main()
