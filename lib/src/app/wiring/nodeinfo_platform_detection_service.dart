import 'package:thunder/src/foundation/contracts/platform_detection_service.dart';
import 'package:thunder/src/features/instance/data/services/instance_discovery_service.dart';

class NodeInfoPlatformDetectionService implements PlatformDetectionService {
  const NodeInfoPlatformDetectionService();

  @override
  Future<Map<String, dynamic>?> detectPlatform(String instance) {
    return detectPlatformFromNodeInfo(instance);
  }
}
