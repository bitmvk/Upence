import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Helpers/icon_pack_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';

class IconPickerWidget extends StatefulWidget {
  final String? selectedIcon;
  final Function(String) onIconSelected;
  final double iconSize;

  const IconPickerWidget({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.iconSize = 40.0,
  });

  @override
  State<IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends State<IconPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Map<String, IconData> _handpickedIcons = {};
  Map<String, IconData>? _fullCache;
  bool _isBackgroundLoading = false;
  bool _hasLoadError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _handpickedIcons = IconUtils.handpickedIcons;
    _loadIconsInBackground();
  }

  Future<void> _loadIconsInBackground() async {
    if (_isBackgroundLoading) return;

    setState(() {
      _isBackgroundLoading = true;
      _hasLoadError = false;
    });

    try {
      final iconPack = IconPackManager.getIcons(IconPack.material);
      final iconMap = <String, IconData>{};

      for (final entry in iconPack.entries) {
        iconMap[entry.key] = entry.value.data;
      }

      if (iconMap.isEmpty) {
        throw Exception(
          'Icon pack is empty. Run: dart run flutter_iconpicker:generate_packs --packs material\n'
          'Icon packs must be generated before the app can use them.',
        );
      }

      IconUtils.populateCache(iconMap);

      setState(() {
        _fullCache = iconMap;
        _isBackgroundLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBackgroundLoading = false;
        _hasLoadError = true;
        _errorMessage = 'Failed to load icons: $e';
      });

      IconUtils.setLoadError('Failed to load icons: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, IconData>> get _filteredIcons {
    if (_searchQuery.isEmpty) {
      return _handpickedIcons.entries.toList();
    }

    if (_fullCache != null) {
      return _fullCache!.entries
          .where(
            (entry) =>
                entry.key.contains(_searchQuery.toLowerCase()) ||
                _formatIconName(
                  entry.key,
                ).toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .take(100)
          .toList();
    } else {
      return _handpickedIcons.entries
          .where(
            (entry) =>
                entry.key.contains(_searchQuery.toLowerCase()) ||
                _formatIconName(
                  entry.key,
                ).toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .take(100)
          .toList();
    }
  }

  String _formatIconName(String iconName) {
    return iconName
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search icons...',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: _isBackgroundLoading && _searchQuery.isNotEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        if (_hasLoadError) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Failed to load icons',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Expanded(child: _buildIconGrid()),
      ],
    );
  }

  Widget _buildIconGrid() {
    if (_searchQuery.isNotEmpty && _fullCache == null && _isBackgroundLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading icons for search...'),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredIcons.length,
      itemBuilder: (context, index) {
        final entry = _filteredIcons[index];
        final isSelected = entry.key == widget.selectedIcon;
        return _buildIconTile(entry.key, entry.value, isSelected);
      },
    );
  }

  Widget _buildIconTile(String key, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onIconSelected(key),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
            size: widget.iconSize,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              _formatIconName(key),
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
