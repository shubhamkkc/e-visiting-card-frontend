import 'package:flutter/material.dart';
import '../constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor),
    );
  }
}
