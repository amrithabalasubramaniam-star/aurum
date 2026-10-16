import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api.dart';
import '../widgets.dart';
import 'reservation_tile.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});
  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final List<Map<String, dynamic>> _items = [];
  final _scroll = ScrollController();
  Timer? _debounce;
  String _q = '', _status = '', _date = '';
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
      final res = await Api.instance.reservations(q: _q, status: _status, date: _date, page: _page);
      _last = res['last_page'];
      _items.addAll((res['data'] as List).cast<Map<String, dynamic>>());
    } on ApiException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2035));
    if (d != null) {
      _date = DateFormat('yyyy-MM-dd').format(d);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: TextField(
          decoration: const InputDecoration(hintText: 'Search name, phone, email or code', prefixIcon: Icon(Icons.search), isDense: true),
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), () { _q = v; _reload(); });
          },
        ),
      ),
      SizedBox(
        height: 46,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_date.isEmpty ? 'Any date' : _date),
                  onPressed: _pickDate)),
          if (_date.isNotEmpty)
            Padding(padding: const EdgeInsets.only(right: 6), child: ActionChip(label: const Text('✕ date'), onPressed: () { _date = ''; _reload(); })),
          for (final e in {'': 'All', ...statusLabels}.entries)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(label: Text(e.value), selected: _status == e.key, onSelected: (_) { _status = e.key; _reload(); }),
            ),
        ]),
      ),
      Expanded(
        child: _error != null && _items.isEmpty
            ? ErrorView(_error!, _reload)
            : RefreshIndicator(
                onRefresh: _reload,
                child: ListView(controller: _scroll, padding: const EdgeInsets.all(14), children: [
                  if (_items.isEmpty && !_loading) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No reservations found.', style: TextStyle(color: Colors.white54)))),
                  for (final r in _items) ReservationTile(r, showDate: true, onChanged: _reload),
                  if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                ]),
              ),
      ),
    ]);
  }
}
