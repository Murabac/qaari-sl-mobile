# Qaari SL Mobile

Flutter app for the Somali community Quran reciters platform (homeland + diaspora).

UI tracks [`Mobile APP Design Ref`](../Mobile%20APP%20Design%20Ref/) (Nunito / Amiri, forest-gold-cream layouts, featured home, player chrome).

## Features

- Sanctum login / register (token in `flutter_secure_storage`)
- Synced favorites + playlists
- Follow-along Arabic ayah screen
- Language switcher (SO / AR / EN) + share listen links
- Catalog browse + `just_audio` / `audio_service` playback

## Run on a physical phone

### USB tethering (Samsung data → laptop)

If the laptop internet comes from the phone via **USB tethering**:

1. Keep USB tethering on
2. On the PC, run `ipconfig` and find **Ethernet** / `SAMSUNG Mobile USB Remote NDIS` — use that IPv4 (not Wi‑Fi)
3. Start Laravel on all interfaces:

```bash
cd qaari-sl-backend
php artisan serve --host=0.0.0.0 --port=8000
```

4. Rebuild the app with that tether IP (example `10.172.77.244`):

```bash
cd qaari-sl-mobile
flutter run --dart-define=API_BASE_URL=http://10.172.77.244:8000
```

Hot reload does **not** apply a new `--dart-define` — stop and re-run.

### Same Wi‑Fi instead

Phone and PC on the same Wi‑Fi: use the PC’s **Wi‑Fi** IPv4 from `ipconfig`, same `artisan serve --host=0.0.0.0` command.

The default `http://10.0.2.2:8000` only works inside the Android emulator.

## Auth

- Register / login via Settings (or when saving a favorite / playlist)
- Bearer token attached to Dio automatically; cleared on logout or HTTP 401
- Favorites and playlists require an account (no offline guest library)

## API used

Public:

- `GET /api/v1/reciters`
- `GET /api/v1/reciters/{id}`
- `GET /api/v1/recitations/{id}/follow-along`

Authenticated (Sanctum):

- `POST /api/v1/auth/login|register` · `POST /auth/logout` · `GET /auth/me`
- `GET|POST|DELETE /api/v1/favorites`
- `GET|POST|PUT|DELETE /api/v1/playlists` (+ items)

Share links use `{WEB_BASE_URL}/listen/{recitationId}`.

## Tests

```bash
flutter test
```
