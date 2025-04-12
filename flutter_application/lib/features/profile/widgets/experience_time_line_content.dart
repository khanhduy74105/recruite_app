import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uuid/uuid.dart';

import '../../../models/experience_model.dart';
import '../cubit/profile_cubit.dart';
import '../pages/profile.dart';

class ExperienceTimelineContent extends StatefulWidget {
  final List<ExperienceModel> experiences;
  final TimelineConfig<ExperienceModel> config;
  final String userId;

  const ExperienceTimelineContent({
    super.key,
    required this.experiences,
    required this.config,
    required this.userId,
  });

  @override
  _ExperienceTimelineContentState createState() =>
      _ExperienceTimelineContentState();
}

class _ExperienceTimelineContentState extends State<ExperienceTimelineContent> {
  late List<ExperienceModel> _experiences;

  @override
  void initState() {
    super.initState();
    _experiences = List.from(widget.experiences);
    _sortExperiences();
  }

  void _sortExperiences() {
    _experiences.sort((a, b) {
      if (a.endDate == null && b.endDate == null) {
        return 0;
      } else if (a.endDate == null) {
        return -1;
      } else if (b.endDate == null) {
        return 1;
      } else {
        return b.endDate!.compareTo(a.endDate!);
      }
    });
  }

  void _addOrUpdateExperience(ExperienceModel experience) {
    setState(() {
      int index = _experiences.indexWhere((exp) => exp.id == experience.id);
      if (index != -1) {
        _experiences[index] = experience;
      } else {
        _experiences.add(experience);
      }
      _sortExperiences();
    });
    context.read<ProfileCubit>().updateExperiences(widget.userId, _experiences);
  }

  void _deleteExperience(String id) {
    setState(() {
      _experiences.removeWhere((exp) => exp.id == id);
    });
    context.read<ProfileCubit>().updateExperiences(widget.userId, _experiences);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _experiences.length + 1,
      itemBuilder: (context, index) {
        if (index == _experiences.length) {
          return TimelineTile(
            alignment: TimelineAlign.start,
            lineXY: widget.config.lineXY,
            isLast: true,
            isFirst: _experiences.isEmpty,
            indicatorStyle: IndicatorStyle(
              width: widget.config.indicatorSize,
              color: widget.config.indicatorColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              iconStyle: IconStyle(
                iconData: Icons.add,
                color: Colors.white,
              ),
            ),
            beforeLineStyle: _experiences.isEmpty
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
                    builder: (context) => ExperienceForm(
                      onSave: _addOrUpdateExperience,
                    ),
                  );
                },
                child: const Text('Add Experience'),
              ),
            ),
          );
        }
        final experience = _experiences[index];
        return ExperienceTimelineTile(
          experience: experience,
          isFirst: index == 0,
          isLast: false,
          config: widget.config,
          onEdit: _addOrUpdateExperience,
          onDelete: _deleteExperience,
        );
      },
    );
  }
}

class ExperienceForm extends StatefulWidget {
  final ExperienceModel? experience;
  final Function(ExperienceModel) onSave;

  const ExperienceForm({super.key, this.experience, required this.onSave});

  @override
  _ExperienceFormState createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _companyController =
        TextEditingController(text: widget.experience?.company ?? '');
    _positionController =
        TextEditingController(text: widget.experience?.position ?? '');
    _startDateController = TextEditingController(
        text: widget.experience?.startDate?.toString() ?? '');
    _endDateController = TextEditingController(
        text: widget.experience?.endDate?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.experience?.description ?? '');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
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
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a company' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a position' : null,
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
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final experience = ExperienceModel(
                      id: widget.experience?.id ?? const Uuid().v4(),
                      userId: Supabase.instance.client.auth.currentUser!.id,
                      company: _companyController.text,
                      position: _positionController.text,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      description: _descriptionController.text,
                    );
                    widget.onSave(experience);
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

class ExperienceTimelineTile extends StatelessWidget {
  final ExperienceModel experience;
  final bool isFirst;
  final bool isLast;
  final TimelineConfig<ExperienceModel> config;
  final Function(ExperienceModel) onEdit;
  final Function(String) onDelete;

  const ExperienceTimelineTile({
    super.key,
    required this.experience,
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
      endChild: Padding(
        padding: config.padding,
        child: Expanded(
          child: Dismissible(
            key: Key(experience.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              onDelete(experience.id);
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
                  builder: (context) => ExperienceForm(
                    experience: experience,
                    onSave: onEdit,
                  ),
                );
              },
              child: config.customCardBuilder != null
                  ? config.customCardBuilder!(experience)
                  : _buildDefaultCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCard() {
    final formattedStartDate = config.dateFormatter != null
        ? config.dateFormatter!(experience.startDate!)
        : experience.startDate;
    final formattedEndDate = config.dateFormatter != null
        ? config.dateFormatter!(experience.endDate!)
        : (experience.endDate!.isEmpty ? "Present" : experience.endDate);

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
              experience.company,
              style: config.companyTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              experience.position,
              style: config.positionTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              "$formattedStartDate - $formattedEndDate",
              style: config.dateTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              experience.description,
              style: config.descriptionTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
