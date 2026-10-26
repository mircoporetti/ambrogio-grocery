import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'language_name.dart';
import 'language_page.dart';
import 'language_view_model.dart';
import 'settings_view_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.viewModel,
    required this.languageViewModel,
  });

  final SettingsViewModel viewModel;
  final LanguageViewModel Function() languageViewModel;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _openLanguage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LanguagePage(viewModel: widget.languageViewModel()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final language = widget.viewModel.language;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  language == null ? '' : languageName(l10n, language),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openLanguage,
              ),
            ],
          );
        },
      ),
    );
  }
}
