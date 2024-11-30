import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/custom_app_bar.dart';
import '../constants/spacing.dart';

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  _ShareCodeScreenState createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen> {
  String? _deviceId;
  String? _sessionCode;
  String? _sessionId;
  bool _isLoading = true; // State to manage loading

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');
      if (deviceId != null) {
        setState(() {
          _deviceId = deviceId;
        });
        await _startSession(deviceId);
      } else {
        if (kDebugMode) {
          print('Device ID not found in SharedPreferences');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading device ID: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startSession(String deviceId) async {
    final url =
        'https://movie-night-api.onrender.com/start-session?device_id=$deviceId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'];
        final code = responseData['code'];
        final sessionId = responseData['session_id'];

        // Save the session ID in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);

        setState(() {
          _sessionCode = code;
          _sessionId = sessionId;
        });
      } else {
        if (kDebugMode) {
          print('Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to start session: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Share Code'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : _sessionCode == null
                  ? const Text(
                      'Failed to generate session code. Please try again.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Your Session Code:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _sessionCode!,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          'Session ID: $_sessionId',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6)),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        ElevatedButton(
                          onPressed: () {
                            if (_sessionId != null && _deviceId != null) {
                              Navigator.pushNamed(context, '/movieSelection');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Session ID or Device ID is missing. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.small,
                              horizontal: AppSpacing.large,
                            ),
                          ),
                          child: const Text('Start Matching'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
