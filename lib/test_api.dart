import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/core/constants/app_constants.dart';

/// Simple test widget to verify API connectivity
class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _result = 'Press the button to test API';
  bool _isLoading = false;

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing API connection...';
    });

    try {
      // Build the URL using the same constants as the app
      final url =
          '${AppConstants.baseUrl}/weather?q=London&units=${AppConstants.metric}&appid=${AppConstants.apiKey}';

      setState(() {
        _result = 'Requesting: $url';
      });

      // Make the API call
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _result =
              'SUCCESS!\nStatus: ${response.statusCode}\nCity: ${data['name']}\nTemp: ${data['main']['temp']}°C\nCondition: ${data['weather'][0]['main']}';
        });
      } else {
        setState(() {
          _result =
              'ERROR\nStatus: ${response.statusCode}\nBody: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Constants info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Constants:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Base URL: ${AppConstants.baseUrl}'),
                    Text('API Key: ${AppConstants.apiKey.substring(0, 5)}...'),
                    Text('Metric Unit: ${AppConstants.metric}'),
                    Text('Default City: ${AppConstants.defaultCity}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Test button
            ElevatedButton(
              onPressed: _isLoading ? null : _testApi,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Test OpenWeather API'),
            ),
            const SizedBox(height: 20),

            // Results display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
