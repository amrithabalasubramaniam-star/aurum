/// Change this to your server address before building the APK.
///  - Android emulator talking to `php artisan serve` on your PC: http://10.0.2.2:8000
///  - Real phone on the same Wi-Fi: http://YOUR-PC-LAN-IP:8000 (run: php artisan serve --host=0.0.0.0)
///  - Production: https://yourrestaurant.com
const String kBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8000');
const String kAppName = 'AURUM';
