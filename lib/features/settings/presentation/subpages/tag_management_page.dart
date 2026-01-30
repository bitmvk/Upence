import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/color_picker_widget.dart';
import '../../../../data/models/tag.dart';

enum _BottomSheetMode { form, colorPicker }

class TagManagementPage extends ConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(context, ref, null),
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
                    int.parse(tag.color.replaceFirst('#', '0xFF')),
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
                      onPressed: () => _showAddEditDialog(context, ref, tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _showDeleteDialog(context, ref, tag),
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
    Tag? existingTag,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEditTagBottomSheet(
        existingTag: existingTag,
        onSave: (name, color) async {
          final repo = ref.read(tagRepositoryProvider);

          if (existingTag == null) {
            await repo.insertTag(
              Tag(
                id: 0,
                name: name,
                color: color,
              ),
            );
          } else {
            await repo.updateTag(
              existingTag.copyWith(name: name, color: color),
            );
          }

          ref.invalidate(tagsProvider);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
  ) {
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
              ref.invalidate(tagsProvider);

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

class _AddEditTagBottomSheet extends StatefulWidget {
  final Tag? existingTag;
  final Future<void> Function(
    String name,
    String color,
  ) onSave;

  const _AddEditTagBottomSheet({
    required this.existingTag,
    required this.onSave,
  });

  @override
  State<_AddEditTagBottomSheet> createState() =>
      _AddEditTagBottomSheetState();
}

class _AddEditTagBottomSheetState extends State<_AddEditTagBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColor = AppColors.primary.toARGB32();
  _BottomSheetMode _mode = _BottomSheetMode.form;

  @override
  void initState() {
    super.initState();
    if (widget.existingTag != null) {
      _nameController.text = widget.existingTag!.name;
      _selectedColor =
          int.parse(widget.existingTag!.color.replaceFirst('#', '0xFF'));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          widget.existingTag == null ? 'Add Tag' : 'Edit Tag',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          autofocus: widget.existingTag == null,
          decoration: const InputDecoration(labelText: 'Name *'),
          onChanged: (_) => setState(() {}),
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
                        final colorHex =
                            '#${_selectedColor.toRadixString(16).substring(2)}';
                        widget.onSave(_nameController.text, colorHex);
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
        key: const ValueKey('colorPicker'),
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
            child: ColorPickerWidget(
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
