import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'home_screen_hint_view_model.dart';

class HomeScreenHint extends StatefulWidget {
  const HomeScreenHint({
    super.key,
    required this.viewModel,
    required this.child,
  });

  final HomeScreenHintViewModel viewModel;
  final Widget child;

  @override
  State<HomeScreenHint> createState() => _HomeScreenHintState();
}

class _HomeScreenHintState extends State<HomeScreenHint> {
  @override
  void initState() {
    super.initState();
    _suggestIfNeeded();
  }

  Future<void> _suggestIfNeeded() async {
    if (!await widget.viewModel.shouldSuggest() || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    messenger.showMaterialBanner(
      MaterialBanner(
        leading: const Icon(Icons.add_to_home_screen),
        content: Text(l10n.addToHomeScreen),
        actions: [
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(l10n.notNow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
