import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/spacing.dart';
import '../constants/custom_app_bar.dart';

class EnterCodeScreen extends StatelessWidget {
  EnterCodeScreen({super.key});

  final TextEditingController _codeController = TextEditingController();

  Future<void> _joinSession(BuildContext context) async {
    final String code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid code.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Device ID not found. Please restart the app.')),
        );
        return;
      }

      final url =
          'https://movie-night-api.onrender.com/join-session?device_id=$deviceId&code=$code';

      if (kDebugMode) {
        print('Request URL: $url');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print('Response Data: $responseData');
        }

        // Access the nested session_id under 'data'
        final sessionData = responseData['data'];
        if (sessionData == null || sessionData['session_id'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Session ID is missing in the response. Please try again.'),
            ),
          );
          return;
        }

        final sessionId = sessionData['session_id'];

        await prefs.setString('session_id', sessionId);

        if (kDebugMode) {
          print('Joined session successfully. Session ID: $sessionId');
        }

        Navigator.pushNamed(context, '/movieSelection');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to join session. Please check the code and try again.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Failed to connect. Please check your network connection.')),
      );
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Enter Code'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the Shared Code:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Shared Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.small),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton(
              onPressed: () => _joinSession(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.small,
                  horizontal: AppSpacing.large,
                ),
              ),
              child: const Text('Begin Matching'),
            ),
          ],
        ),
      ),
    );
  }
}
