import 'package:flutter/material.dart';
import 'package:ascend/core/constants/constants.dart';

class IconUtils {
  static Widget buildCategoryIcon(
    String iconStr, {
    Color? color,
    double size = 22,
  }) {
    // If it's one of our predefined string keys, use the mapped const IconData
    if (CategoryIcons.iconMap.containsKey(iconStr)) {
      return Icon(CategoryIcons.iconMap[iconStr], color: color, size: size);
    }

    final codePoint = int.tryParse(iconStr);
    if (codePoint != null) {
      // NOTE: This fallback might still break tree-shaking if called.
      // But typically all icons we save are in our premiumIcons set.
      // We will default to a constant icon to ensure tree-shaking works 100%.
      return Icon(
        Icons
            .category_rounded, // Fallback const icon to avoid tree-shake errors
        color: color,
        size: size,
      );
    } else {
      // For emojis or other strings
      return Text(
        iconStr,
        style: TextStyle(fontSize: size, color: color),
      );
    }
  }
}
