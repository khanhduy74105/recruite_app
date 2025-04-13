import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../model/timeline_item.dart';
import '../pages/profile.dart';

class TimelineTileWidget<T extends TimelineItem> extends StatelessWidget {
  final T item;
  final bool isFirst;
  final bool isLast;
  final TimelineConfig<T> config;
  final Function(T) onEdit;
  final Function(String) onDelete;

  const TimelineTileWidget({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.config,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.start,
      lineXY: config.lineXY,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: config.indicatorSize,
        color: config.indicatorColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      beforeLineStyle: LineStyle(
        color: config.lineColor,
        thickness: config.lineThickness,
      ),
      afterLineStyle: LineStyle(
        color: config.lineColor,
        thickness: config.lineThickness,
      ),
      endChild: Container(
        width: double.infinity, // Ensure endChild takes full width
        padding: config.padding,
        child: Dismissible(
          key: Key(item.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) => onDelete(item.id),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          child: GestureDetector(
            onTap: () {
              if (config.formBuilder != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => config.formBuilder!(item, onEdit),
                );
              }
            },
            child: config.customCardBuilder != null
                ? config.customCardBuilder!(item)
                : _buildDefaultCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCard(BuildContext context) {
    return const SizedBox();
  }
}