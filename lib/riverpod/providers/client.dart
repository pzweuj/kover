import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/riverpod/providers/settings/credentials.dart';
import 'package:kover/widgets/util/network_switch_listener.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

ChopperClient getChopperClient(
  Uri uri,
  String apiKey, {
  Uri? fallbackUri,
  void Function(String from, String to)? onFallback,
}) {
  return ChopperClient(
    baseUrl: uri,
    client: FallbackHttpClient(
      primaryBaseUrl: uri,
      fallbackBaseUrl: fallbackUri,
      onFallback: onFallback,
    ),
    interceptors: [
      HeadersInterceptor({
        'x-api-key': apiKey,
        "Content-Type": "application/json",
      }),
    ],
    converter: $JsonSerializableConverter(),
  );
}

class FallbackHttpClient extends http.BaseClient {
  final Uri primaryBaseUrl;
  final Uri? fallbackBaseUrl;
  final Duration primaryTimeout;
  final http.Client _inner;
  final void Function(String from, String to)? onFallback;

  /// Whether currently using fallback URL.
  bool _switchedToFallback = false;

  /// Periodic timer for probing primary network recovery.
  Timer? _recoveryTimer;

  /// How often to probe whether primary is back.
  static const _recoveryInterval = Duration(minutes: 15);

  FallbackHttpClient({
    required this.primaryBaseUrl,
    this.fallbackBaseUrl,
    this.primaryTimeout = const Duration(seconds: 8),
    this.onFallback,
    http.Client? inner,
  }) : _inner = inner ?? http.Client() {
    if (fallbackBaseUrl != null) {
      _recoveryTimer = Timer.periodic(_recoveryInterval, (_) => _probePrimary());
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final fallbackBaseUrl = this.fallbackBaseUrl;

    // Already switched to fallback — use it directly, no retry of primary.
    if (_switchedToFallback && fallbackBaseUrl != null) {
      final fallbackRequest = _copyRequest(
        request,
        _replaceBaseUrl(request.url, from: primaryBaseUrl, to: fallbackBaseUrl),
      );
      return _inner.send(fallbackRequest ?? request);
    }

    // No fallback configured — just send normally.
    if (fallbackBaseUrl == null) {
      return _inner.send(request);
    }

    // Try primary with timeout; on failure, switch to fallback permanently.
    try {
      final response = await _inner.send(request).timeout(primaryTimeout);
      if (_shouldRetryStatus(response.statusCode)) {
        await response.stream.drain<void>();
        _switchToFallback(request, fallbackBaseUrl);
        return _sendFallback(request, fallbackBaseUrl);
      }
      return response;
    } catch (_) {
      _switchToFallback(request, fallbackBaseUrl);
      return _sendFallback(request, fallbackBaseUrl);
    }
  }

  void _switchToFallback(http.BaseRequest request, Uri fallbackBaseUrl) {
    _switchedToFallback = true;
    onFallback?.call(primaryBaseUrl.host, fallbackBaseUrl.host);
  }

  Future<http.StreamedResponse> _sendFallback(
    http.BaseRequest request,
    Uri fallbackBaseUrl,
  ) {
    final fallbackRequest = _copyRequest(
      request,
      _replaceBaseUrl(request.url, from: primaryBaseUrl, to: fallbackBaseUrl),
    );
    return _inner.send(fallbackRequest ?? request);
  }

  /// Silently probe whether primary is reachable again.
  /// If yes, switch back to primary and notify.
  Future<void> _probePrimary() async {
    if (!_switchedToFallback) return;

    try {
      final probeUri = primaryBaseUrl.replace(path: '${primaryBaseUrl.path}/api/health');
      final response = await _inner
          .head(probeUri)
          .timeout(primaryTimeout);
      if (!_shouldRetryStatus(response.statusCode)) {
        // Primary is back!
        _switchedToFallback = false;
        onFallback?.call(fallbackBaseUrl!.host, primaryBaseUrl.host);
      }
    } catch (_) {
      // Primary still down, stay on fallback.
    }
  }

  @override
  void close() {
    _recoveryTimer?.cancel();
    _inner.close();
    super.close();
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == 408 || statusCode >= 500;
  }

  Uri _replaceBaseUrl(Uri uri, {required Uri from, required Uri to}) {
    final relativePath = _relativePath(uri.path, from.path);
    final fallbackPath = _joinPaths(to.path, relativePath);

    return to.replace(
      path: fallbackPath,
      query: uri.query.isEmpty ? null : uri.query,
      fragment: uri.fragment.isEmpty ? null : uri.fragment,
    );
  }

  String _relativePath(String path, String basePath) {
    if (basePath.isEmpty || basePath == '/') return path;
    if (path == basePath) return '';
    if (path.startsWith('$basePath/')) return path.substring(basePath.length);
    return path;
  }

  String _joinPaths(String basePath, String relativePath) {
    if (basePath.isEmpty || basePath == '/') {
      return relativePath.startsWith('/') ? relativePath : '/$relativePath';
    }
    if (relativePath.isEmpty) return basePath;
    if (basePath.endsWith('/') && relativePath.startsWith('/')) {
      return '${basePath.substring(0, basePath.length - 1)}$relativePath';
    }
    if (!basePath.endsWith('/') && !relativePath.startsWith('/')) {
      return '$basePath/$relativePath';
    }
    return '$basePath$relativePath';
  }

  http.BaseRequest? _copyRequest(http.BaseRequest request, Uri uri) {
    if (request is! http.Request) return null;

    final copy = http.Request(request.method, uri)
      ..bodyBytes = request.bodyBytes
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;
    copy.headers.addAll(request.headers);

    return copy;
  }
}

@Riverpod(keepAlive: true)
ChopperClient authenticatedClient(Ref ref) {
  final settings = ref.watch(credentialsProvider).value;
  final key = ref.watch(apiKeyProvider);

  if (settings?.url == null || settings?.apiKey == null) {
    throw Exception('Credentials not set in settings');
  }

  final uri = Uri.tryParse(settings!.url!.trim());
  if (uri == null || !_isValidBaseUri(uri)) {
    throw Exception('Invalid URL in settings');
  }

  final fallbackUrl = settings.fallbackUrl?.trim();
  final fallbackUri = fallbackUrl == null || fallbackUrl.isEmpty
      ? null
      : Uri.tryParse(fallbackUrl);

  if (fallbackUrl != null &&
      fallbackUrl.isNotEmpty &&
      (fallbackUri == null || !_isValidBaseUri(fallbackUri))) {
    throw Exception('Invalid fallback URL in settings');
  }

  final client = getChopperClient(
    uri,
    key!,
    fallbackUri: fallbackUri,
    onFallback: (from, to) {
      NetworkSwitchNotifier.instance.notify(from, to);
    },
  );

  return client;
}

@Riverpod(keepAlive: true)
Openapi restClient(Ref ref) {
  final client = ref.watch(authenticatedClientProvider);
  return Openapi.create(client: client);
}

bool _isValidBaseUri(Uri uri) {
  return uri.scheme.isNotEmpty && uri.host.isNotEmpty;
}
