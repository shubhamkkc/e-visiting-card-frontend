import 'package:flutter/material.dart';
import '../constants.dart';

class NavigationBarCustom extends StatelessWidget {
  final Function(int) onItemSelected;
  const NavigationBarCustom({super.key, required this.onItemSelected});

  static const List<String> _menuItems = [
    "Home",
    "About Us",
    "Products",
    "Gallery",
    "Feedback",
    "Enquiry",
    "Share"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _menuItems.asMap().entries.map((entry) {
          int index = entry.key;
          String title = entry.value;
          return InkWell(
            onTap: () => onItemSelected(index),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}
