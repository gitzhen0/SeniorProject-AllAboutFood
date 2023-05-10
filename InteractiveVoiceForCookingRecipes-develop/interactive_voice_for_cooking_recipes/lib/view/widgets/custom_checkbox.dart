import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final Color activeColor;
  final Color checkColor;

  CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label = '',
    this.activeColor = Colors.blue,
    this.checkColor = Colors.white,
  }) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.value,
          onChanged: widget.onChanged,
          activeColor: widget.activeColor,
          checkColor: widget.checkColor,
        ),
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: TextStyle(fontSize: 16),
          ),
      ],
    );
  }
}
