import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalLocatorScreen extends StatefulWidget {
  const HospitalLocatorScreen({super.key});

  @override
  State<HospitalLocatorScreen> createState() => _HospitalLocatorScreenState();
}

class _HospitalLocatorScreenState extends State<HospitalLocatorScreen> {
  bool loading = false;
  String message = "Find hospitals near your location";

  Future<void> findHospitals() async {
    setState(() {
      loading = true;
      message = "Getting your location...";
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          loading = false;
          message = "Please enable location services.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          loading = false;
          message = "Location permission was not granted.";
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final url = Uri.parse(
        "https://www.google.com/maps/search/hospitals/"
        "@${position.latitude},${position.longitude},14z",
      );

      await launchUrl(url, mode: LaunchMode.externalApplication);

      setState(() {
        loading = false;
        message = "Nearby hospitals opened in Maps.";
      });
    } catch (e) {
      setState(() {
        loading = false;
        message = "Unable to get location.";
      });
    }
  }

  Future<void> openEmergencySearch() async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/emergency+hospital/",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Locator"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.local_hospital, size: 90, color: Colors.teal),

            const SizedBox(height: 25),

            const Text(
              "Find Nearby Hospitals",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : findHospitals,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_on),

                label: Text(
                  loading ? "Finding Hospitals..." : "Find Nearby Hospitals",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: openEmergencySearch,
                icon: const Icon(Icons.emergency),
                label: const Text("Emergency Hospitals"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
