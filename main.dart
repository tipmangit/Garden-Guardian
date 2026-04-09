import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

void main() {
  runApp(const GardenGuardianApp());
}

class GardenGuardianApp extends StatelessWidget {
  const GardenGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Your exact ESP32-CAM stream URL
  final String streamUrl = 'http://192.168.100.163:81/stream';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Guardian'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Camera Feed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- LIVE VIDEO FEED ---
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Mjpeg(
                isLive: true,
                stream: streamUrl,
                error: (context, error, stack) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white54, size: 60),
                      SizedBox(height: 12),
                      Text(
                          'Stream Disconnected',
                          style: TextStyle(color: Colors.white54)
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // --- CONTROLS SECTION ---
            const Text(
              'Hardware Controls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Sprinkler Button (Placeholder)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add HTTP request to trigger sprinkler
                    print("Sprinkler toggled");
                  },
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Sprinkler'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                // Camera Pan/Tilt Button (Placeholder)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add HTTP request to move servos
                    print("Pan/Tilt controls opened");
                  },
                  icon: const Icon(Icons.control_camera),
                  label: const Text('Pan / Tilt'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}