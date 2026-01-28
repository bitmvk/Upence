import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _currentColor;
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _gController = TextEditingController();
  final TextEditingController _bController = TextEditingController();

  static const List<Color> predefinedColors = [
    Color(0xFF5D4EFD),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
    Color(0xFFF97316),
    Color(0xFF64748B),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor;
    _updateControllers();
  }

  @override
  void didUpdateWidget(ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      _currentColor = widget.selectedColor;
      _updateControllers();
    }
  }

  void _updateControllers() {
    _hexController.text = _colorToHex(_currentColor);
    _rController.text = _currentColor.red.toString();
    _gController.text = _currentColor.green.toString();
    _bController.text = _currentColor.blue.toString();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updateColorFromHex(String hex) {
    if (hex.isEmpty) return;
    final color = _hexToColor(hex);
    if (color != null) {
      setState(() {
        _currentColor = color;
        _updateRGBControllers();
      });
      widget.onColorChanged(color);
    }
  }

  Color? _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.startsWith('#')) {
      buffer.write(hex.replaceFirst('#', ''));
    } else {
      buffer.write(hex);
    }

    if (buffer.length == 6) {
      final intValue = int.tryParse(buffer.toString(), radix: 16);
      if (intValue != null) {
        return Color(0xFF000000 | intValue);
      }
    }
    return null;
  }

  void _updateColorFromRGB() {
    final r = int.tryParse(_rController.text) ?? 0;
    final g = int.tryParse(_gController.text) ?? 0;
    final b = int.tryParse(_bController.text) ?? 0;

    final color = Color.fromRGBO(
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
      1.0,
    );

    setState(() {
      _currentColor = color;
    });
    widget.onColorChanged(color);
    _hexController.text = _colorToHex(color);
  }

  void _updateRGBControllers() {
    _rController.text = _currentColor.red.toString();
    _gController.text = _currentColor.green.toString();
    _bController.text = _currentColor.blue.toString();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _rController.dispose();
    _gController.dispose();
    _bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 350,
            width: double.infinity,
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  _currentColor = color;
                  _updateControllers();
                });
                widget.onColorChanged(color);
              },
              pickerAreaHeightPercent: 0.7,
              paletteType: PaletteType.hsvWithHue,
              enableAlpha: false,
              displayThumbColor: true,
              labelTypes: const [],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hexController,
            decoration: const InputDecoration(
              labelText: "Hex",
              hintText: '#RRGGBB',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-F]')),
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              _updateColorFromHex(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rController,
                  decoration: InputDecoration(
                    labelText: 'R',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _updateColorFromRGB(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _gController,
                  decoration: InputDecoration(
                    labelText: 'G',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _updateColorFromRGB(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bController,
                  decoration: InputDecoration(
                    labelText: 'B',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _updateColorFromRGB(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: predefinedColors.map((color) {
                final isSelected = color.value == _currentColor.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentColor = color;
                      _updateControllers();
                    });
                    widget.onColorChanged(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
