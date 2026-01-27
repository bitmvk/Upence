import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/management_colors.dart';
import '../../../../data/models/tag.dart';
import '../widgets/management_base_widget.dart';

class TagManagementPage extends ConsumerWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseManagementPage<Tag>(
      title: 'Tags',
      itemsProvider: tagsProvider,
      availableColors: ManagementColors.tagColors,
      buildLeading: (tag) => CircleAvatar(
        backgroundColor: Color(ManagementColors.parseColorHex(tag.color)),
        child: Text(
          tag.name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      buildTitle: (tag) => Text(tag.name),
      getName: (tag) => tag.name,
      getColor: (tag) => ManagementColors.parseColorHex(tag.color),
      buildDialogFields:
          (
            nameController,
            extraControllers,
            setState,
            selectedColor,
            existingTag,
          ) {
            return [
              buildColorPicker(
                colors: ManagementColors.tagColors,
                selectedColor: selectedColor,
                setState: setState,
              ),
            ];
          },
      onSave: (name, extraFields, color, existingTag) async {
        final repo = ref.read(tagRepositoryProvider);
        final colorHex = ManagementColors.toColorHex(color);

        if (existingTag == null) {
          await repo.insertTag(Tag(id: 0, name: name, color: colorHex));
        } else {
          await repo.updateTag(
            existingTag.copyWith(name: name, color: colorHex),
          );
        }

        ref.invalidate(tagsProvider);
      },
      onDelete: (id) async {
        final repo = ref.read(tagRepositoryProvider);
        await repo.deleteTag(id);
        ref.invalidate(tagsProvider);
      },
    );
  }
}
