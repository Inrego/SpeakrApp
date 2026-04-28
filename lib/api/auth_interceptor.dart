import 'package:dio/dio.dart';

import '../services/credentials_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._creds);

  final CredentialsStore _creds;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final c = await _creds.read();
    if (c != null) {
      // Always rewrite the base URL — secure storage is the source of truth.
      // Set extra['useRootApi'] = true on a request to hit /api/* directly,
      // bypassing the /api/v1 prefix (used by the unofficial detail endpoint).
      final useRoot = options.extra['useRootApi'] == true;
      options.baseUrl = '${c.baseUrl}/api${useRoot ? '' : '/v1'}';
      options.headers['X-API-Token'] = c.token;
      options.headers['Authorization'] = 'Bearer ${c.token}';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }
}
