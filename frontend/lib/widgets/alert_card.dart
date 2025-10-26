import 'package:flutter/material.dart';
import '../models/alerts.dart';
import '../api/api_service.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onDeleted;

  const AlertCard({super.key, required this.alert, required this.onDeleted});

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Alert?"),
        content: Text("Are you sure you want to delete this alert?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteAlert(alert.id);
      if (success) {
        onDeleted();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Alert deleted")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to delete alert")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(alert.imageUrl,
            width: 50, height: 50, fit: BoxFit.cover),
        title: Text(alert.animal.toUpperCase()),
        subtitle: Text("Detected at: ${alert.timestamp}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }
}
