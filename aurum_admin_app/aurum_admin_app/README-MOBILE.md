# AURUM Staff App (Flutter / Dart, Android APK)

Staff app for the AURUM Laravel site: today's service, reservations (search, filter, change status, call guest) and guest CRM profiles. Flutter's Android project uses Kotlin, so no extra Kotlin code is needed.

## A. Backend (Laravel) — one-time
1. Copy the updated `aurum-admin` files (new migration, `app/Http/Controllers/Api/*`, `EnsureApiAdmin`, updated `routes/web.php`).
2. Allow the API to skip CSRF — in `bootstrap/app.php`:
   ```php
   ->withMiddleware(function (Middleware $middleware) {
       $middleware->validateCsrfTokens(except: ['api/v1/*']);
   })
   ```
3. `php artisan migrate`
4. Run the server so your phone can reach it: `php artisan serve --host=0.0.0.0`
   (For a real launch, host the site on HTTPS and use that URL.)

## B. Build the APK (needs Flutter SDK + Android Studio installed)
```bash
flutter create --org com.aurum --project-name aurum_admin aurum_build
cd aurum_build
# copy this package's lib/ folder and pubspec.yaml over the generated ones
flutter pub get
```
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application ... android:usesCleartextTraffic="true">   <!-- only needed for http:// during testing; remove for https -->
```
Build, passing your server address:
```bash
flutter build apk --release --dart-define=BASE_URL=http://192.168.1.50:8000
```
APK output: `build/app/outputs/flutter-apk/app-release.apk` — copy to the phone and install (allow "unknown sources").

Emulator: use `http://10.0.2.2:8000`. Production: `--dart-define=BASE_URL=https://yourdomain.com`.

## Publishing on Google Play
Create a signing key and use `flutter build appbundle --release` (see https://docs.flutter.dev/deployment/android).
Sign in uses the same admin account as the web panel (`ADMIN_EMAIL` / `ADMIN_PASSWORD`).
