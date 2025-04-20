import 'package:flutter/material.dart';

class FormattedDateTimeText extends StatelessWidget {
  final String? isoString;
  final TextStyle? style;

  const FormattedDateTimeText({
    super.key,
    required this.isoString,
    this.style,
  });

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final formatted = "${dateTime.day.toString().padLeft(2, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.year}, "
          "${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}:"
          "${dateTime.minute.toString().padLeft(2, '0')} "
          "${dateTime.hour >= 12 ? 'PM' : 'AM'}";
      return formatted;
    } catch (e) {
      return isoString ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateTime(isoString),
      style: style ?? const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}
