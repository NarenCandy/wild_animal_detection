import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/alerts.dart';
import '../widgets/alert_card.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Alert> _alerts = [];
  bool _isLoading = false;
  bool _fetchedOnce = false;

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _fetchedOnce = true;
    });
    final data = await ApiService.getAlerts();
    setState(() {
      _alerts = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Alerts"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : !_fetchedOnce
                ? ElevatedButton.icon(
                    onPressed: _fetchAlerts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      "Load Alerts",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : _alerts.isEmpty
                    ? const Text("No alerts found")
                    : RefreshIndicator(
                        onRefresh: _fetchAlerts,
                        child: ListView.builder(
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) {
                            return AlertCard(alert: _alerts[index]); // ✅
                          },
                        ),
                      ),
      ),
    );
  }
}
