# Ventana Nails & Spa — Richmond, TX

Website for **Ventana Nails & Spa**, 9711 Mason Rd Ste 120, Richmond, TX 77407 · (832) 422-6979.

One plain `index.html` plus an `images/` folder. No frameworks, no build step. Same design and features as the Katy site (cream / charcoal / Ventana gold), with Richmond's own details, menu, reviews and photos.

## What's in this folder

```
ventana-nails-spa-richmond/
├── index.html            The whole website (design, text, prices, Spanish, scripts)
├── terms.html            Terms of Use
├── privacy.html          Privacy Policy
├── accessibility.html    Accessibility statement
├── images/               Web-size photos (.jpg/.png) + a smaller .webp copy of each
├── images-originals/     Untouched full-size originals. NOT uploaded (see .gitignore)
├── optimize-images.sh    Shrinks photos and makes the .webp copies
├── favicon.ico, apple-touch-icon.png, images/og-image.jpg   Icons + share image (made from the logo)
├── robots.txt, sitemap.xml   For Google
└── vercel.json           Security headers when hosted on Vercel
```

## Preview it on your Mac

```bash
cd ~/ventana-nails-spa-richmond && python3 -m http.server 8766
```

Then open http://localhost:8766 in your browser.

## Change business details

Everything (booking link, phone, email, address, Instagram, Facebook, website address, rating, review count, map, **opening hours**) lives in the `CONFIG` block near the bottom of `index.html`. Change a value between the quotes, save, reload. Every button, link, hours table, footer line, the "Open today" badge and the Google listing data update from it.

- **Hours**: `days` uses numbers, 0 = Sunday … 6 = Saturday.
- **Email**: empty on purpose. Add one and it appears on the page.

## Change text, prices or services

- All page text is in the `T = { en: {...}, es: {...} }` block: English in `en`, Spanish in `es`, same key names.
- Services and prices are in the `data` block. Their Spanish versions are in `T.es.services`, **in the same order**. If you add a service to one, add it to the other at the same position. Prices with words (like "$5 & up") can have a Spanish `price` (e.g. `'Desde $5'`).
- Salon policy lines are `policy.1` … `policy.8`. To add a line, add `policy.9` in both languages and change `POLICY_COUNT`.
- The six Google reviews are in the HTML and stay in English in both languages.

## Language

First visit: an English / Español chooser. After that the EN / ES switch in the header changes the whole page (menu, services, drinks, hours, footer, cookie banner, legal links). The choice is remembered. The Terms, Privacy and Accessibility pages themselves are English only.

## Swapping photos

Keep the same file names, drop the new photo into `images/`, then run:

```bash
cd ~/ventana-nails-spa-richmond && bash optimize-images.sh
```

It saves the original into `images-originals/`, shrinks the photo, writes the `.webp` copy (needs `brew install webp`), and rebuilds the icons. If a gallery photo changes, update its caption (`gallery.label1`…) and description (`gallery.alt1`…) in both languages.

| File | Where it shows |
|---|---|
| `logo.png` | Header, footer, language chooser, icons |
| `gallery-1.jpg` … `gallery-6.jpg` | "Our Work". `gallery-6` is also the big hero photo |
| `service-*.jpg` | Photo beside each services tab (`service-pedicure` is also the small hero photo) |
| `drink-1.jpg` … `drink-32.jpg` | Drinks Menu tab, in menu order |

## Booking

Online booking: https://booking.gocheckin.net/v2/multiple-staff/18329
