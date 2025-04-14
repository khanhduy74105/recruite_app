import 'package:flutter/material.dart';
import 'package:flutter_application/features/profile/widgets/timeline_tile.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../model/timeline_item.dart';
import '../pages/profile.dart';

class TimelineContent<T extends TimelineItem> extends StatefulWidget {
  final List<T> items;
  final TimelineConfig<T> config;
  final String userId;
  final Function(List<T>) onUpdate;

  const TimelineContent({
    super.key,
    required this.items,
    required this.config,
    required this.userId,
    required this.onUpdate,
  });

  @override
  _TimelineContentState<T> createState() => _TimelineContentState<T>();
}

class _TimelineContentState<T extends TimelineItem> extends State<TimelineContent<T>> {
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _sortItems();
  }

  void _sortItems() {
    _items.sort((a, b) {
      if (a.endDate == null && b.endDate == null) {
        return DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate));
      } else if (a.endDate == null) {
        return -1;
      } else if (b.endDate == null) {
        return 1;
      } else {
        return DateTime.parse(b.endDate!).compareTo(DateTime.parse(a.endDate!));
      }
    });
  }

  void _addOrUpdateItem(T item) {
    setState(() {
      int index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      } else {
        _items.add(item);
      }
      _sortItems();
    });
    widget.onUpdate(_items);
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((i) => i.id == id);
    });
    widget.onUpdate(_items);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.config.typeName.toLowerCase()} added yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return TimelineTileWidget(
          item: item,
          isFirst: index == 0,
          isLast: index == _items.length - 1,
          config: widget.config,
          onEdit: _addOrUpdateItem,
          onDelete: _deleteItem,
        );
      },
    );
  }
}