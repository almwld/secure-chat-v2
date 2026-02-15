import 'dart:io';
import 'dart:async';

class NetworkMonitor {
  Future<bool> checkTunnelHealth() async {
    try {
      // محاولة فحص الوصول لـ DNS جوجل عبر المنفذ 53
      final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
