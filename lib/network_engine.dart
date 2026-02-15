import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkEngine {
  // فحص نوع الاتصال الحالي
  Future<String> checkStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return "CLOUD_MODE (GitHub Active)";
    } else {
      return "MESH_MODE (Local Radar Only)";
    }
  }
}
