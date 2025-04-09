import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/features/weather_dashboard/domain/entities/weather.dart';
import 'package:weather_app/features/weather_dashboard/presentation/pages/recent_searches_page.dart';
import 'package:weather_app/features/weather_dashboard/presentation/pages/weather_dashboard_page.dart';
import 'package:weather_app/features/weather_dashboard/presentation/pages/weather_details_page.dart';

/// Router configuration for the app
class AppRouter {
  // Private constructor
  AppRouter._();

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.home,
    routes: [
      // Weather Dashboard page
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WeatherDashboardPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),

      // Recent Searches page
      GoRoute(
        path: AppRoutes.recentSearches,
        name: 'recentSearches',
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RecentSearchesPage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
      ),

      // Weather Details page
      GoRoute(
        path: AppRoutes.weatherDetails,
        name: 'weatherDetails',
        pageBuilder: (context, state) {
          // Get city name from parameters, or use weather object passed as extra
          final cityName = state.uri.queryParameters['city'];
          final Weather? weather = state.extra as Weather?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: WeatherDetailsPage(
              weather: weather,
              cityName: cityName ?? AppConstants.defaultCity,
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
    ],

    // Error Page - shown for invalid routes
    errorPageBuilder:
        (context, state) => MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Oops! The page you are looking for does not exist.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => GoRouter.of(context).go(AppRoutes.home),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
