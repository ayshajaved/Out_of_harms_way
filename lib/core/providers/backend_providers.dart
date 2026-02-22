import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/backend_service.dart';

final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService();
});
