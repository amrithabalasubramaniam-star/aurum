import 'package:flutter/material.dart';
import 'main.dart';

const statusColors = {
  'pending': Color(0xFFE0A63A),
  'confirmed': Color(0xFF4C8FD9),
  'seated': goldLight,
  'completed': Color(0xFF4CAF7A),
  'cancelled': Color(0xFFD9534F),
  'no_show': Color(0xFFD9534F),
};

const statusLabels = {
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'seated': 'Seated',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
  'no_show': 'No-show',
};

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: c), borderRadius: BorderRadius.circular(99)),
      child: Text(statusLabels[status] ?? status, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class VipBadge extends StatelessWidget {
  const VipBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(4)),
        child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}

void snack(BuildContext c, String msg, {bool error = false}) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: error ? const Color(0xFF8B2E2B) : const Color(0xFF2D5B42)));
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView(this.message, this.onRetry, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 44, color: Colors.white38),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ]),
        ),
      );
}
