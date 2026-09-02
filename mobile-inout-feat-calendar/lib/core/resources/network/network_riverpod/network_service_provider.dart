import 'package:dio/dio.dart';
import 'package:flutter_alice/alice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/dio_calendar_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/dio_network_service.dart';
import 'package:mobile_in_out/core/resources/network/network_riverpod/network_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final calendarDioProvider = Provider<Dio>((ref) {
  return Dio();
});

final aliceProvider = Provider<Alice>((ref) {
  return Alice(showNotification: true, showInspectorOnShake: true);
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return DioNetworkService(ref.read(dioProvider), ref.read(aliceProvider));
});

final calendarNetworkServiceProvider = Provider<NetworkService>((ref) {
  return DioCalendarService(
    ref.read(calendarDioProvider),
    ref.read(aliceProvider),
  );
});
