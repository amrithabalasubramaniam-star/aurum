import 'package:flutter/material.dart';
import 'api.dart';
import 'config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

final navKey = GlobalKey<NavigatorState>();

const gold = Color(0xFFC9A24B);
const goldLight = Color(0xFFE2C177);
const bg = Color(0xFF0D0C0A);
const panel = Color(0xFF171512);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AurumApp());
}

class AurumApp extends StatefulWidget {
  const AurumApp({super.key});
  @override
  State<AurumApp> createState() => _AurumAppState();
}

class _AurumAppState extends State<AurumApp> {
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    Api.instance.onUnauthorized = () => navKey.currentState
        ?.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    Api.instance.loadSession().then((v) => setState(() => _loggedIn = v));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: '$kAppName Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(primary: gold, secondary: goldLight, surface: panel),
        cardTheme: CardTheme(
          color: panel,
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2D2922))),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: goldLight, elevation: 0),
        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: panel, indicatorColor: gold.withOpacity(.2)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF100E0B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF16130D))),
      ),
      home: _loggedIn == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _loggedIn!
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
