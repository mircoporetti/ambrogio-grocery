import 'package:flutter/material.dart';

import '../../shared/ui/readable_width.dart';

import '../../l10n/app_localizations.dart';
import 'confirm_skip_log_in.dart';
import 'log_in_view_model.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key, required this.viewModel, this.asPrompt = false});

  final LogInViewModel viewModel;

  /// Shown at startup: offers to skip instead of going back.
  final bool asPrompt;

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    widget.viewModel.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final loggedIn = await widget.viewModel.submit(
      email: _email.text,
      password: _password.text,
    );
    if (loggedIn && mounted) Navigator.of(context).pop();
  }

  Future<void> _skip() async {
    if (await confirmSkipLogIn(context) && mounted) {
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
        final creating = viewModel.mode == AccountFormMode.createAccount;
        final title = creating ? l10n.createAccount : l10n.logIn;
        final error = viewModel.error;
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: !widget.asPrompt,
            actions: [
              if (widget.asPrompt)
                TextButton(
                  onPressed: viewModel.submitting ? null : _skip,
                  child: Text(l10n.skip),
                ),
            ],
            bottom: error == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: Container(
                      width: double.infinity,
                      color: colors.errorContainer,
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          error.message(l10n),
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ),
                  ),
          ),
          body: ReadableWidth(
            maxWidth: ReadableWidth.form,
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.asPrompt)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(l10n.logInLater),
                      ),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(labelText: l10n.emailLabel),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? l10n.emailRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                      ),
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: [
                        creating
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) =>
                          (value ?? '').isEmpty ? l10n.passwordRequired : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: viewModel.submitting ? null : _submit,
                      child: Text(title),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: viewModel.submitting
                          ? null
                          : viewModel.switchMode,
                      child: Text(
                        creating
                            ? l10n.switchToLogIn
                            : l10n.switchToCreateAccount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
