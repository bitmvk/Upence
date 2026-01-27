import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/tag.dart';

class TagManagementPage extends ConsumerStatefulWidget {
  const TagManagementPage({super.key});

  @override
  ConsumerState<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends ConsumerState<TagManagementPage> {
  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTagDialog(),
          ),
        ],
      ),
      body: tagsAsync.when(
        data: (tags) {
          if (tags.isEmpty) {
            return const Center(
              child: Text('No tags yet'),
            );
          }

          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(
                    int.parse(tag.color.replaceAll('#', '0xFF')),
                  ),
                  child: Text(
                    tag.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(tag.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditTagDialog(tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.expense,
                      onPressed: () => _showDeleteDialog(tag),
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

  void _showAddTagDialog() {
    _showTagDialog(null);
  }

  void _showEditTagDialog(Tag tag) {
    _showTagDialog(tag);
  }

  void _showTagDialog(Tag? tag) {
    final nameController = TextEditingController(text: tag?.name ?? '');
    String selectedColor = tag?.color ?? '#4361EE';

    final colors = [
      '#4361EE', // Primary
      '#06D6A0', // Income
      '#EF476F', // Expense
      '#FFD166', // Warning
      '#118AB2', // Blue
      '#073B4C', // Dark Blue
      '#9D4EDD', // Purple
      '#FF9F1C', // Orange
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tag == null ? 'Add Tag' : 'Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              const Text('Color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors.map((color) {
                  return _buildColorOption(color, selectedColor, setState);
                }).toList(),
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

                final repo = ref.read(tagRepositoryProvider);
                if (tag == null) {
                  await repo.insertTag(
                    Tag(
                      id: 0,
                      name: nameController.text,
                      color: selectedColor,
                    ),
                  );
                } else {
                  await repo.updateTag(
                    tag.copyWith(
                      name: nameController.text,
                      color: selectedColor,
                    ),
                  );
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(tagsProvider);
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
    String color,
    String selectedColor,
    StateSetter setState,
  ) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(tagRepositoryProvider);
              await repo.deleteTag(tag.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(tagsProvider);
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
