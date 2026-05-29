#!/usr/bin/env python3
"""Wallpaper Curator — web UI for scanning, browsing, and organizing wallpaper collections."""

import argparse
import json
import os
import shutil
import subprocess
import sys
import threading
import time
import webbrowser
from datetime import datetime, timezone
from pathlib import Path

from flask import Flask, jsonify, request, send_file, send_from_directory
from PIL import Image

# ─── Config ─────────────────────────────────────────────────────────────────
SCREEN_W = 2560
SCREEN_H = 1440
CACHE_DIR = Path.home() / ".cache" / "wallpaper-curator"
THUMB_DIR = CACHE_DIR / "thumbs"
DATA_DIR = Path.home() / ".local" / "share" / "wallpaper-curator"
MANIFEST_PATH = DATA_DIR / "manifest.json"
DEFAULT_TARGET = Path.home() / ".dotfiles-sevens" / "wallpapers"

PRESET_TAGS = [
    "Catppuccin", "Nord", "Dracula", "Gruvbox", "Everforest",
    "Tokyo-Night", "Rose-Pine", "Material", "Osaka",
    "Minimal", "Dark", "Nature", "Anime", "Uncategorized"
]

app = Flask(__name__)
WATCH_DIR = ""
IMAGES = {}  # rel_path -> {metadata, decision, tags}
LOCK = threading.Lock()


# ─── Image Metadata ─────────────────────────────────────────────────────────

def tier_label(w, h):
    if h > w:
        return "portrait"
    ratio = w / h if h else 1
    if ratio > 2.1:
        return "ultrawide"
    if w < 1920 or h < 1080:
        return "lowres"
    if w >= SCREEN_W and h >= SCREEN_H:
        return "fit"
    return "smaller"


def classify(w, h):
    t = tier_label(w, h)
    return {
        "tier": t,
        "width": w,
        "height": h,
        "aspect": f"{w // (lambda a, b: b if b else 1)(w, h) if (lambda a, b: b if b else 1)(w, h) else 1}:{h // (lambda a, b: b if b else 1)(w, h) if (lambda a, b: b if b else 1)(w, h) else 1}",
        "megapixels": round(w * h / 1_000_000, 2),
    }


def scan_directory(path):
    """Walk directory, collect image files, extract metadata."""
    path = Path(path).resolve()
    results = {}
    extensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff', '.tif', '.avif'}

    for f in sorted(path.rglob("*")):
        if f.suffix.lower() not in extensions or not f.is_file():
            continue
        rel = str(f.relative_to(path))
        try:
            with Image.open(f) as img:
                w, h = img.size
                fmt = img.format or "UNKNOWN"
        except Exception:
            continue
        size_bytes = f.stat().st_size
        t = tier_label(w, h)
        results[rel] = {
            "path": str(f),
            "rel": rel,
            "width": w,
            "height": h,
            "format": fmt,
            "size_bytes": size_bytes,
            "tier": t,
            "decision": "pending",
            "tags": [],
        }
    return results


def generate_thumbnail(src, dst):
    """Generate a thumbnail for rofi/browser display."""
    if dst.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    try:
        with Image.open(src) as img:
            img.thumbnail((330, 540), Image.LANCZOS)
            bg = Image.new("RGB", (330, 540), (0, 0, 0))
            offset = ((330 - img.width) // 2, (540 - img.height) // 2)
            bg.paste(img, offset)
            bg.save(dst, "JPEG", quality=80)
    except Exception as e:
        print(f"  [WARN] thumbnail failed: {src.name}: {e}", file=sys.stderr)


# ─── Manifest I/O ───────────────────────────────────────────────────────────

def load_manifest():
    if MANIFEST_PATH.exists():
        try:
            return json.loads(MANIFEST_PATH.read_text())
        except Exception:
            pass
    return {"scanned_at": None, "source_dir": "", "screen": f"{SCREEN_W}x{SCREEN_H}",
            "total_scanned": 0, "kept": 0, "discarded": 0, "images": {}}


def save_manifest(data):
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(data, indent=2))


