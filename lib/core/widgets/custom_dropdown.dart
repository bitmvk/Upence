import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final Widget? icon;
  final Widget Function(T? value)? selectedItemBuilder;
  final bool isExpanded;
  final Color? fillColor;

  const CustomDropdown({
    super.key,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.dropdownColor,
    this.menuMaxHeight,
    this.icon,
    this.selectedItemBuilder,
    this.isExpanded = false,
    this.fillColor,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height,
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height),
                  child: GestureDetector(
                    onTap: () {},
                    child: _DropdownMenu<T>(
                      items: widget.items,
                      value: widget.value,
                      dropdownColor: widget.dropdownColor,
                      menuMaxHeight: widget.menuMaxHeight,
                      onItemSelected: (item) {
                        widget.onChanged?.call(item);
                        _removeOverlay();
                      },
                      onDismiss: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedWidget = widget.selectedItemBuilder != null
        ? widget.selectedItemBuilder!(widget.value)
        : widget.items
              .firstWhere(
                (item) => item.value == widget.value,
                orElse: () => const DropdownMenuItem(child: SizedBox()),
              )
              .child;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isOpen) {
            _removeOverlay();
          } else {
            _showOverlay();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.fillColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.value != null
                    ? selectedWidget
                    : Text(
                        widget.hint,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
              ),
              widget.icon ??
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Theme.of(context).iconTheme.color,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownMenu<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final ValueChanged<T?> onItemSelected;
  final VoidCallback onDismiss;

  const _DropdownMenu({
    required this.items,
    this.value,
    this.dropdownColor,
    this.menuMaxHeight,
    required this.onItemSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(8),
              color: dropdownColor ?? Theme.of(context).canvasColor,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: menuMaxHeight ?? 300,
                  minWidth: 100,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: items.map((item) {
                    final isSelected = item.value == value;
                    return InkWell(
                      onTap: () => onItemSelected(item.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : null,
                        ),
                        child: item.child,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
