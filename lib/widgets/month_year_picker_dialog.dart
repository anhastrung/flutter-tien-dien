import 'package:flutter/material.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime? from;
  final DateTime? to;
  final bool isFrom;

  const MonthYearPickerDialog({
    super.key,
    required this.from,
    required this.to,
    required this.isFrom,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int year;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();

    DateTime? baseDate;
    if (widget.isFrom) {
      baseDate = widget.from ?? widget.to;
    } else {
      baseDate = widget.to ?? widget.from;
    }

    year = baseDate?.year ?? now.year;
  }

  bool isBefore1969(int y) => y < 1969;

  bool isAfterNow(int y, int m) {
    final maxMonth = DateTime(now.year, now.month);
    return DateTime(y, m).isAfter(maxMonth);
  }

  bool isInRange(int y, int m) {
    if (widget.from == null || widget.to == null) return false;

    final start = DateTime(widget.from!.year, widget.from!.month);
    final end = DateTime(widget.to!.year, widget.to!.month);
    final current = DateTime(y, m);

    if (start.isAfter(end)) return false;

    return current.isAfter(start) && current.isBefore(end);
  }

  bool isEdge(int y, int m) {
    final current = DateTime(y, m);
    return (widget.from != null &&
            current.year == widget.from!.year &&
            current.month == widget.from!.month) ||
        (widget.to != null &&
            current.year == widget.to!.year &&
            current.month == widget.to!.month);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: isBefore1969(year - 1)
                ? null
                : () => setState(() => year--),
          ),
          Text(
            'Năm $year',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: year >= now.year ? null : () => setState(() => year++),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (_, index) {
            final month = index + 1;
            final disabled = isBefore1969(year) || isAfterNow(year, month);
            final edge = isEdge(year, month);
            final inRange = isInRange(year, month);

            Color bgColor;
            Color textColor;

            if (disabled) {
              bgColor = Colors.grey.shade300;
              textColor = Colors.grey;
            } else if (edge) {
              bgColor = Theme.of(context).colorScheme.primary;
              textColor = Colors.white;
            } else if (inRange) {
              bgColor = Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.25);
              textColor = Colors.white70;
            } else {
              bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
              textColor = Theme.of(context).colorScheme.onSurfaceVariant;
            }

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: disabled
                  ? null
                  : () {
                      Navigator.pop(context, DateTime(year, month));
                    },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Tháng $month',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: edge ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
