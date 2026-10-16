import 'package:flutter/material.dart';
import '../api.dart';
import '../main.dart';
import 'customers_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _titles = const ['Today', 'Reservations', 'Guests'];

  Future<void> _logout() async {
    await Api.instance.logout();
    if (!mounted) return;
    navKey.currentState!.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
              tooltip: 'Log out',
              icon: const Icon(Icons.logout),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Log out?'),
                        content: Text('Signed in as ${Api.instance.userName ?? 'admin'}.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _logout();
                              },
                              child: const Text('Log out')),
                        ],
                      ))),
        ],
      ),
      // IndexedStack keeps each tab's scroll position and loaded data
      body: IndexedStack(index: _tab, children: const [DashboardScreen(), ReservationsScreen(), CustomersScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.event_seat_outlined), selectedIcon: Icon(Icons.event_seat), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Guests'),
        ],
      ),
    );
  }
}
