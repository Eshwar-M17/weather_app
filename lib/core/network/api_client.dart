import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/core/utils/app_error.dart';
import 'package:weather_app/core/utils/app_logger.dart';

/// API request method enum
enum RequestMethod { get, post, put, delete }

/// Callback for handling network responses
typedef ResponseHandler<T> = T Function(dynamic data);

/// API client for making network requests
class ApiClient {
  final http.Client _client;
  final Duration _timeout;
  final int _maxRetries;

  /// Creates an API client
  ApiClient({http.Client? client, Duration? timeout, int maxRetries = 2})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 15),
      _maxRetries = maxRetries;

  /// Make a request to the API with automatic error handling
  Future<T> request<T>({
    required String endpoint,
    required RequestMethod method,
    required ResponseHandler<T> responseHandler,
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool includeApiKey = true,
    bool requiresAuthentication = false,
    String? customBaseUrl,
    int? retryCount,
  }) async {
    retryCount ??= 0;
    final baseUrl = customBaseUrl ?? AppConstants.baseUrl;
    final uri = _buildUri(baseUrl, endpoint, queryParams, includeApiKey);

    final requestHeaders = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    appLogger.d('ApiClient: ${method.name.toUpperCase()} request to $uri');

    try {
      final http.Response response;

      switch (method) {
        case RequestMethod.get:
          response = await _client
              .get(uri, headers: requestHeaders)
              .timeout(_timeout);
          break;
        case RequestMethod.post:
          response = await _client
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case RequestMethod.put:
          response = await _client
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
        case RequestMethod.delete:
          response = await _client
              .delete(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
          break;
      }

      return _handleResponse(
        response: response,
        responseHandler: responseHandler,
        endpoint: endpoint,
        method: method,
        retryCount: retryCount,
        queryParams: queryParams,
        body: body,
        headers: headers,
        includeApiKey: includeApiKey,
        requiresAuthentication: requiresAuthentication,
      );
    } on SocketException catch (_) {
      appLogger.e('ApiClient: No internet connection');
      throw const NetworkError(message: 'No internet connection');
    } on TimeoutException catch (_) {
      appLogger.e(
        'ApiClient: Request timed out after ${_timeout.inSeconds} seconds',
      );

      // Retry if we haven't exceeded max retries
      if (retryCount < _maxRetries) {
        appLogger.i(
          'ApiClient: Retrying request (${retryCount + 1}/$_maxRetries)',
        );
        return request<T>(
          endpoint: endpoint,
          method: method,
          responseHandler: responseHandler,
          queryParams: queryParams,
          body: body,
          headers: headers,
          includeApiKey: includeApiKey,
          requiresAuthentication: requiresAuthentication,
          retryCount: retryCount + 1,
        );
      }

      throw const NetworkError(message: 'Request timed out. Please try again.');
    } catch (e, stackTrace) {
      appLogger.e('ApiClient: Unexpected error', e, stackTrace);

      // Retry if we haven't exceeded max retries and it's not a permanent error
      if (retryCount < _maxRetries) {
        appLogger.i(
          'ApiClient: Retrying request (${retryCount + 1}/$_maxRetries)',
        );
        return request<T>(
          endpoint: endpoint,
          method: method,
          responseHandler: responseHandler,
          queryParams: queryParams,
          body: body,
          headers: headers,
          includeApiKey: includeApiKey,
          requiresAuthentication: requiresAuthentication,
          retryCount: retryCount + 1,
        );
      }

      throw ServerError(
        message: 'Unexpected error occurred: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles the HTTP response with appropriate error handling
  Future<T> _handleResponse<T>({
    required http.Response response,
    required ResponseHandler<T> responseHandler,
    required String endpoint,
    required RequestMethod method,
    required int retryCount,
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool includeApiKey = true,
    bool requiresAuthentication = false,
  }) async {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    appLogger.d('ApiClient: Response status code: $statusCode');

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      try {
        final dynamic data =
            responseBody.isEmpty ? {} : json.decode(responseBody);
        return responseHandler(data);
      } catch (e, stackTrace) {
        appLogger.e('ApiClient: Error parsing response data', e, stackTrace);
        throw ServerError(
          message: 'Failed to parse response data: ${e.toString()}',
          stackTrace: stackTrace,
        );
      }
    } else if (statusCode == 401) {
      appLogger.e('ApiClient: API key error - 401 Unauthorized');
      throw ServerError(
        message:
            'Invalid API key or unauthorized access. Please check your API key.',
      );
    } else if (statusCode == 404) {
      final errorMsg = 'Resource not found: $endpoint';
      appLogger.w('ApiClient: $errorMsg');

      // For weather API, 404 usually means city not found
      if (endpoint.contains('weather') || endpoint.contains('forecast')) {
        final cityParam = queryParams?['q'] ?? 'Unknown';
        throw CityNotFoundError(message: 'City not found: $cityParam');
      }

      throw ServerError(message: errorMsg);
    } else if (statusCode >= 500) {
      appLogger.e('ApiClient: Server error: $statusCode, body: $responseBody');

      // Retry server errors if we haven't exceeded max retries
      if (retryCount < _maxRetries) {
        appLogger.i(
          'ApiClient: Retrying request (${retryCount + 1}/$_maxRetries)',
        );
        return request<T>(
          endpoint: endpoint,
          method: method,
          responseHandler: responseHandler,
          queryParams: queryParams,
          body: body,
          headers: headers,
          includeApiKey: includeApiKey,
          requiresAuthentication: requiresAuthentication,
          retryCount: retryCount + 1,
        );
      }

      throw ServerError(
        message: 'Server error occurred. Status code: $statusCode',
      );
    } else {
      appLogger.e(
        'ApiClient: Request failed: $statusCode, body: $responseBody',
      );
      throw ServerError(
        message: 'Request failed with status code: $statusCode',
      );
    }
  }

  /// Build URI with API key and query parameters
  Uri _buildUri(
    String baseUrl,
    String endpoint,
    Map<String, String>? queryParams,
    bool includeApiKey,
  ) {
    // Ensure endpoint doesn't start with slash if baseUrl ends with slash
    if (baseUrl.endsWith('/') && endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    // Ensure there is a slash between baseUrl and endpoint if needed
    if (!baseUrl.endsWith('/') && !endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    final fullUrl = '$baseUrl$endpoint';
    final uri = Uri.parse(fullUrl);

    final Map<String, String> allParams = {};

    // Add API key if needed
    if (includeApiKey) {
      allParams['appid'] = AppConstants.apiKey;
      allParams['units'] = AppConstants.metric;
    }

    // Add any additional query parameters
    if (queryParams != null) {
      allParams.addAll(queryParams);
    }

    return uri.replace(queryParameters: allParams);
  }
}
