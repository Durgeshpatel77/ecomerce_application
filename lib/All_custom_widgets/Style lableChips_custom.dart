// import 'package:flutter/material.dart';
//
// class StyledLabelChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//
//   const StyledLabelChip({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(width: 6),
//           Text(
//             "$label: ",
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
