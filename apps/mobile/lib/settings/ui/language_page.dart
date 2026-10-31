import 'package:flutter/material.dart';

import '../../shared/ui/readable_width.dart';

import '../../l10n/app_localizations.dart';
import '../domain/language_preference.dart';
import 'language_name.dart';
import 'language_view_model.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key, required this.viewModel});

  final LanguageViewModel viewModel;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _choose(LanguagePreference preference) async {
    if (await widget.viewModel.choose(preference) && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.language),
            bottom: viewModel.failed
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: Container(
                      width: double.infinity,
                      color: colors.errorContainer,
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.changeLanguageFailed,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          body: ReadableWidth(
            maxWidth: ReadableWidth.list,
            child: ListView(
              children: [
                for (final choice in viewModel.choices)
                  ListTile(
                    title: Text(languageName(l10n, choice)),
                    selected: choice == viewModel.current,
                    trailing: choice == viewModel.current
                        ? const Icon(Icons.check)
                        : null,
                    enabled: !viewModel.saving,
                    onTap: () => _choose(choice),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
