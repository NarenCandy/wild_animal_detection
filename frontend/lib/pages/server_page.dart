import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  bool _isRunning = false;
  bool _loading = false;

  Future<void> _toggleServer() async {
    setState(() {
      _loading = true;
    });

    final token = await ApiService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Not logged in")),
      );
      setState(() => _loading = false);
      return;
    }

    final endpoint = _isRunning ? "stop" : "start";
    final url = Uri.parse("${ApiService.baseUrl}/server/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isRunning = !_isRunning;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(_isRunning ? "🚀 Server started" : "🛑 Server stopped"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Server Control"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRunning ? Icons.check_circle : Icons.stop_circle,
              size: 100,
              color: _isRunning ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isRunning ? "Server is Running" : "Server is Stopped",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loading ? null : _toggleServer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning ? Colors.red : Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isRunning ? "Stop Server" : "Start Server",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
