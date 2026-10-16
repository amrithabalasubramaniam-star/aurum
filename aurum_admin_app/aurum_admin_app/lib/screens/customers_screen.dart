import 'dart:async';
import 'package:flutter/material.dart';
import '../api.dart';
import '../main.dart';
import '../widgets.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final List<Map<String, dynamic>> _items = [];
  final _scroll = ScrollController();
  Timer? _debounce;
  String _q = '';
  bool _vip = false;
  int _page = 1, _last = 1;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300 && _page < _last && !_loading) {
        _page++;
        _fetch();
      }
    });
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    _page = 1;
    _items.clear();
    await _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Api.instance.customers(q: _q, vip: _vip, page: _page);
      _last = res['last_page'];
      _items.addAll((res['data'] as List).cast<Map<String, dynamic>>());
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(hintText: 'Search guests, tags, phone', prefixIcon: Icon(Icons.search), isDense: true),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () { _q = v; _reload(); });
              },
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(label: const Text('VIP'), selected: _vip, onSelected: (v) { _vip = v; _reload(); }),
        ]),
      ),
      Expanded(
        child: _error != null && _items.isEmpty
            ? ErrorView(_error!, _reload)
            : RefreshIndicator(
                onRefresh: _reload,
                child: ListView(controller: _scroll, padding: const EdgeInsets.all(14), children: [
                  if (_items.isEmpty && !_loading) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No guests found.', style: TextStyle(color: Colors.white54)))),
                  for (final c in _items)
                    Card(
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailScreen(c['id']))),
                        leading: CircleAvatar(backgroundColor: gold.withOpacity(.2), child: Text((c['name'] as String).isEmpty ? '?' : (c['name'] as String)[0].toUpperCase(), style: const TextStyle(color: goldLight))),
                        title: Row(children: [Flexible(child: Text(c['name'], overflow: TextOverflow.ellipsis)), if (c['is_vip'] == true) const VipBadge()]),
                        subtitle: Text('${c['email']}${(c['dietary_notes'] ?? '').toString().isNotEmpty ? '\n⚠ ${c['dietary_notes']}' : ''}'),
                        isThreeLine: (c['dietary_notes'] ?? '').toString().isNotEmpty,
                        trailing: Text('${c['bookings'] ?? 0}\nvisits', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ),
                    ),
                  if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                ]),
              ),
      ),
    ]);
  }
}
