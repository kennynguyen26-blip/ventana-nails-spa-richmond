#!/bin/bash
# =============================================================================
#  optimize-images.sh  —  Ventana Nails & Spa Richmond
#
#  WHAT IT DOES:
#   1. Copies every photo it hasn't seen before from images/ into
#      images-originals/ so the full-size original is never lost.
#   2. Shrinks every photo in images/ (always working from the saved original),
#      keeping the same file name:
#        drinks   -> 1080 px wide max, JPEG quality 60
#        gallery  -> 1080 px wide max, JPEG quality 70
#        services ->  900 px wide max, JPEG quality 80
#        logo.png ->  360 px wide max (PNG, keeps the transparent background)
#   3. Writes a .webp copy next to every photo (needs `cwebp`: brew install webp).
#      Browsers that understand WebP get the smaller .webp; others get the .jpg/.png.
#   4. Builds favicon.ico, apple-touch-icon.png and images/og-image.jpg from the logo.
#   5. Prints the folder size before and after.
#
#  HOW TO RUN (Terminal, from this folder):
#        bash optimize-images.sh            # only new or changed photos
#        bash optimize-images.sh --force    # redo everything from the originals
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

SRC="images-originals"   # untouched originals (not uploaded, see .gitignore)
OUT="images"             # what the site uses
FORCE=0; [ "${1:-}" = "--force" ] && FORCE=1
MANIFEST="$SRC/optimized-sizes.txt"
mkdir -p "$SRC"; touch "$MANIFEST"
HAVE_WEBP=0; command -v cwebp >/dev/null 2>&1 && HAVE_WEBP=1

size_of()  { stat -f %z "$1"; }
width_of() { sips -g pixelWidth "$1" | awk '/pixelWidth/{print $2}'; }
is_done()  { grep -qx "$1 $2" "$MANIFEST"; }
record()   { { grep -v "^$1 " "$MANIFEST" || true; echo "$1 $2"; } > "$MANIFEST.tmp"; mv "$MANIFEST.tmp" "$MANIFEST"; }

BEFORE=$(du -sk "$OUT" | cut -f1)
echo "== Optimizing photos in $OUT/ (originals kept in $SRC/) =="

optimize_one() {   # $1 file name  $2 max width  $3 quality (jpeg) / webp quality
  local name="$1" maxw="$2" q="$3"
  local cur="$OUT/$name" orig="$SRC/$name" tmp="$OUT/.tmp-$name"
  [ -e "$cur" ] || { echo "  missing, skipped  $name"; return; }
  if [ $FORCE -eq 0 ] && is_done "$name" "$(size_of "$cur")"; then echo "  already done       $name"; return; fi
  # a file we haven't processed yet is an original -> keep a safe copy first
  if [ $FORCE -eq 0 ] || [ ! -e "$orig" ]; then cp -p "$cur" "$orig"; fi
  local before; before=$(size_of "$orig")
  local w; w=$(width_of "$orig")
  local resize=(); [ "$w" -gt "$maxw" ] && resize=(--resampleWidth "$maxw")
  if [[ "$name" == *.png ]]; then
    sips ${resize[@]+"${resize[@]}"} "$orig" --out "$tmp" >/dev/null
  else
    sips -s format jpeg -s formatOptions "$q" ${resize[@]+"${resize[@]}"} "$orig" --out "$tmp" >/dev/null
  fi
  if [ "$(size_of "$tmp")" -ge "$before" ]; then cp -p "$orig" "$tmp"; fi   # never bigger than the original
  mv "$tmp" "$cur"
  if [ $HAVE_WEBP -eq 1 ]; then
    if [[ "$name" == *.png ]]; then cwebp -quiet -q 90 -alpha_q 100 "$cur" -o "${cur%.*}.webp"
    else cwebp -quiet -q "$((q + 4))" -m 6 "$cur" -o "${cur%.*}.webp"; fi
  fi
  record "$name" "$(size_of "$cur")"
  printf "  %-22s %5s px  %6d KB -> %4d KB jpg/png%s\n" "$name" "$(width_of "$cur")" $((before/1024)) $(( $(size_of "$cur")/1024 )) \
    "$( [ $HAVE_WEBP -eq 1 ] && printf ', %d KB webp' $(( $(size_of "${cur%.*}.webp")/1024 )) )"
}

for i in $(seq 1 6);  do optimize_one "gallery-$i.jpg" 1080 70; done
for n in manicure pedicure nails waxing eyelash; do optimize_one "service-$n.jpg" 900 80; done
for i in $(seq 1 32); do optimize_one "drink-$i.jpg" 1080 60; done
optimize_one "logo.png" 360 0

echo "== Building favicon.ico, apple-touch-icon.png, images/og-image.jpg from the logo =="
LOGO="$SRC/logo.png"; [ -e "$LOGO" ] || LOGO="$OUT/logo.png"
TMPD="$(mktemp -d)"
sips -s format ico -Z 48 "$LOGO" --out favicon.ico >/dev/null
sips -Z 180 "$LOGO" --out apple-touch-icon.png >/dev/null
sips -Z 520 "$LOGO" --out "$TMPD/og.png" >/dev/null
sips -p 630 1200 --padColor 1C1915 "$TMPD/og.png" --out "$TMPD/og-pad.png" >/dev/null 2>&1
sips -s format jpeg -s formatOptions 85 "$TMPD/og-pad.png" --out "$OUT/og-image.jpg" >/dev/null
rm -rf "$TMPD"
[ $HAVE_WEBP -eq 1 ] || echo "  (cwebp not installed: no .webp copies were made. Install with: brew install webp)"

AFTER=$(du -sk "$OUT" | cut -f1)
echo "== Done =="
awk -v b="$BEFORE" -v a="$AFTER" 'BEGIN{printf "  images/ before: %.1f MB\n  images/ after : %.1f MB (includes the .webp copies)\n", b/1024, a/1024}'
