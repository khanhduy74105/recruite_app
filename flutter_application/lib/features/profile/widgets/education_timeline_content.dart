import 'package:flutter/material.dart';
import 'package:flutter_application/models/education_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uuid/uuid.dart';

import '../cubit/profile_cubit.dart';
import '../pages/profile.dart';

class EducationTimelineContent extends StatefulWidget {
  final List<EducationModel> educations;
  final TimelineConfig<EducationModel> config;
  final String userId;

  const EducationTimelineContent({
    super.key,
    required this.educations,
    required this.config,
    required this.userId,
  });

  @override
  _EducationTimelineContentState createState() =>
      _EducationTimelineContentState();
}

class _EducationTimelineContentState extends State<EducationTimelineContent> {
  late List<EducationModel> _educations;

  @override
  void initState() {
    super.initState();
    _educations = List.from(widget.educations);
    _sortEducations();
  }

  void _sortEducations() {
    _educations.sort((a, b) {
      if (a.endDate == null && b.endDate == null) {
        return b.startDate.compareTo(a.startDate);
      } else if (a.endDate == null) {
        return -1;
      } else if (b.endDate == null) {
        return 1;
      } else {
        return b.endDate!.compareTo(a.endDate!);
      }
    });
  }

  void _addOrUpdateEducation(EducationModel education) {
    setState(() {
      int index = _educations.indexWhere((edu) => edu.id == education.id);
      if (index != -1) {
        _educations[index] = education;
      } else {
        _educations.add(education);
      }
      _sortEducations();
    });
    context.read<ProfileCubit>().updateEducations(widget.userId, _educations);
  }

  void _deleteEducation(String id) {
    setState(() {
      _educations.removeWhere((edu) => edu.id == id);
    });
    context.read<ProfileCubit>().updateEducations(widget.userId, _educations);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _educations.length + 1,
      itemBuilder: (context, index) {
        if (index == _educations.length) {
          return TimelineTile(
            alignment: TimelineAlign.start,
            lineXY: widget.config.lineXY,
            isLast: true,
            isFirst: _educations.isEmpty,
            indicatorStyle: IndicatorStyle(
              width: widget.config.indicatorSize,
              color: widget.config.indicatorColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              iconStyle: IconStyle(
                iconData: Icons.add,
                color: Colors.white,
              ),
            ),
            beforeLineStyle: _educations.isEmpty
                ? const LineStyle()
                : LineStyle(
                    color: widget.config.lineColor,
                    thickness: widget.config.lineThickness,
                  ),
            endChild: Padding(
              padding: widget.config.padding,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => EducationForm(
                      onSave: _addOrUpdateEducation,
                    ),
                  );
                },
                child: const Text('Add Education'),
              ),
            ),
          );
        }
        final education = _educations[index];
        return EducationTimelineTile(
          education: education,
          isFirst: index == 0,
          isLast: false,
          config: widget.config,
          onEdit: _addOrUpdateEducation,
          onDelete: _deleteEducation,
        );
      },
    );
  }
}

class EducationTimelineTile extends StatelessWidget {
  final EducationModel education;
  final bool isFirst;
  final bool isLast;
  final TimelineConfig<EducationModel> config;
  final Function(EducationModel) onEdit;
  final Function(String) onDelete;

  const EducationTimelineTile({
    Key? key,
    required this.education,
    required this.isFirst,
    required this.isLast,
    required this.config,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
      endChild: Padding(
        padding: config.padding,
        child: Dismissible(
          key: Key(education.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            onDelete(education.id);
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 30,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => EducationForm(
                  education: education,
                  onSave: onEdit,
                ),
              );
            },
            child: config.customCardBuilder != null
                ? config.customCardBuilder!(education)
                : _buildDefaultCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCard() {
    final formattedStartDate = config.dateFormatter != null
        ? config.dateFormatter!(education.startDate)
        : education.startDate;
    final formattedEndDate = education.endDate != null
        ? (config.dateFormatter != null
            ? config.dateFormatter!(education.endDate!)
            : education.endDate!)
        : "Present";

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: config.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              education.school,
              style: config.companyTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              education.degree,
              style: config.positionTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              education.fieldOfStudy,
              style: config.descriptionTextStyle,
            ),
            const SizedBox(height: 4),
            Text(
              "$formattedStartDate - $formattedEndDate",
              style: config.dateTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class EducationForm extends StatefulWidget {
  final EducationModel? education;
  final Function(EducationModel) onSave;

  const EducationForm({Key? key, this.education, required this.onSave})
      : super(key: key);

  @override
  _EducationFormState createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _schoolController;
  late TextEditingController _degreeController;
  late TextEditingController _fieldOfStudyController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _schoolController =
        TextEditingController(text: widget.education?.school ?? '');
    _degreeController =
        TextEditingController(text: widget.education?.degree ?? '');
    _fieldOfStudyController =
        TextEditingController(text: widget.education?.fieldOfStudy ?? '');
    _startDateController = TextEditingController(
        text: widget.education?.startDate.substring(0, 10) ?? '');
    _endDateController = TextEditingController(
        text: widget.education?.endDate != null
            ? widget.education!.endDate!.substring(0, 10)
            : '');
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(labelText: 'School'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a school' : null,
              ),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: 'Degree'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a degree' : null,
              ),
              TextFormField(
                controller: _fieldOfStudyController,
                decoration: const InputDecoration(labelText: 'Field of Study'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a field of study' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration:
                    const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a start date';
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'Invalid date format';
                  }
                },
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD or empty for present)'),
                validator: (value) {
                  if (value!.isNotEmpty) {
                    try {
                      DateTime.parse(value);
                      return null;
                    } catch (e) {
                      return 'Invalid date format';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final education = EducationModel(
                      id: widget.education?.id ?? const Uuid().v4(),
                      userId: Supabase.instance.client.auth.currentUser!.id,
                      school: _schoolController.text,
                      degree: _degreeController.text,
                      fieldOfStudy: _fieldOfStudyController.text,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text.isEmpty
                          ? null
                          : _endDateController.text,
                    );
                    widget.onSave(education);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
