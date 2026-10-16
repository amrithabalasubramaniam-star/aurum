import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../widgets.dart';
import 'customer_detail_screen.dart';

class ReservationTile extends StatelessWidget {
  final Map<String, dynamic> r;
  final VoidCallback onChanged;
  final bool showDate;
  const ReservationTile(this.r, {super.key, required this.onChanged, this.showDate = false});

  Future<void> _setStatus(BuildContext context, String status) async {
    try {
      await Api.instance.setStatus(r['id'], status);
      if (context.mounted) snack(context, '${r['code']} marked as ${statusLabels[status]}.');
      onChanged();
    } on ApiException catch (e) {
      if (context.mounted) snack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = (r['notes'] ?? '') as String;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _sheet(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Column(children: [
              Text(r['time'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (showDate) Text((r['date'] as String).substring(5), style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(r['name'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (r['is_vip'] == true) const VipBadge(),
                ]),
                Text('${r['guests']} guests · ${r['seating_area'] ?? '—'}${r['table_number'] != null ? ' · ${r['table_number']}' : ''}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54)),
                if (notes.isNotEmpty)
                  Text('“$notes”', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white38)),
              ]),
            ),
            StatusChip(r['status']),
          ]),
        ),
      ),
    );
  }

  void _sheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${r['code']} · ${r['date']} at ${r['time']} · ${r['guests']} guests', style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 10),
            Text('Seating: ${r['seating_area'] ?? '—'}'),
            Text('Experience: ${r['experience_tier'] ?? '—'}'),
            if ((r['notes'] ?? '').toString().isNotEmpty) Text('Guest notes: ${r['notes']}'),
            if ((r['admin_notes'] ?? '').toString().isNotEmpty) Text('Staff notes: ${r['admin_notes']}'),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(r['phone']),
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: r['phone']))),
              if (r['customer_id'] != null)
                OutlinedButton.icon(
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('Guest profile'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailScreen(r['customer_id'])));
                    }),
            ]),
            const SizedBox(height: 16),
            const Text('SET STATUS', style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.white54)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in statusLabels.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: r['status'] == e.key,
                  onSelected: (_) {
                    Navigator.pop(ctx);
                    if (r['status'] != e.key) _setStatus(context, e.key);
                  },
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}
