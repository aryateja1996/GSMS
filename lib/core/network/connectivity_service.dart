import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:gsma/core/utils/app_logger.dart';

class ConnectivityService extends GetxService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    final results = await _connectivity.checkConnectivity();
    isOnline.value = _hasConnection(results);
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _hasConnection(results);
      AppLogger.info(
        'Connectivity: ${isOnline.value ? "online" : "offline"}',
        tag: 'Connectivity',
      );
    });
    return this;
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