def write_organize_manifest(entries=None):
    """Write the manifest with all images and their decisions."""
    if entries is None:
        entries = []
        for rel, img in IMAGES.items():
            entry = {
                "path": str(Path(WATCH_DIR) / rel),
                "width": img["width"],
                "height": img["height"],
                "format": img["format"],
                "size_bytes": img["size_bytes"],
                "tier": img["tier"],
                "decision": img.get("decision", "pending"),
                "tags": img.get("tags", []),
            }
            if img.get("organized"):
                entry["organized"] = True
            entries.append(entry)
    kept = sum(1 for e in entries if e.get("decision") == "keep")
    discarded = sum(1 for e in entries if e.get("decision") == "discard")
    now = datetime.now(timezone.utc).isoformat()
    manifest = {
        "scanned_at": now,
        "source_dir": str(WATCH_DIR),
        "screen": f"{SCREEN_W}x{SCREEN_H}",
        "total_scanned": len(IMAGES),
        "kept": kept,
        "discarded": discarded,
        "images": entries,
    }
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2))
    return manifest


# ─── Flask Routes ───────────────────────────────────────────────────────────

@app.route("/")
def index():
    return send_from_directory(app.root_path, "curator.html")


@app.route("/favicon.ico")
def favicon():
    return "", 204

@app.route("/api/images")
def api_images():
    tier_filter = request.args.get("tier", "all")
    tag_filter = request.args.get("tag", "")
    decision_filter = request.args.get("decision", "all")
    search = request.args.get("q", "").lower()

    with LOCK:
        items = list(IMAGES.values())

    results = []
    for img in items:
        if tier_filter != "all" and img.get("tier") != tier_filter:
            continue
        if decision_filter != "all" and img.get("decision", "pending") != decision_filter:
            continue
        if tag_filter and tag_filter not in img.get("tags", []):
            continue
        if search and search not in img["rel"].lower():
            continue
        results.append({
            "rel": img["rel"],
            "width": img["width"],
            "height": img["height"],
            "format": img["format"],
            "size_bytes": img["size_bytes"],
            "tier": img["tier"],
            "decision": img.get("decision", "pending"),
            "tags": img.get("tags", []),
            "thumbnail": f"/api/thumbnail/{img['rel']}",
        })

    return jsonify({
        "images": results,
        "total": len(items),
        "filtered": len(results),
        "stats": {
            "fit": sum(1 for i in items if i.get("tier") == "fit"),
            "smaller": sum(1 for i in items if i.get("tier") == "smaller"),
            "portrait": sum(1 for i in items if i.get("tier") == "portrait"),
            "ultrawide": sum(1 for i in items if i.get("tier") == "ultrawide"),
            "lowres": sum(1 for i in items if i.get("tier") == "lowres"),
            "kept": sum(1 for i in items if i.get("decision") == "keep"),
            "discarded": sum(1 for i in items if i.get("decision") == "discard"),
            "pending": sum(1 for i in items if i.get("decision") == "pending"),
        },
    })


@app.route("/api/thumbnail/<path:rel>")
def api_thumbnail(rel):
    src = Path(WATCH_DIR) / rel
    if not src.exists():
        return "", 404
    dst = THUMB_DIR / f"{hash(rel)}.jpg"
    if not dst.exists():
        generate_thumbnail(src, dst)
    if not dst.exists():
        return "", 404
    return send_file(str(dst), mimetype="image/jpeg")


@app.route("/api/image/<path:rel>")
def api_image(rel):
    path = Path(WATCH_DIR) / rel
    if not path.exists():
        return jsonify({"error": "not found"}), 404
    return send_file(str(path))


@app.route("/api/decide", methods=["POST"])
def api_decide():
    data = request.get_json()
    rel = data.get("rel", "")
    decision = data.get("decision", "pending")
    tag = data.get("tag", "")

    with LOCK:
        if rel not in IMAGES:
            return jsonify({"error": "not found"}), 404
        IMAGES[rel]["decision"] = decision
        if tag:
            existing = IMAGES[rel].get("tags", [])
            if tag not in existing:
                existing.append(tag)
            IMAGES[rel]["tags"] = existing

    write_organize_manifest()

    return jsonify({"ok": True, "image": IMAGES[rel]})


@app.route("/api/tag-replace", methods=["POST"])
def api_tag_replace():
    """Replace all tags on an image."""
    data = request.get_json()
    rel = data.get("rel", "")
    new_tags = data.get("tags", [])

    with LOCK:
        if rel not in IMAGES:
            return jsonify({"error": "not found"}), 404
        IMAGES[rel]["tags"] = new_tags

    write_organize_manifest()
    return jsonify({"ok": True, "image": IMAGES[rel]})


