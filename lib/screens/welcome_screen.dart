import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../constants/spacing.dart';
import '../constants/custom_app_bar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    try {
      String? deviceId = await PlatformDeviceId.getDeviceId;
      setState(() {
        _deviceId = deviceId;
      });
      if (deviceId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_id', deviceId);

        if (kDebugMode) {
          print('Device ID saved: $deviceId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get device ID: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎬 Movie Night!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Your personalized movie night companion to share with your friend!',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            if (_deviceId != null)
              Text(
                'Device ID: $_deviceId',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/shareCode'),
              child: const Text('Get a Code to Share'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.small,
                  horizontal: AppSpacing.large,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/enterCode'),
              child: const Text('Enter a Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.small,
                  horizontal: AppSpacing.large,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
