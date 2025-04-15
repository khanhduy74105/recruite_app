import 'package:flutter/material.dart';

import '../model/timeline_item.dart';
import '../utils/timeline_utils.dart';
import 'form_field_widgets.dart';

class TimelineForm<T extends TimelineItem> extends StatefulWidget {
  final T? item;
  final Function(T) onSave;
  final List<Widget> Function(T?, Map<String, TextEditingController>)
      fieldBuilder;
  final Map<String, TextEditingController> controllers;
  final T Function(Map<String, String>, String, String?) itemFactory;
  final String typeName;

  const TimelineForm({
    super.key,
    this.item,
    required this.onSave,
    required this.fieldBuilder,
    required this.controllers,
    required this.itemFactory,
    required this.typeName,
  });

  @override
  _TimelineFormState<T> createState() => _TimelineFormState<T>();
}

class _TimelineFormState<T extends TimelineItem>
    extends State<TimelineForm<T>> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = TimelineUtils.parseDate(widget.item?.startDate);
    _endDate = TimelineUtils.parseDate(widget.item?.endDate);
  }

  @override
  void dispose() {
    widget.controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 8,
        right: 8,
        top: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      widget.item == null
                          ? 'Add ${widget.typeName}'
                          : 'Edit ${widget.typeName}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  ...widget.fieldBuilder(widget.item, widget.controllers),
                  const SizedBox(height: 16),
                  FormFieldWidgets.buildDateField(
                    label: 'Start Date',
                    selectedDate: _startDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _startDate = date);
                    },
                    validator: (value) => _startDate == null
                        ? 'Please select a start date'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FormFieldWidgets.buildDateField(
                    label: 'End Date (leave empty for present)',
                    selectedDate: _endDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(1970),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            dialogBackgroundColor: Colors.white,
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueAccent),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      setState(() => _endDate = date);
                    },
                  ),
                  const SizedBox(height: 24),
                  FormFieldWidgets.buildSaveButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final values = widget.controllers.map(
                            (key, controller) =>
                                MapEntry(key, controller.text));
                        final item = widget.itemFactory(
                          values,
                          TimelineUtils.formatDateTime(_startDate),
                          TimelineUtils.formatDateTime(_endDate),
                        );
                        widget.onSave(item);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
