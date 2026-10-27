import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../account/application/watch_session.dart';
import '../../account/domain/session.dart';
import '../application/sync_recipes.dart';
import '../application/watch_pending_recipe_changes.dart';

/// Keeps the recipes in sync for the whole app: at login and app start,
/// after each change on the phone, and when the app comes back to the
/// foreground.
class RecipeSyncViewModel extends ChangeNotifier {
  RecipeSyncViewModel(
    WatchSession watchSession,
    WatchPendingRecipeChanges watchPending,
    this._sync,
  ) {
    _session = watchSession().listen((session) {
      final loggedIn = session != null;
      final justLoggedIn = loggedIn && !_loggedIn;
      _loggedIn = loggedIn;
      if (justLoggedIn) _sync();
    });
    _pending = watchPending().listen((count) {
      if (_loggedIn && count > 0) _sync();
    });
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (_loggedIn) _sync();
      },
    );
  }

  final SyncRecipes _sync;
  late final StreamSubscription<Session?> _session;
  late final StreamSubscription<int> _pending;
  late final AppLifecycleListener _lifecycle;
  bool _loggedIn = false;

  @override
  void dispose() {
    _session.cancel();
    _pending.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}
