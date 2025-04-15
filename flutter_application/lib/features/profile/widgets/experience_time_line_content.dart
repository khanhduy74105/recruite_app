import 'package:flutter/material.dart';
import 'package:flutter_application/features/profile/widgets/timeline_content.dart';
import 'package:flutter_application/features/profile/widgets/timeline_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/experience_model.dart';
import '../cubit/profile_cubit.dart';
import '../pages/profile.dart';
import '../utils/timeline_utils.dart';
import 'form_field_widgets.dart';

class ExperienceTimelineContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TimelineContent<ExperienceModel>(
      items: experiences,
      config: config,
      userId: userId,
      onUpdate: (items) =>
          context.read<ProfileCubit>().updateExperiences(userId, items),
    );
  }
}

class ExperienceTile extends StatelessWidget {
  final ExperienceModel experience;
  final TimelineConfig<ExperienceModel> config;

  const ExperienceTile({
    super.key,
    required this.experience,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final formattedStartDate = TimelineUtils.formatDate(experience.startDate, config.dateFormatter);
    final formattedEndDate = TimelineUtils.formatDate(experience.endDate, config.dateFormatter);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
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

Widget buildExperienceForm(
    ExperienceModel? experience, Function(ExperienceModel) onSave) {
  final controllers = {
    'company': TextEditingController(text: experience?.company ?? ''),
    'position': TextEditingController(text: experience?.position ?? ''),
    'description': TextEditingController(text: experience?.description ?? ''),
  };

  return TimelineForm<ExperienceModel>(
    item: experience,
    onSave: onSave,
    controllers: controllers,
    typeName: 'Experience',
    fieldBuilder: (item, controllers) => [
      FormFieldWidgets.buildTextField(
        controller: controllers['company']!,
        label: 'Company',
        validator: (value) => value!.isEmpty ? 'Please enter a company' : null,
      ),
      const SizedBox(height: 16),
      FormFieldWidgets.buildTextField(
        controller: controllers['position']!,
        label: 'Position',
        validator: (value) => value!.isEmpty ? 'Please enter a position' : null,
      ),
      const SizedBox(height: 16),
      FormFieldWidgets.buildTextField(
        controller: controllers['description']!,
        label: 'Description',
        maxLines: 3,
        validator: (value) =>
            value!.isEmpty ? 'Please enter a description' : null,
      ),
    ],
    itemFactory: (values, startDate, endDate) => ExperienceModel(
      id: experience?.id ?? const Uuid().v4(),
      userId: Supabase.instance.client.auth.currentUser!.id,
      company: values['company']!,
      position: values['position']!,
      description: values['description']!,
      startDate: startDate,
      endDate: endDate,
    ),
  );
}
