import 'package:flutter/material.dart';

import 'log_in_page.dart';
import 'log_in_prompt_view_model.dart';
import 'log_in_view_model.dart';

/// Shows [child] and, on the first launch without an account, the log-in
/// page on top of it.
class LogInPrompt extends StatefulWidget {
  const LogInPrompt({
    super.key,
    required this.viewModel,
    required this.logInViewModel,
    required this.child,
  });

  final LogInPromptViewModel viewModel;
  final LogInViewModel Function() logInViewModel;
  final Widget child;

  @override
  State<LogInPrompt> createState() => _LogInPromptState();
}

class _LogInPromptState extends State<LogInPrompt> {
  @override
  void initState() {
    super.initState();
    _askIfNeeded();
  }

  Future<void> _askIfNeeded() async {
    if (!await widget.viewModel.shouldAsk() || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            LogInPage(viewModel: widget.logInViewModel(), asPrompt: true),
      ),
    );
    await widget.viewModel.answered();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
