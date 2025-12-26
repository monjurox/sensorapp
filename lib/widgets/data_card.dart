import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  
  const DataCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Divider
            Divider(
              color: Colors.grey[700],
              height: 1,
            ),
            
            const SizedBox(height: 12),
            
            // Content
            ...children,
          ],
        ),
      ),
    );
  }
}

// Specialized card for numeric values
class ValueCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color valueColor;
  
  const ValueCard({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.valueColor = Colors.white,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }
}