@app.route("/api/batch-decide", methods=["POST"])
def api_batch_decide():
    data = request.get_json()
    decision = data.get("decision", "keep")
    tier = data.get("tier", "all")
    tag = data.get("tag", "")

    count = 0
    with LOCK:
        for rel, img in IMAGES.items():
            if img.get("decision") != "pending":
                continue
            if tier != "all" and img.get("tier") != tier:
                continue
            IMAGES[rel]["decision"] = decision
            if tag:
                existing = IMAGES[rel].get("tags", [])
                if tag not in existing:
                    existing.append(tag)
                IMAGES[rel]["tags"] = existing
            count += 1

    return jsonify({"ok": True, "affected": count})


@app.route("/api/tags")
def api_tags():
    return jsonify(PRESET_TAGS)


@app.route("/api/organize", methods=["POST"])
def api_organize():
    """Copy kept wallpapers to target themed directories."""
    data = request.get_json() or {}
    target = Path(data.get("target", str(DEFAULT_TARGET)))
    dry_run = data.get("dry_run", False)
    commit = data.get("commit", False)

    copied = 0
    errors = 0
    theme_counts = {}

    with LOCK:
        for rel, img in IMAGES.items():
            if img.get("decision") != "keep":
                continue
            tags = img.get("tags", [])
            theme = tags[0] if tags else "Uncategorized"
            src = Path(WATCH_DIR) / rel

            dest_dir = target / theme
            dest = dest_dir / Path(rel).name

            # Skip if already organized (dest exists with same name)
            if dest.exists():
                continue

            if dry_run:
                print(f"  [COPY] {Path(rel).name} → {theme}/")
                copied += 1
                continue

            dest_dir.mkdir(parents=True, exist_ok=True)
            try:
                shutil.copy2(str(src), str(dest))
                copied += 1
                theme_counts[theme] = theme_counts.get(theme, 0) + 1
                img["organized"] = True
            except Exception as e:
                print(f"  [ERR] {Path(rel).name}: {e}", file=sys.stderr)
                errors += 1

    if not dry_run:
        write_organize_manifest()

    if commit and not dry_run:
        try:
            subprocess.run(["git", "-C", str(target), "add", "-A"], check=False)
            subprocess.run(
                ["git", "-C", str(target), "commit", "-m",
                 f"wallpapers: organize curated ({datetime.now():%Y-%m-%d})"],
                check=False,
            )
        except Exception:
            pass

    return jsonify({
        "ok": True,
        "dry_run": dry_run,
        "copied": copied,
        "errors": errors,
        "theme_counts": theme_counts,
        "target": str(target),
    })


# ─── CLI ────────────────────────────────────────────────────────────────────

def apply_manifest_arg(args):
    global MANIFEST_PATH
    if getattr(args, "manifest", None):
        MANIFEST_PATH = Path(args.manifest)

def cmd_scan(args):
    global WATCH_DIR, IMAGES
    apply_manifest_arg(args)
    WATCH_DIR = str(Path(args.directory).resolve())
    print(f"Scanning {WATCH_DIR}...")
    IMAGES = scan_directory(WATCH_DIR)
    print(f"Found {len(IMAGES)} images")

    # Pre-generate thumbnails
    print("Generating thumbnails...")
    for i, rel in enumerate(IMAGES, 1):
        src = Path(WATCH_DIR) / rel
        dst = THUMB_DIR / f"{hash(rel)}.jpg"
        generate_thumbnail(src, dst)
        if i % 50 == 0:
            print(f"  {i}/{len(IMAGES)}")
    print("Done.")

    write_organize_manifest()
    print(f"Manifest saved: {MANIFEST_PATH}")


def load_images_from_manifest():
    """Restore IMAGES global from saved manifest."""
    global WATCH_DIR, IMAGES
    data = load_manifest()
    if not data.get("images"):
        print("No scanned data found. Run 'scan' first or use 'scan + serve'.")
        return
    WATCH_DIR = data.get("source_dir", "")
    for entry in data["images"]:
        path = Path(entry["path"])
        try:
            rel = str(path.relative_to(Path(WATCH_DIR)))
        except ValueError:
            rel = path.name
        IMAGES[rel] = {
            "path": entry["path"],
            "rel": rel,
            "width": entry.get("width", 0),
            "height": entry.get("height", 0),
            "format": entry.get("format", ""),
            "size_bytes": entry.get("size_bytes", 0),
            "tier": entry.get("tier", "unknown"),
            "decision": entry.get("decision", "pending"),
            "tags": entry.get("tags", []),
            "organized": entry.get("organized", False),
        }
    print(f"Loaded {len(IMAGES)} images from manifest (source: {WATCH_DIR})")


