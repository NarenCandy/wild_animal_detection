import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mjpeg_stream/mjpeg_stream.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../api/api_service.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  bool _isRunning = false;
  bool _cameraRunning = false;
  bool _loading = false;
  // Fetch from environment or use ip address and different port
  final String _cameraFeedUrl = dotenv.env['CAMERA_STREAM_URL'] ??
      'http://192.168.29.223:8001/video_feed';

  Future<void> _toggleServer() async {
    setState(() => _loading = true);

    final token = await ApiService.getToken();
    if (token == null) {
      _showSnack("⚠️ Not logged in");
      setState(() => _loading = false);
      return;
    }

    final endpoint = _isRunning ? "stop" : "start";
    final url = Uri.parse("${ApiService.baseUrl}/server/$endpoint");

    try {
      final response =
          await http.post(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        setState(() => _isRunning = !_isRunning);
        _showSnack(_isRunning ? "🚀 Server started" : "🛑 Server stopped");
      } else {
        _showSnack("❌ Error: ${response.body}");
      }
    } catch (e) {
      _showSnack("⚠️ Failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleCamera() async {
    setState(() => _loading = true);

    final token = await ApiService.getToken();
    if (token == null) {
      _showSnack("⚠️ Not logged in");
      setState(() => _loading = false);
      return;
    }

    final endpoint = _cameraRunning ? "stop-camera" : "start-camera";
    final url = Uri.parse("${ApiService.baseUrl}/server/$endpoint");

    try {
      final response =
          await http.post(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        setState(() => _cameraRunning = !_cameraRunning);
        _showSnack(_cameraRunning
            ? "📷 Camera stream started"
            : "🛑 Camera stream stopped");
      } else {
        _showSnack("❌ Error: ${response.body}");
      }
    } catch (e) {
      _showSnack("⚠️ Failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Server Control & Live Feed"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 20),
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
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isRunning ? "Stop Server" : "Start Server",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _toggleCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cameraRunning ? Colors.red : Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _cameraRunning ? "Stop Camera" : "Start Camera",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            if (_cameraRunning)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MJPEGStreamScreen(
                    streamUrl: _cameraFeedUrl,
                    width: double.infinity,
                    height: 300.0,
                    fit: BoxFit.cover,
                    showLiveIcon: true,
                    timeout: const Duration(seconds: 5),
                  ),
                ),
              )
            else
              const Center(
                child: Text(
                  "Start the camera to view the live feed.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
