import 'dart:io';
import 'dart:math';

class DNSHopper {
  // قائمة بأقوى سيرفرات DNS في العالم
  final List<String> _servers = [
    '8.8.8.8',    // Google
    '1.1.1.1',    // Cloudflare
    '9.9.9.9',    // Quad9
    '208.67.222.222', // OpenDNS
    '77.88.8.8',  // Yandex (Russia)
  ];

  String _currentServer = '8.8.8.8';

  // اختيار أسرع سيرفر أو التبديل عشوائياً عند الحظر
  void hop() {
    _currentServer = _servers[Random().nextInt(_servers.length)];
    print("Hopping to new DNS node: $_currentServer");
  }

  String get activeNode => _currentServer;
}
