import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/category.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
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
                  child: Text(
                    category.icon,
                    style: const TextStyle(color: Colors.white),
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
                      onPressed: () => _showEditCategoryDialog(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.expense,
                      onPressed: () => _showDeleteDialog(category),
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

  void _showAddCategoryDialog() {
    _showCategoryDialog(null);
  }

  void _showEditCategoryDialog(Category category) {
    _showCategoryDialog(category);
  }

  void _showCategoryDialog(Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final iconController = TextEditingController(text: category?.icon ?? '📦');
    int selectedColor = category?.color ?? AppColors.primary.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Icon (emoji)'),
              ),
              const SizedBox(height: 16),
              const Text('Color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildColorOption(AppColors.primary.value, selectedColor, setState),
                  _buildColorOption(AppColors.income.value, selectedColor, setState),
                  _buildColorOption(AppColors.expense.value, selectedColor, setState),
                  _buildColorOption(AppColors.warning.value, selectedColor, setState),
                  _buildColorOption(AppColors.gray600.value, selectedColor, setState),
                  _buildColorOption(AppColors.gray800.value, selectedColor, setState),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;

                final repo = ref.read(categoryRepositoryProvider);
                if (category == null) {
                  await repo.insertCategory(
                    Category(
                      id: 0, // Will be assigned by database
                      name: nameController.text,
                      icon: iconController.text,
                      color: selectedColor,
                      description: descriptionController.text,
                    ),
                  );
                } else {
                  await repo.updateCategory(
                    category.copyWith(
                      name: nameController.text,
                      icon: iconController.text,
                      color: selectedColor,
                      description: descriptionController.text,
                    ),
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(categoriesProvider);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    int colorValue,
    int selectedColor,
    StateSetter setState,
  ) {
    final isSelected = colorValue == selectedColor;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = colorValue),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
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
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(categoriesProvider);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
