import 'package:flutter/material.dart';

class InfoText extends StatelessWidget {
  final String? title;
  final String description;

  const InfoText({super.key, this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    if (title == null || title!.isEmpty) {
      return Text(description);
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: description),
        ],
      ),
    );
  }
}
  