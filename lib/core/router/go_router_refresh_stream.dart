import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to [ChangeNotifier] so GoRouter's [refreshListenable]
/// reacts to stream events (e.g. [AuthCubit] state changes).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
