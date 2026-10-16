import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../main.dart';
import '../widgets.dart';
import 'reservation_tile.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;
  const CustomerDetailScreen(this.id, {super.key});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic>? _c;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Api.instance.customer(widget.id);
      if (mounted) setState(() { _c = d; _error = null; });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Widget _row(String k, String? v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(color: Colors.white54))),
          Expanded(child: Text((v == null || v.isEmpty) ? '—' : v)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      appBar: AppBar(title: Row(children: [Flexible(child: Text(c?['name'] ?? 'Guest', overflow: TextOverflow.ellipsis)), if (c?['is_vip'] == true) const VipBadge()])),
      body: _error != null && c == null
          ? ErrorView(_error!, _load)
          : c == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(padding: const EdgeInsets.all(14), children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _row('Email', c['email']),
                          _row('Phone', c['phone']),
                          _row('Birthday', c['birthday']),
                          _row('Dietary', c['dietary_notes']),
                          _row('Tags', (c['tags'] as List).join(', ')),
                          _row('Offers', c['marketing_opt_in'] == true ? 'Opted in' : 'Not opted in'),
                          _row('Notes', c['notes']),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, children: [
                            if ((c['phone'] ?? '').toString().isNotEmpty)
                              OutlinedButton.icon(icon: const Icon(Icons.call, size: 18), label: const Text('Call'), onPressed: () => launchUrl(Uri(scheme: 'tel', path: c['phone']))),
                            OutlinedButton.icon(icon: const Icon(Icons.email, size: 18), label: const Text('Email'), onPressed: () => launchUrl(Uri(scheme: 'mailto', path: c['email']))),
                          ]),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('RESERVATION HISTORY (${c['bookings']})', style: const TextStyle(color: gold, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                    for (final r in (c['reservations'] as List).cast<Map<String, dynamic>>()) ReservationTile(r, showDate: true, onChanged: _load),
                  ]),
                ),
    );
  }
}
