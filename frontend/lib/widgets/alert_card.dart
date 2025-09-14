import 'package:flutter/material.dart';
import 'package:frontend/pages/alert_detail.dart';
import '../models/alerts.dart';
// ✅ Import this

class AlertCard extends StatelessWidget {
  final Alert alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlertDetailPage(alert: alert),
            ),
          );
        },
        child: ListTile(
          leading: Image.network(
            alert.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text(alert.animal.toUpperCase()),
          subtitle: Text(alert.timestamp),
        ),
      ),
    );
  }
}
