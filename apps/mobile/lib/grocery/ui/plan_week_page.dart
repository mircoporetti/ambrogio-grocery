import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/ui/readable_width.dart';

import '../../l10n/app_localizations.dart';
import '../../recipes/domain/recipe.dart';
import '../../recipes/ui/photo_image.dart';
import '../domain/week.dart';
import 'grocery_list_page.dart';
import 'grocery_list_view_model.dart';
import 'plan_week_view_model.dart';
import 'week_format.dart';

class PlanWeekPage extends StatefulWidget {
  const PlanWeekPage({
    super.key,
    required this.viewModel,
    required this.groceryListViewModel,
  });

  final PlanWeekViewModel viewModel;
  final GroceryListViewModel Function(Week week) groceryListViewModel;

  @override
  State<PlanWeekPage> createState() => _PlanWeekPageState();
}

class _PlanWeekPageState extends State<PlanWeekPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<bool> _confirmReplace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(
            l10n.confirmReplaceGroceryList(
              formatWeek(l10n, widget.viewModel.week),
            ),
          ),
          content: Text(l10n.replaceGroceryListWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.replace),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _createGroceryList() async {
    final viewModel = widget.viewModel;
    if (await viewModel.replacesList()) {
      if (!mounted || !await _confirmReplace()) return;
    }
    final week = viewModel.week;
    if (!await viewModel.createGroceryList() || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            GroceryListPage(viewModel: widget.groceryListViewModel(week)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planTheWeek)),
      body: ReadableWidth(
        maxWidth: ReadableWidth.deck,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => Column(
            children: [
              _WeekPicker(viewModel: viewModel),
              Expanded(child: _deck(viewModel)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ReadableWidth(
        maxWidth: ReadableWidth.deck,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final error = viewModel.error;
                final colors = Theme.of(context).colorScheme;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            error.message(l10n),
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      ),
                    Semantics(
                      liveRegion: true,
                      child: Text(l10n.recipesChosen(viewModel.chosenCount)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: viewModel.canCreateGroceryList
                            ? _createGroceryList
                            : null,
                        child: Text(l10n.createGroceryList),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _deck(PlanWeekViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.recipes.isEmpty) {
      return Center(child: Text(l10n.addRecipesToPlan));
    }
    final recipe = viewModel.current;
    if (recipe == null) {
      return Center(child: Text(l10n.seenAllRecipes));
    }
    return _RecipeDeck(
      key: ValueKey(recipe.id),
      recipe: recipe,
      position: l10n.deckPosition(viewModel.position, viewModel.recipes.length),
      onCook: viewModel.cook,
      onSkip: viewModel.skip,
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker({required this.viewModel});

  final PlanWeekViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.earlierWeek,
            icon: const Icon(Icons.chevron_left),
            onPressed: viewModel.canChooseEarlierWeek
                ? viewModel.earlierWeek
                : null,
          ),
          Expanded(
            child: Text(
              formatWeek(l10n, viewModel.week),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: l10n.laterWeek,
            icon: const Icon(Icons.chevron_right),
            onPressed: viewModel.laterWeek,
          ),
        ],
      ),
    );
  }
}

class _RecipeDeck extends StatefulWidget {
  const _RecipeDeck({
    super.key,
    required this.recipe,
    required this.position,
    required this.onCook,
    required this.onSkip,
  });

  final Recipe recipe;
  final String position;
  final VoidCallback onCook;
  final VoidCallback onSkip;

  @override
  State<_RecipeDeck> createState() => _RecipeDeckState();
}

class _RecipeDeckState extends State<_RecipeDeck>
    with SingleTickerProviderStateMixin {
  static const _throwDistance = 0.35;
  static const _throwSpeed = 800.0;
  static const _maxTilt = 0.35;

  late final AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _offset = Offset.zero;
  double _width = 1;
  bool _thrown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() => setState(() => _offset = _animation.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _tilt =>
      (_offset.dx / _width * 0.5).clamp(-_maxTilt, _maxTilt).toDouble();

  void _animateTo(Offset target, {VoidCallback? onDone}) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    _controller.duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 250);
    _animation = Tween(
      begin: _offset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0).then((_) => onDone?.call());
  }

  void _throw(int direction) {
    if (_thrown) return;
    setState(() => _thrown = true);
    _animateTo(
      Offset(direction * _width * 1.5, _offset.dy + 80),
      onDone: direction > 0 ? widget.onCook : widget.onSkip,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_thrown) return;
    _controller.stop();
    setState(() => _offset += details.delta);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_thrown) return;
    final speed = details.velocity.pixelsPerSecond.dx;
    final far = _offset.dx.abs() > _width * _throwDistance;
    final fast = speed.abs() > _throwSpeed && speed.sign == _offset.dx.sign;
    if (far || fast) {
      _throw(_offset.dx > 0 ? 1 : -1);
    } else {
      _animateTo(Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.arrowRight): () => _throw(1),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _throw(-1),
    },
    child: Focus(autofocus: true, child: _card(context)),
  );

  Widget _card(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final pull = (_offset.dx / (_width * _throwDistance)).clamp(-1.0, 1.0);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.position),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _width = constraints.maxWidth;
                return GestureDetector(
                  onPanUpdate: _onDragUpdate,
                  onPanEnd: _onDragEnd,
                  child: Transform.translate(
                    offset: _offset,
                    child: Transform.rotate(
                      angle: _tilt,
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _RecipeCard(recipe: widget.recipe),
                          _SwipeStamp(
                            icon: Icons.check,
                            color: colors.primary,
                            alignment: Alignment.topLeft,
                            opacity: pull > 0 ? pull : 0,
                          ),
                          _SwipeStamp(
                            icon: Icons.close,
                            color: colors.error,
                            alignment: Alignment.topRight,
                            opacity: pull < 0 ? -pull : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _thrown ? null : () => _throw(-1),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.skip),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _thrown ? null : () => _throw(1),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.cook),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final photo = recipe.photo?.path;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: photo == null
                ? const Icon(Icons.restaurant, size: 96)
                : Image(
                    image: photoImage(photo),
                    fit: BoxFit.cover,
                    semanticLabel: l10n.photoOf(recipe.title),
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.restaurant, size: 96),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: textTheme.headlineSmall),
                Text(l10n.portions(recipe.portions)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.icon,
    required this.color,
    required this.alignment,
    required this.opacity,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Align(
          alignment: alignment,
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
