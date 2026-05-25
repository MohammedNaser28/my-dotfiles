#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/thumbnails/bgselector"
CACHE_INDEX="$CACHE_DIR/.index"

mkdir -p "$CACHE_DIR"

# Build current wallpaper index
current_index=$(mktemp)
find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.avif' \) -printf '%p\n' > "$current_index"

# Clean orphaned cache files
if [ -f "$CACHE_INDEX" ]; then
    while read -r cached_path; do
        if [ ! -f "$cached_path" ]; then
            rel_path="${cached_path#$WALL_DIR/}"
            cache_name="${rel_path//\//_}"
            cache_name="${cache_name%.*}.jpg"
            rm -f "$CACHE_DIR/$cache_name"
        fi
    done < "$CACHE_INDEX"
fi

# Generate thumbnails with validation
progress_file=$(mktemp)
touch "$progress_file"

max_jobs=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

to_generate=$(mktemp)
while read -r img; do
    rel_path="${img#$WALL_DIR/}"
    cache_name="${rel_path//\//_}"
    cache_name="${cache_name%.*}.jpg"
    cache_file="$CACHE_DIR/$cache_name"

    [ -f "$cache_file" ] || echo "$img" >> "$to_generate"
done < "$current_index"

generate_thumbnail() {
    local img="$1"
    local cache_dir="$2"
    local wall_dir="$3"
    local progress="$4"

    local rel_path="${img#$wall_dir/}"
    local cache_name="${rel_path//\//_}"
    cache_name="${cache_name%.*}.jpg"
    local cache_file="$cache_dir/$cache_name"

    if [[ "$img" =~ \.(gif|GIF)$ ]]; then
        magick "$img[0]" -define jpeg:size=660x1080 -filter Triangle -strip \
            -thumbnail 330x540^ -gravity center -extent 330x540 \
            -quality 80 +repage "$cache_file" 2>/dev/null
    else
        magick "$img" -define jpeg:size=660x1080 -filter Triangle -strip \
            -thumbnail 330x540^ -gravity center -extent 330x540 \
            -quality 80 +repage "$cache_file" 2>/dev/null
    fi
    [ -f "$cache_file" ] && echo "1" >> "$progress"
}
export -f generate_thumbnail

if command -v xargs >/dev/null 2>&1 && [ -s "$to_generate" ]; then
    cat "$to_generate" | xargs -P "$max_jobs" -I {} bash -c \
        'generate_thumbnail "$1" "$2" "$3" "$4"' _ {} "$CACHE_DIR" "$WALL_DIR" "$progress_file"
elif [ -s "$to_generate" ]; then
    job_count=0
    while read -r img; do
        generate_thumbnail "$img" "$CACHE_DIR" "$WALL_DIR" "$progress_file" &
        ((job_count++))
        if [ $((job_count % max_jobs)) -eq 0 ]; then
            wait -n 2>/dev/null || wait
        fi
    done < "$to_generate"
    wait
fi

rm -f "$to_generate"

total_generated=$(wc -l < "$progress_file" 2>/dev/null || echo 0)
[ $total_generated -gt 0 ] && echo "Generated $total_generated thumbnails" || echo "Cache up to date"
rm -f "$progress_file"

mv "$current_index" "$CACHE_INDEX"

# --- Output selection ---

select_output() {
    local outputs=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^Output ]]; then
            local name
            name=$(echo "$line" | grep -oP '\(\K[^)]+')
            [ -n "$name" ] && outputs+=("$name")
        fi
    done < <(niri msg outputs 2>/dev/null)

    if [ ${#outputs[@]} -eq 0 ]; then
        echo "all"
        return
    fi

    if [ ${#outputs[@]} -eq 1 ]; then
        echo "${outputs[0]}"
        return
    fi

    local chosen
    chosen=$({
        printf 'All outputs\n'
        for out in "${outputs[@]}"; do
            printf '%s\n' "$out"
        done
    } | vicinae dmenu -n " Wallpaper " -s "Select output" -W 300)

    if [ "$chosen" = "All outputs" ]; then
        echo "all"
    elif [ -n "$chosen" ]; then
        echo "$chosen"
    fi
}

select_wallpaper() {
    local prompt="${1:-Select wallpaper}"
    local chosen
    chosen=$(while read -r abs; do
        # Show "folder/filename" for display; absolute path triggers quick look preview
        echo "$abs"
    done < "$CACHE_INDEX" \
        | vicinae dmenu -n " Wallpaper " -s "{count} wallpapers" -p "$prompt" -W 800 --no-metadata)

    # Return relative path from absolute
    echo "${chosen#$WALL_DIR/}"
}

apply_wallpaper() {
    local selected="$1"
    local target="$2"
    local selected_path="$WALL_DIR/$selected"

    if [ ! -f "$selected_path" ]; then
        return 1
    fi

    if [ "$target" == "all" ]; then
        awww img "$selected_path" -t fade --transition-duration 2 --transition-fps 30 &
    else
        awww img "$selected_path" -o "$target" -t fade --transition-duration 2 --transition-fps 30 &
    fi
    return 0
}

# --- Main flow ---

target=$(select_output)
[ -z "$target" ] && exit 0

SELECTED_PATH=""

if [ "$target" == "all" ]; then
    selected=$(select_wallpaper "Select wallpaper")
    [ -z "$selected" ] && exit 0
    SELECTED_PATH="$WALL_DIR/$selected"
    apply_wallpaper "$selected" "all"
    sleep 0.2
else
    selected=$(select_wallpaper "Wallpaper for $target")
    [ -z "$selected" ] && exit 0
    SELECTED_PATH="$WALL_DIR/$selected"
    apply_wallpaper "$selected" "$target"
    sleep 0.2

    # Offer to set wallpaper for remaining outputs
    local all_outputs=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^Output ]]; then
            local name
            name=$(echo "$line" | grep -oP '\(\K[^)]+')
            [ -n "$name" ] && all_outputs+=("$name")
        fi
    done < <(niri msg outputs 2>/dev/null)

    for out in "${all_outputs[@]}"; do
        if [ "$out" != "$target" ]; then
            local choice
            choice=$(printf "Yes\nNo" | vicinae dmenu -n " Wallpaper " -s "Set same for $out?" -W 300)
            if [ "$choice" = "Yes" ]; then
                awww img "$SELECTED_PATH" -o "$out" -t fade --transition-duration 2 --transition-fps 30 &
                sleep 0.2
            else
                local other_sel
                other_sel=$(select_wallpaper "Wallpaper for $out")
                [ -n "$other_sel" ] && awww img "$WALL_DIR/$other_sel" -o "$out" -t fade --transition-duration 2 --transition-fps 30 &
                sleep 0.2
            fi
        fi
    done
fi

sleep 0.2
"$HOME/.config/scripts/theme-sync.sh" &
wait