def cmd_serve(args):
    global WATCH_DIR, IMAGES
    apply_manifest_arg(args)
    port = args.port or 8080
    load_images_from_manifest()
    if not IMAGES and args.directory:
        WATCH_DIR = str(Path(args.directory).resolve())
        IMAGES = scan_directory(WATCH_DIR)
        write_organize_manifest()
        print(f"Scanned {len(IMAGES)} images from {WATCH_DIR}")
    print(f"Manifest: {MANIFEST_PATH}")
    print(f"Starting curator at http://localhost:{port}")
    threading.Timer(1.5, lambda: webbrowser.open(f"http://localhost:{port}")).start()
    app.run(host="0.0.0.0", port=port, debug=False)


def cmd_organize(args):
    apply_manifest_arg(args)
    manifest_data = load_manifest()
    entries = [e for e in manifest_data.get("images", []) if e.get("decision") == "keep"]
    if not entries:
        print("No kept images to organize.")
        return

    target = Path(args.target or DEFAULT_TARGET)
    dry_run = args.dry_run
    copied = 0
    errors = 0
    theme_counts = {}

    for entry in entries:
        src = Path(entry["path"])
        if not src.exists():
            errors += 1
            continue
        tags = entry.get("tags", [])
        theme = tags[0] if tags else "Uncategorized"
        dest_dir = target / theme
        dest = dest_dir / src.name
        if dest.exists():
            continue
        if dry_run:
            print(f"  {src.name} → {theme}/")
            copied += 1
            continue
        dest_dir.mkdir(parents=True, exist_ok=True)
        try:
            shutil.copy2(str(src), str(dest))
            copied += 1
            theme_counts[theme] = theme_counts.get(theme, 0) + 1
        except Exception as e:
            print(f"  ERR {src.name}: {e}", file=sys.stderr)
            errors += 1

    print(f"\nCopied: {copied} | Errors: {errors}")
    for theme, count in sorted(theme_counts.items()):
        print(f"  {theme}: {count}")


# ─── Entry Point ────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Wallpaper Curator")
    sub = parser.add_subparsers(dest="cmd", required=True)

    def add_manifest_arg(p):
        p.add_argument("--manifest", "-m", help="Manifest file path (default: ~/.local/share/wallpaper-curator/manifest.json)")

    scan_parser = sub.add_parser("scan", help="Scan a directory and generate thumbnails")
    scan_parser.add_argument("directory", help="Directory to scan")
    add_manifest_arg(scan_parser)
    scan_parser.set_defaults(func=cmd_scan)

    serve_parser = sub.add_parser("serve", help="Start the web curator UI")
    serve_parser.add_argument("directory", nargs="?", help="Optional: scan directory first")
    serve_parser.add_argument("--port", "-p", type=int, default=8080, help="Port (default: 8080)")
    add_manifest_arg(serve_parser)
    serve_parser.set_defaults(func=cmd_serve)

    org_parser = sub.add_parser("organize", help="Copy kept images to themed directories")
    org_parser.add_argument("--target", "-t", help="Target wallpapers directory")
    org_parser.add_argument("--dry-run", "-n", action="store_true", help="Preview only")
    add_manifest_arg(org_parser)
    org_parser.set_defaults(func=cmd_organize)

    all_parser = sub.add_parser("all", help="Scan + serve in one command")
    all_parser.add_argument("directory", help="Directory to scan")
    all_parser.add_argument("--port", "-p", type=int, default=8080)
    add_manifest_arg(all_parser)
    all_parser.set_defaults(func=cmd_organize_all)

    args = parser.parse_args()

    if args.cmd == "all":
        class ScanNS: pass
        scan_args = ScanNS()
        scan_args.directory = args.directory
        cmd_scan(scan_args)

        class ServeNS: pass
        serve_args = ServeNS()
        serve_args.port = args.port
        cmd_serve(serve_args)
    else:
        args.func(args)


def cmd_organize_all(args):
    apply_manifest_arg(args)
    cmd_scan(args)
    cmd_serve(args)


if __name__ == "__main__":
    main()
