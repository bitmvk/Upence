import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/widgets/icon_picker_widget.dart';
import '../../../../core/widgets/color_picker_widget.dart';
import '../../../../data/models/category.dart';

enum _BottomSheetMode { form, iconPicker, colorPicker }

class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context, ref, null),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet'),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category.color),
                  child: Icon(
                    IconUtils.getIcon(category.icon),
                    color: Colors.white,
                  ),
                ),
                title: Text(category.name),
                subtitle: category.description.isNotEmpty
                    ? Text(category.description)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showAddEditDialog(context, ref, category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _showDeleteDialog(context, ref, category),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref,
    Category? existingCategory,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEditCategoryBottomSheet(
        existingCategory: existingCategory,
        onSave: (name, icon, color, description) async {
          final repo = ref.read(categoryRepositoryProvider);

          if (existingCategory == null) {
            await repo.insertCategory(
              Category(
                id: 0,
                name: name,
                icon: icon,
                color: color,
                description: description,
              ),
            );
          } else {
            await repo.updateCategory(
              existingCategory.copyWith(
                name: name,
                icon: icon,
                color: color,
                description: description,
              ),
            );
          }

          ref.invalidate(categoriesProvider);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(categoryRepositoryProvider);
              await repo.deleteCategory(category.id);
              ref.invalidate(categoriesProvider);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddEditCategoryBottomSheet extends StatefulWidget {
  final Category? existingCategory;
  final Future<void> Function(
    String name,
    String icon,
    int color,
    String description,
  ) onSave;

  const _AddEditCategoryBottomSheet({
    required this.existingCategory,
    required this.onSave,
  });

  @override
  State<_AddEditCategoryBottomSheet> createState() =>
      _AddEditCategoryBottomSheetState();
}

class _AddEditCategoryBottomSheetState
    extends State<_AddEditCategoryBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedIcon = 'restaurant';
  int _selectedColor = AppColors.primary.toARGB32();
  _BottomSheetMode _mode = _BottomSheetMode.form;

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController.text = widget.existingCategory!.name;
      _descriptionController.text = widget.existingCategory!.description;
      _selectedIcon = widget.existingCategory!.icon;
      _selectedColor = widget.existingCategory!.color;
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
    return PopScope(
      canPop: _mode == _BottomSheetMode.form,
      onPopInvokedWithResult: (didPop, result) {
        if (_mode != _BottomSheetMode.form && !didPop) {
          setState(() {
            _mode = _BottomSheetMode.form;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_mode == _BottomSheetMode.form) _buildFormContent(),
                if (_mode != _BottomSheetMode.form)
                  Expanded(child: _buildPickerContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.existingCategory == null ? 'Add Category' : 'Edit Category',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          autofocus: widget.existingCategory == null,
          decoration: const InputDecoration(labelText: 'Name *'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 16),
        const Text('Icon'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _mode = _BottomSheetMode.iconPicker),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(IconUtils.getIcon(_selectedIcon), size: 32),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Color'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _mode = _BottomSheetMode.colorPicker),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(_selectedColor),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.palette, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _nameController.text.isNotEmpty
                    ? () {
                        widget.onSave(
                          _nameController.text,
                          _selectedIcon,
                          _selectedColor,
                          _descriptionController.text,
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPickerContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      child: Column(
        key: ValueKey(_mode),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _mode = _BottomSheetMode.form;
                });
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const Divider(),
          Expanded(
            child: _mode == _BottomSheetMode.iconPicker
                ? IconPickerWidget(
                    selectedIcon: _selectedIcon,
                    onIconSelected: (icon) {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                  )
                : ColorPickerWidget(
                    selectedColor: Color(_selectedColor),
                    onColorChanged: (color) {
                      setState(() {
                        _selectedColor = color.toARGB32();
                      });
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _mode = _BottomSheetMode.form;
                    });
                  },
                  child: const Text('Done'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
