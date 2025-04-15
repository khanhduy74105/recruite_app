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
        width: double.infinity,
        padding: config.padding,
        child: config.customCardBuilder != null
            ? config.customCardBuilder!(item)
            : _buildDefaultCard(context),
      ),
    );
  }

  Widget _buildDefaultCard(BuildContext context) {
    return const SizedBox();
  }
}