import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/features/weather_dashboard/presentation/providers/weather_providers.dart';

/// Weather search bar widget
class WeatherSearchBar extends ConsumerStatefulWidget {
  /// Text controller for the search field
  final TextEditingController controller;

  /// Callback when search is submitted
  final Function(String) onSubmitted;

  /// Creates a WeatherSearchBar widget
  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  ConsumerState<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends ConsumerState<WeatherSearchBar> {
  bool _showClearButton = false;
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = widget.controller.text.isNotEmpty;
    });
  }

  Future<void> _handleSubmitted(String value) async {
    if (value.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Check if we're online before initiating search
    final repo = ref.read(weatherRepositoryProvider);
    final isOnline = await repo.isConnected();

    if (!isOnline) {
      // Check if we have cached data for this specific city
      final hasCachedData = await repo.hasCachedWeatherDataForCity(
        value.trim(),
      );

      if (!hasCachedData) {
        // If city has no cached data and we're offline, show a snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You\'re offline. Only cities with cached data are available.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        setState(() {
          _isSearching = false;
        });
        return;
      }

      appLogger.i(
        'Found cached data for ${value.trim()}, proceeding with offline search',
      );
    }

    // Submit the search
    widget.onSubmitted(value);
    _focusNode.unfocus();

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onSubmitted: _handleSubmitted,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for a city',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            prefixIcon:
                _isSearching
                    ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    )
                    : const Icon(Icons.search, color: Colors.white),
            suffixIcon:
                _showClearButton
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        widget.controller.clear();
                        _focusNode.requestFocus();
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
