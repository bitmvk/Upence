import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/core/ui/icon_mapper.dart';
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
              : Scrollbar(
                  child: ListView.builder(
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
            iconMap[category.icon] ?? Icons.category,
            color: Colors.white,
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
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
  String _icon = "category";
  Color _color = Colors.deepPurple;

  final categoryIcons = iconMap.entries
      .where(
        (e) => [
          // Food & Dining
          'restaurant',
          'fastfood',
          'pizza',
          'coffee',
          'breakfast_dining',
          'dinner_dining',
          'lunch_dining',
          'icecream',
          'cake',
          'liquor',
          'local_bar',
          'ramen_dining',
          'set_meal',
          'restaurant_menu',
          // Transportation
          'directions_car',
          'directions_bike',
          'directions_walk',
          'directions_bus',
          'directions_railway',
          'directions_transit',
          'flight',
          'flight_land',
          'flight_takeoff',
          'train',
          'subway',
          'tram',
          'local_taxi',
          'electric_car',
          'airport_shuttle',
          'pedal_bike',
          'two_wheeler',
          'moped',
          'electric_scooter',
          // Shopping
          'shopping_cart',
          'store',
          'shopping_bag',
          'local_mall',
          'payment',
          'receipt',
          'point_of_sale',
          // Entertainment
          'theater_comedy',
          'movie_filter',
          'movie_creation',
          'live_tv',
          'sports_esports',
          'sports_soccer',
          'sports_basketball',
          'sports_baseball',
          'sports_cricket',
          'sports_tennis',
          'sports_golf',
          'sports',
          'fitness_center',
          'games',
          'videogame_asset',
          // Health & Wellness
          'medical_services',
          'health_and_safety',
          'local_hospital',
          'local_pharmacy',
          'medication',
          'vaccines',
          'psychology',
          'self_improvement',
          'spa',
          'healing',
          'monitor_heart',
          // Utilities & Services
          'water_drop',
          'bolt',
          'gas_meter',
          'lightbulb_outline',
          'wb_sunny',
          'ac_unit',
          'thermostat',
          'cleaning_services',
          // Education
          'school',
          'book',
          'menu_book',
          'import_contacts',
          'library_books',
          'library_add',
          'class',
          'science',
          // Personal Care
          'face',
          'content_cut',
          // Travel
          'luggage',
          'hotel',
          'beach_access',
          'hiking',
          'nature',
          // Subscriptions & Bills
          'subscriptions',
          'receipt_long',
          // Miscellaneous
          'home',
          'work',
          'pets',
          'category',
        ].contains(e.key),
      )
      .toList();

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
    _nameController.addListener(() {
      setState(() {});
    });
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
              items: categoryIcons.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Icon(entry.value),
                );
              }).toList(),
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
