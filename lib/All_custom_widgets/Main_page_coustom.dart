import 'package:flutter/material.dart';

class IconTextContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;

  const IconTextContainer({
    super.key,
    required this.icon,
    required this.text,
    this.size = 60,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size + 20,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size * 0.4, color: iconColor),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size * 0.18,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
