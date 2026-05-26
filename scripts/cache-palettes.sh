#!/usr/bin/env bash
# Pre-generate wallust palettes for all wallpapers (JSON + 16-color swatch PNG).
# Usage: cache-palettes.sh [--force]

set -euo pipefail

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-palettes"

mkdir -p "$CACHE_DIR"

FORCE="${1:-}"

# Count images first
total=0
while IFS= read -r -d '' f; do
    ((total++)) || true
done < <(find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.avif' \) -print0)

echo "==> Pre-generating palettes for $total wallpapers..."

processed=0
skipped=0
failed=0

# Process each image
while IFS= read -r -d '' img; do
    rel="${img#$WALL_DIR/}"
    name_hash=$(echo -n "$rel" | sha256sum | cut -c1-16)
    cache_json="$CACHE_DIR/$name_hash.json"

    if [[ -f "$cache_json" && "$FORCE" != "--force" ]]; then
        ((skipped++)) || true
        continue
    fi

    if wallust run "$img" --quiet 2>/dev/null; then
        # Normalize wallpaper path in cache to use WALL_DIR (resolve symlinks)
        python3 -c "
import json, os
with open('$HOME/.cache/wallust/colors.json') as f:
    data = json.load(f)
data['wallpaper'] = os.path.realpath('$img')
with open('$cache_json', 'w') as f:
    json.dump(data, f)
" 2>/dev/null || cp "$HOME/.cache/wallust/colors.json" "$cache_json"
        ((processed++)) || true
    else
        ((failed++)) || true
    fi

    if [[ $(( (processed + skipped + failed) % 30 )) -eq 0 ]]; then
        printf "\r  %d/%d processed, %d skipped, %d failed" "$processed" "$total" "$skipped" "$failed"
    fi
done < <(find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.avif' \) -print0 | sort -z)

printf "\r  %d/%d processed, %d skipped, %d failed\n" "$processed" "$total" "$skipped" "$failed"

# Generate swatch thumbnails via Python
echo "==> Generating swatch thumbnails..."
python3 -c "
import json, os
from PIL import Image

cache_dir = os.path.expanduser('$CACHE_DIR')
thumb_dir = os.path.expanduser('$HOME/.cache/thumbnails/palettes')
os.makedirs(thumb_dir, exist_ok=True)
count = 0
for f in os.listdir(cache_dir):
    if not f.endswith('.json'):
        continue
    name_hash = f[:-5]
    swatch_path = os.path.join(thumb_dir, f'{name_hash}.png')
    if os.path.exists(swatch_path):
        continue
    with open(os.path.join(cache_dir, f)) as fh:
        data = json.load(fh)
    colors = [data['colors'][f'color{i}'] for i in range(16)]
    rgb = []
    for c in colors:
        c = c.lstrip('#')
        rgb.append(tuple(int(c[i:i+2], 16) for i in (0, 2, 4)))
    img = Image.new('RGB', (320, 20))
    for i, col in enumerate(rgb):
        for x in range(i * 20, (i + 1) * 20):
            for y in range(20):
                img.putpixel((x, y), col)
    img.resize((160, 10), Image.NEAREST).save(swatch_path)
    count += 1
print(f'  {count} swatch thumbnails generated')
" 2>&1

echo "==> Done. $processed cached, $skipped skipped, $failed failed."
