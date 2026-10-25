import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/ingredient.dart';
import '../domain/recipe.dart';
import 'formatting.dart';
import 'recipe_form_view_model.dart';

class RecipeFormPage extends StatefulWidget {
  const RecipeFormPage({super.key, required this.viewModel});

  final RecipeFormViewModel viewModel;

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _portions = TextEditingController();
  final _procedure = TextEditingController();
  final _ingredientName = TextEditingController();
  final _ingredientQuantity = TextEditingController();
  final _category = TextEditingController();

  final List<Ingredient> _ingredients = [];
  final List<String> _categories = [];
  MeasureUnit _unit = MeasureUnit.grams;

  String? _ingredientNameError;
  String? _ingredientQuantityError;
  String? _ingredientsError;

  @override
  void initState() {
    super.initState();
    final initial = widget.viewModel.initial;
    if (initial == null) return;
    _title.text = initial.title;
    _portions.text = '${initial.portions}';
    _procedure.text = initial.procedure ?? '';
    _ingredients.addAll(initial.ingredients);
    _categories.addAll(initial.categories);
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _portions,
      _procedure,
      _ingredientName,
      _ingredientQuantity,
      _category,
    ]) {
      c.dispose();
    }
    widget.viewModel.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final name = _ingredientName.text.trim();
    final quantity = _parseQuantity(_ingredientQuantity.text);
    setState(() {
      _ingredientNameError = name.isEmpty
          ? 'Ingredient name is required'
          : null;
      _ingredientQuantityError = quantity == null || quantity <= 0
          ? 'Quantity must be a number greater than 0'
          : null;
      if (_ingredientNameError != null || _ingredientQuantityError != null) {
        return;
      }
      _ingredients.add(
        Ingredient(name: name, quantity: quantity!, unit: _unit),
      );
      _ingredientsError = null;
      _ingredientName.clear();
      _ingredientQuantity.clear();
    });
  }

  void _removeIngredient(Ingredient ingredient) =>
      setState(() => _ingredients.remove(ingredient));

  void _addCategory() {
    final categories = distinctCategories([..._categories, _category.text]);
    setState(() {
      _categories
        ..clear()
        ..addAll(categories);
      _category.clear();
    });
  }

  void _removeCategory(String category) =>
      setState(() => _categories.remove(category));

  Future<void> _save() async {
    final fieldsValid = _formKey.currentState!.validate();
    setState(() {
      _ingredientsError = _ingredients.isEmpty
          ? 'Add at least one ingredient'
          : null;
    });
    if (!fieldsValid || _ingredientsError != null) return;

    final procedure = _procedure.text.trim();
    final saved = await widget.viewModel.save(
      Recipe(
        id: widget.viewModel.initial?.id,
        title: _title.text.trim(),
        portions: int.parse(_portions.text.trim()),
        ingredients: _ingredients,
        procedure: procedure.isEmpty ? null : procedure,
        photoPath: widget.viewModel.photoPath,
        categories: _categories,
      ),
    );
    if (saved && mounted) Navigator.of(context).pop();
  }

  static double? _parseQuantity(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewModel.isEditing ? 'Edit recipe' : 'New recipe'),
        actions: [
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (_, _) => TextButton(
              // Disabled while saving so a double tap can't save twice.
              onPressed: widget.viewModel.saving ? null : _save,
              child: const Text('Save'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              final error = widget.viewModel.error;
              if (error == null) return const SizedBox.shrink();
              final colors = Theme.of(context).colorScheme;
              return Container(
                width: double.infinity,
                color: colors.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              ListenableBuilder(
                listenable: widget.viewModel,
                builder: (_, _) => _PhotoField(
                  photoPath: widget.viewModel.photoPath,
                  onPick: widget.viewModel.pickPhoto,
                ),
              ),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _portions,
                decoration: const InputDecoration(labelText: 'Portions'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final portions = int.tryParse((value ?? '').trim());
                  return portions == null || portions < 1
                      ? 'Portions must be a whole number of at least 1'
                      : null;
                },
              ),
              Text('Ingredients', style: textTheme.titleMedium),
              for (final ingredient in _ingredients)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(ingredient.name),
                  subtitle: Text(formatQuantity(ingredient)),
                  trailing: IconButton(
                    tooltip: 'Remove ${ingredient.name}',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeIngredient(ingredient),
                  ),
                ),
              if (_ingredientsError != null)
                Text(
                  _ingredientsError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              TextFormField(
                controller: _ingredientName,
                decoration: InputDecoration(
                  labelText: 'Ingredient',
                  errorText: _ingredientNameError,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientQuantity,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        errorText: _ingredientQuantityError,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SegmentedButton<MeasureUnit>(
                    segments: [
                      for (final unit in MeasureUnit.values)
                        ButtonSegment(value: unit, label: Text(unit.symbol)),
                    ],
                    selected: {_unit},
                    onSelectionChanged: (s) => setState(() => _unit = s.single),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                label: const Text('Add ingredient'),
              ),
              TextFormField(
                controller: _procedure,
                decoration: const InputDecoration(
                  labelText: 'Procedure (optional)',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
              Text('Categories', style: textTheme.titleMedium),
              if (_categories.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final category in _categories)
                      InputChip(
                        label: Text(category),
                        onDeleted: () => _removeCategory(category),
                        deleteButtonTooltipMessage: 'Remove $category',
                      ),
                  ],
                ),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                textCapitalization: TextCapitalization.sentences,
                onFieldSubmitted: (_) => _addCategory(),
              ),
              OutlinedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.photoPath, required this.onPick});

  final String? photoPath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    if (path == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add photo (optional)'),
      );
    }
    return Semantics(
      button: true,
      label: 'Change photo',
      child: InkWell(
        onTap: onPick,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              height: 180,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
        ),
      ),
    );
  }
}
