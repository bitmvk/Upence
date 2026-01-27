import 'package:flutter/material.dart';
import 'package:upence/core/utils/icon_utils.dart';

class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcons = IconUtils.getCategoryIcons();

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categoryIcons.length,
      itemBuilder: (context, index) {
        final icon = categoryIcons[index];
        final isSelected = icon == selectedIcon;
        return GestureDetector(
          onTap: () => onIconSelected(icon),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              IconUtils.getIcon(icon),
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        );
      },
    );
  }
}
