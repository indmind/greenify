import 'package:flutter/material.dart';

class GrInfoCard extends StatelessWidget {
  const GrInfoCard(
      {super.key,
      required this.title,
      required this.content,
      required this.icon,
      required this.isPrimaryColor});

  final String title;
  final String content;
  final IconData icon;
  final bool isPrimaryColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = isPrimaryColor
        ? Theme.of(context).primaryTextTheme
        : Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: isPrimaryColor
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: textTheme.titleLarge!.apply(fontWeightDelta: 2),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: textTheme.bodyMedium,
            ),
            const Spacer(),
            Icon(
              icon,
              size: 32,
              color: textTheme.bodyMedium!.color,
            ),
          ],
        ),
      ),
    );
  }
}
