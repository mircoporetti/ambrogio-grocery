import 'package:flutter/material.dart';

import '../../account/ui/account_view_model.dart';
import '../../account/ui/log_in_page.dart';
import '../../account/ui/log_in_view_model.dart';
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
    required this.accountViewModel,
    required this.logInViewModel,
  });

  final SettingsViewModel viewModel;
  final LanguageViewModel Function() languageViewModel;
  final AccountViewModel accountViewModel;
  final LogInViewModel Function() logInViewModel;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    widget.accountViewModel.dispose();
    super.dispose();
  }

  void _openLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LogInPage(viewModel: widget.logInViewModel()),
      ),
    );
  }

  Future<void> _logOut() async {
    final account = widget.accountViewModel;
    if (await account.logOut() || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.unsyncedChangesWillBeLost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logOutAnyway),
          ),
        ],
      ),
    );
    if (confirmed == true) await account.logOutAnyway();
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
        listenable: Listenable.merge([
          widget.viewModel,
          widget.accountViewModel,
        ]),
        builder: (context, _) {
          final language = widget.viewModel.language;
          final account = widget.accountViewModel;
          final session = account.session;
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
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(l10n.account),
                subtitle: Text(
                  account.loading ? '' : session?.email ?? l10n.notLoggedIn,
                ),
                trailing: session == null
                    ? const Icon(Icons.chevron_right)
                    : null,
                onTap: account.loading || session != null ? null : _openLogIn,
              ),
              if (session != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logOut),
                  onTap: _logOut,
                ),
            ],
          );
        },
      ),
    );
  }
}
