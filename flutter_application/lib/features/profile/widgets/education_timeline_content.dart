import 'package:flutter/material.dart';
import 'package:flutter_application/features/profile/widgets/timeline_content.dart';
import 'package:flutter_application/features/profile/widgets/timeline_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/education_model.dart';
import '../cubit/profile_cubit.dart';
import '../pages/profile.dart';
import '../utils/timeline_utils.dart';
import 'form_field_widgets.dart';

class EducationTimelineContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TimelineContent<EducationModel>(
      items: educations,
      config: config,
      userId: userId,
      onUpdate: (items) =>
          context.read<ProfileCubit>().updateEducations(userId, items),
    );
  }
}

class EducationTile extends StatelessWidget {
  final EducationModel education;
  final TimelineConfig<EducationModel> config;

  const EducationTile({
    super.key,
    required this.education,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final formattedStartDate =
        TimelineUtils.formatDate(education.startDate, config.dateFormatter);
    final formattedEndDate =
        TimelineUtils.formatDate(education.endDate, config.dateFormatter);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity, // Ensure card content fills available width
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

Widget buildEducationForm(
    EducationModel? education, Function(EducationModel) onSave) {
  final controllers = {
    'school': TextEditingController(text: education?.school ?? ''),
    'degree': TextEditingController(text: education?.degree ?? ''),
    'fieldOfStudy': TextEditingController(text: education?.fieldOfStudy ?? ''),
  };

  return TimelineForm<EducationModel>(
    item: education,
    onSave: onSave,
    controllers: controllers,
    typeName: 'Education',
    fieldBuilder: (item, controllers) => [
      FormFieldWidgets.buildTextField(
        controller: controllers['school']!,
        label: 'School',
        validator: (value) => value!.isEmpty ? 'Please enter a school' : null,
      ),
      const SizedBox(height: 16),
      FormFieldWidgets.buildTextField(
        controller: controllers['degree']!,
        label: 'Degree',
        validator: (value) => value!.isEmpty ? 'Please enter a degree' : null,
      ),
      const SizedBox(height: 16),
      FormFieldWidgets.buildTextField(
        controller: controllers['fieldOfStudy']!,
        label: 'Field of Study',
        validator: (value) =>
            value!.isEmpty ? 'Please enter a field of study' : null,
      ),
    ],
    itemFactory: (values, startDate, endDate) => EducationModel(
      id: education?.id ?? const Uuid().v4(),
      userId: Supabase.instance.client.auth.currentUser!.id,
      school: values['school']!,
      degree: values['degree']!,
      fieldOfStudy: values['fieldOfStudy']!,
      startDate: startDate,
      endDate: endDate,
    ),
  );
}
