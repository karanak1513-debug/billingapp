import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pos_repository.dart';

final posRepositoryProvider = Provider<PosRepository>((ref) {
  return PosRepository();
});
