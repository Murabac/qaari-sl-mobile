## Upload to Play Console
Use the **`play-*.png`** files (1080×2316):

1. `play-01-home.png`
2. `play-02-reciter.png`
3. `play-03-follow-along.png`
4. `play-04-playlists.png`
5. `play-05-favorites.png`
6. `play-06-settings.png`

Native captures are also saved without the `play-` prefix (720×1544).

## Specs
- PNG or JPEG, up to 8 MB each
- Aspect 9:16 (portrait) preferred
- Each side between 320 px and 3,840 px
- For promotion: at least **4** screenshots with **≥1080 px** on each side
- These `play-*.png` files meet the ≥1080 promotion size

## Capture (Android emulator / phone)

1. Authorize USB debugging, or use emulator `Pixel_8_Pro`
2. From `qaari-sl-mobile`:
   ```bash
   flutter run --release -d <deviceId>
   ```
3. Walk through and capture:
   - `01-home.png` — Featured + All Reciters
   - `02-reciter.png` — Reciter detail with surah list
   - `03-follow-along.png` — Follow-along ayah view
   - `04-playlists.png` — Playlists
   - `05-favorites.png` — Favorites
   - `06-settings.png` — Settings / language
4. Save into this folder: `store-listing/screenshots/`
5. Upload 4–8 to Play Console → Main store listing → Phone screenshots

## ADB one-liner

```bash
adb exec-out screencap -p > store-listing/screenshots/01-home.png
```

Repeat after navigating each screen.
