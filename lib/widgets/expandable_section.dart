import 'package:flutter/material.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget expandedChild;
  final Widget? summary;
  final Widget? infoContent;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.expandedChild,
    this.summary,
    this.infoContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (infoContent != null)
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(title),
                              content: infoContent,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Đã hiểu'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
                if (!expanded && summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: DefaultTextStyle(
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                      child: summary!,
                    ),
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Visibility(
            visible: expanded,
            maintainState: true,
            maintainAnimation: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: expandedChild,
            ),
          ),
        ),
      ],
    );
  }
}
