import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef BuildLeading<T> = Widget Function(T item);
typedef BuildTitle<T> = Widget Function(T item);
typedef BuildSubtitle<T> = Widget? Function(T item);
typedef GetName<T> = String? Function(T item);
typedef GetColor<T> = dynamic Function(T item);
typedef BuildDialogFields<T> =
    List<Widget> Function(
      TextEditingController nameController,
      Map<String, TextEditingController> extraControllers,
      StateSetter setState,
      dynamic selectedColor,
      T? existingItem,
    );
typedef SaveItem<T> =
    Future<void> Function(
      String name,
      Map<String, String> extraFields,
      int color,
      T? existingItem,
    );
typedef DeleteItem = Future<void> Function(int id);

class BaseManagementPage<T> extends ConsumerStatefulWidget {
  final String title;
  final ProviderListenable<AsyncValue<List<T>>> itemsProvider;
  final BuildLeading<T> buildLeading;
  final BuildTitle<T> buildTitle;
  final BuildSubtitle<T>? buildSubtitle;
  final List<int> availableColors;
  final GetName<T>? getName;
  final GetColor<T>? getColor;
  final BuildDialogFields<T> buildDialogFields;
  final SaveItem<T> onSave;
  final DeleteItem onDelete;

  const BaseManagementPage({
    super.key,
    required this.title,
    required this.itemsProvider,
    required this.buildLeading,
    required this.buildTitle,
    this.buildSubtitle,
    required this.availableColors,
    this.getName,
    this.getColor,
    required this.buildDialogFields,
    required this.onSave,
    required this.onDelete,
  });

  @override
  ConsumerState<BaseManagementPage<T>> createState() =>
      _BaseManagementPageState<T>();
}

class _BaseManagementPageState<T> extends ConsumerState<BaseManagementPage<T>> {
  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(widget.itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(null),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text('No ${widget.title.toLowerCase()} yet'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: widget.buildLeading(item),
                title: widget.buildTitle(item),
                subtitle: widget.buildSubtitle?.call(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _showDeleteDialog(item),
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

  void _showAddEditDialog(T? item) {
    String initialName = '';

    if (widget.getName != null && item != null) {
      initialName = widget.getName!(item) ?? '';
    }

    final nameController = TextEditingController(text: initialName);
    final extraControllers = <String, TextEditingController>{};
    dynamic selectedColor = widget.availableColors.isNotEmpty
        ? widget.availableColors.first
        : 0xFF4361EE;

    if (widget.getColor != null && item != null) {
      try {
        selectedColor = widget.getColor!(item);
      } catch (_) {}
    }

    final extraFields = <String, String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item == null
                    ? 'Add ${widget.title.substring(0, widget.title.length - 1)}'
                    : 'Edit ${widget.title.substring(0, widget.title.length - 1)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              ...widget.buildDialogFields(
                nameController,
                extraControllers,
                setState,
                selectedColor,
                item,
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty) return;

                        extraControllers.forEach((key, controller) {
                          extraFields[key] = controller.text;
                        });

                        final color = selectedColor is int
                            ? selectedColor
                            : selectedColor is String
                            ? int.parse(
                                selectedColor.toString().replaceAll(
                                  '#',
                                  '0xFF',
                                ),
                              )
                            : 0xFF4361EE;

                        await widget.onSave(
                          nameController.text,
                          extraFields,
                          color,
                          item,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(T item) {
    int id = 0;
    String name = '';

    try {
      id = (item as dynamic).id as int;
      name = (item as dynamic).name as String;
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${widget.title.substring(0, widget.title.length - 1)}',
        ),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await widget.onDelete(id);

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

Widget buildColorPicker({
  required List<int> colors,
  required dynamic selectedColor,
  required StateSetter setState,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Color'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: colors.map((colorValue) {
          final isSelected = selectedColor is int
              ? selectedColor == colorValue
              : (selectedColor is String
                    ? int.parse(
                            selectedColor.toString().replaceAll('#', '0xFF'),
                          ) ==
                          colorValue
                    : false);

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
        }).toList(),
      ),
    ],
  );
}

Widget buildTextField({
  required TextEditingController controller,
  required String labelText,
  String? hintText,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      keyboardType: keyboardType,
    ),
  );
}
