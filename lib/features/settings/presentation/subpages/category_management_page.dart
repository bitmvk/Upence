import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/management_colors.dart';
import '../../../../data/models/category.dart';
import '../widgets/management_base_widget.dart';

class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseManagementPage<Category>(
      title: 'Categories',
      itemsProvider: categoriesProvider,
      availableColors: ManagementColors.categoryColors,
      buildLeading: (category) => CircleAvatar(
        backgroundColor: Color(category.color),
        child: Text(category.icon, style: const TextStyle(color: Colors.white)),
      ),
      buildTitle: (category) => Text(category.name),
      buildSubtitle: (category) =>
          category.description.isNotEmpty ? Text(category.description) : null,
      getName: (category) => category.name,
      getColor: (category) => category.color,
      buildDialogFields:
          (
            nameController,
            extraControllers,
            setState,
            selectedColor,
            existingCategory,
          ) {
            if (!extraControllers.containsKey('description')) {
              extraControllers['description'] = TextEditingController(
                text: existingCategory?.description ?? '',
              );
            }
            if (!extraControllers.containsKey('icon')) {
              extraControllers['icon'] = TextEditingController(
                text: existingCategory?.icon ?? '📦',
              );
            }

            return [
              buildTextField(
                controller: extraControllers['description']!,
                labelText: 'Description',
              ),
              buildTextField(
                controller: extraControllers['icon']!,
                labelText: 'Icon (emoji)',
              ),
              buildColorPicker(
                colors: ManagementColors.categoryColors,
                selectedColor: selectedColor,
                setState: setState,
              ),
            ];
          },
      onSave: (name, extraFields, color, existingCategory) async {
        final repo = ref.read(categoryRepositoryProvider);

        if (existingCategory == null) {
          await repo.insertCategory(
            Category(
              id: 0,
              name: name,
              icon: extraFields['icon'] ?? '📦',
              color: color,
              description: extraFields['description'] ?? '',
            ),
          );
        } else {
          await repo.updateCategory(
            existingCategory.copyWith(
              name: name,
              icon: extraFields['icon'] ?? existingCategory.icon,
              color: color,
              description:
                  extraFields['description'] ?? existingCategory.description,
            ),
          );
        }

        ref.invalidate(categoriesProvider);
      },
      onDelete: (id) async {
        final repo = ref.read(categoryRepositoryProvider);
        await repo.deleteCategory(id);
        ref.invalidate(categoriesProvider);
      },
    );
  }
}
