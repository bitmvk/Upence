import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/views/setup/setup_view_model.dart';

class TagsSetupPage extends ConsumerWidget {
  const TagsSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(
      setupViewModelProvider.select((state) => state.tags),
    );
    final viewModel = ref.read(setupViewModelProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Tags', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Create tags to label and organize transactions.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: tags.isEmpty
              ? Center(
                  child: Text(
                    'No tags added yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...tags.map(
                        (tag) => _TagChip(
                          tag: tag,
                          onDelete: () {
                            final index = tags.indexOf(tag);
                            viewModel.removeTag(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Tag'),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _TagDialog(
        onSave: (tag) {
          ref.read(setupViewModelProvider.notifier).addTag(tag);
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback onDelete;

  const _TagChip({required this.tag, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.name),
      backgroundColor: Color(tag.color).withValues(alpha: 0.2),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDelete,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _TagDialog extends StatefulWidget {
  final Function(Tag) onSave;

  const _TagDialog({required this.onSave});

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  late TextEditingController _nameController;
  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty
              ? () {
                  widget.onSave(
                    Tag(
                      id: 0,
                      name: _nameController.text,
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
