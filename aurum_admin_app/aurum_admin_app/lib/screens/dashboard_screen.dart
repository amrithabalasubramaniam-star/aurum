import 'package:flutter/material.dart';
import '../api.dart';
import '../main.dart';
import '../widgets.dart';
import 'reservation_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Api.instance.dashboard();
      if (mounted) setState(() { _data = d; _error = null; });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Widget _stat(String label, dynamic v) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(children: [
              Text('$v', style: const TextStyle(fontSize: 26, color: goldLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_error != null && _data == null) return ErrorView(_error!, _load);
    if (_data == null) return const Center(child: CircularProgressIndicator());
    final s = _data!['stats'] as Map;
    final today = (_data!['today'] as List).cast<Map<String, dynamic>>();
    final pending = (_data!['pending'] as List).cast<Map<String, dynamic>>();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(14), children: [
        Row(children: [_stat('Bookings today', s['today']), _stat('Covers today', s['today_covers']), _stat('Pending', s['pending'])]),
        Row(children: [_stat('Next 7 days', s['upcoming']), _stat('Guests', s['customers']), _stat('VIPs', s['vips'])]),
        const SizedBox(height: 14),
        const Text("TODAY'S SERVICE", style: TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
        if (today.isEmpty) const Padding(padding: EdgeInsets.all(18), child: Text('No reservations today.', style: TextStyle(color: Colors.white54))),
        for (final r in today) ReservationTile(r, onChanged: _load),
        const SizedBox(height: 14),
        const Text('NEEDS CONFIRMATION', style: TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
        if (pending.isEmpty) const Padding(padding: EdgeInsets.all(18), child: Text('Everything is confirmed 🎉', style: TextStyle(color: Colors.white54))),
        for (final r in pending) ReservationTile(r, onChanged: _load, showDate: true),
      ]),
    );
  }
}
