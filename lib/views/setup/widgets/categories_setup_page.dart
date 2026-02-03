import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/views/setup/setup_view_model.dart';

class CategoriesSetupPage extends ConsumerWidget {
  const CategoriesSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(
      setupViewModelProvider.select((state) => state.categories),
    );
    final viewModel = ref.read(setupViewModelProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Add categories to organize your expenses.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: categories.isEmpty
              ? Center(
                  child: Text(
                    'No categories added yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      category: category,
                      onEdit: () =>
                          _showEditDialog(context, ref, category, index),
                      onDelete: () => viewModel.removeCategory(index),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        onSave: (category) {
          ref.read(setupViewModelProvider.notifier).addCategory(category);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        category: category,
        onSave: (updatedCategory) {
          ref
              .read(setupViewModelProvider.notifier)
              .updateCategory(updatedCategory, index);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color),
          child: Icon(
            IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
            color: Colors.white,
          ),
        ),
        title: Text(category.name),
        subtitle: category.description != null
            ? Text(category.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const _CategoryDialog({this.category, required this.onSave});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _icon = '0xe157';
  Color _color = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    if (widget.category != null) {
      _icon = widget.category!.icon;
      _color = Color(widget.category!.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
              ),
              initialValue: _icon,
              items: const [
                DropdownMenuItem(value: '0xe157', child: Icon(Icons.category)),
                DropdownMenuItem(
                  value: '0xe856',
                  child: Icon(Icons.shopping_cart),
                ),
                DropdownMenuItem(
                  value: '0xe7ef',
                  child: Icon(Icons.restaurant),
                ),
                DropdownMenuItem(
                  value: '0xe53e',
                  child: Icon(Icons.directions_car),
                ),
                DropdownMenuItem(value: '0xe7fd', child: Icon(Icons.home)),
                DropdownMenuItem(value: '0xe88f', child: Icon(Icons.work)),
                DropdownMenuItem(
                  value: '0xe853',
                  child: Icon(Icons.health_and_safety),
                ),
                DropdownMenuItem(value: '0xe86c', child: Icon(Icons.school)),
                DropdownMenuItem(value: '0xe41b', child: Icon(Icons.flight)),
                DropdownMenuItem(value: '0xe7b1', child: Icon(Icons.games)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _icon = value;
                  });
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: _color),
              title: const Text('Color'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final color = await showDialog<Color>(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: BlockPicker(
                      pickerColor: _color,
                      onColorChanged: (color) {
                        Navigator.pop(context, color);
                      },
                    ),
                  ),
                );
                if (color != null) {
                  setState(() {
                    _color = color;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty
              ? () {
                  widget.onSave(
                    Category(
                      id: widget.category?.id ?? 0,
                      name: _nameController.text,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      icon: _icon,
                      color: _color.toARGB32(),
                    ),
                  );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
