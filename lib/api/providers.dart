import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/credentials_store.dart';
import 'auth_interceptor.dart';
import 'speakr_api.dart';

final dioProvider = Provider<Dio>((ref) {
  final creds = ref.watch(credentialsStoreProvider);
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(minutes: 5),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));
  dio.interceptors.add(AuthInterceptor(creds));
  return dio;
});

final speakrApiProvider = Provider<SpeakrApi>((ref) {
  return SpeakrApi(ref.watch(dioProvider));
});
