import 'package:flutter/material.dart';

const List<double> _defaultSizes = [
  16,
  8,
  6,
  4,
  2,
];

typedef PickerLayoutBuilder = Widget Function(
    BuildContext context, List<double> sizess, PickerItem child);
typedef PickerItem = Widget Function(double size);
typedef PickerItemBuilder = Widget Function(
    double size, bool isCurrentSize, void Function() changeSize);

class SizePicker extends StatefulWidget {
  const SizePicker({
    Key? key,
    required this.pickerSize,
    required this.onSizeChanged,
    this.availableSize = _defaultSizes,
    this.layoutBuilder = defaultLayoutBuilder,
    this.itemBuilder = defaultItemBuilder,
  }) : super(key: key);

  final double pickerSize;
  final ValueChanged<double> onSizeChanged;
  final List<double> availableSize;
  final PickerLayoutBuilder layoutBuilder;
  final PickerItemBuilder itemBuilder;

  static Widget defaultLayoutBuilder(
      BuildContext context, List<double> sizes, PickerItem child) {
    return SizedBox(
      width: 300.0,
      height: 60.0,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        children: sizes.map((double size) => child(size)).toList(),
      ),
    );
  }

  static Widget defaultItemBuilder(
      double size, bool isCurrentSize, void Function() changeSize) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: isCurrentSize
            ? Border.all(
                width: 4,
                color: Colors.blueGrey,
              )
            : Border.all(
                width: 2,
                color: Colors.white,
              ),
        borderRadius: BorderRadius.circular(50),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(1.0, 2.0),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeSize,
          borderRadius: BorderRadius.circular(50.0),
          child: Center(
            child: Text(
              size == 2
                  ? 'XS'
                  : size == 4
                      ? 'S'
                      : size == 6
                          ? 'M'
                          : size == 8
                              ? 'L'
                              : 'XL',
              style: const TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  _SizePickerState createState() => _SizePickerState();
}

class _SizePickerState extends State<SizePicker> {
  late double _currentSize;

  @override
  void initState() {
    _currentSize = widget.pickerSize;
    super.initState();
  }

  void changeSize(double size) {
    setState(() => _currentSize = size);
    widget.onSizeChanged(size);
  }

  @override
  Widget build(BuildContext context) {
    return widget.layoutBuilder(
      context,
      widget.availableSize,
      (double size, [bool? _, Function? __]) => widget.itemBuilder(
          size, _currentSize == size, () => changeSize(size)),
    );
  }
}
