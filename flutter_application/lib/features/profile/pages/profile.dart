import 'package:flutter/material.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uuid/uuid.dart';

import '../../../models/user_models.dart';
import '../cubit/profile_cubit.dart';
import '../edit_profile/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const Center(child: Text('User not found'));
    }
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(userId),
      child: Scaffold(
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is AvatarUpdateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            } else if (state is ProfileLoaded) {
              return ProfileContent(user: state.user, userId: userId);
            }
            return const Center(child: Text('Please wait...'));
          },
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  final UserModel user;
  final String userId;

  const ProfileContent({required this.user, required this.userId, Key? key})
      : super(key: key);

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<ProfileCubit>()
                    .updateAvatar(widget.userId, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Picture'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<ProfileCubit>()
                    .updateAvatar(widget.userId, ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Map UserModel experiences to ExperienceTimeline's Experience model
    final List<ExperienceModel> timelineExperiences = widget.user.experiences;

    // Custom TimelineConfig
    String formatDate(String date) {
      if (date.isEmpty) return "Present";
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM yyyy').format(parsedDate);
    }

    final timelineConfig = TimelineConfig(
      lineXY: 0.15,
      indicatorSize: 25.0,
      indicatorColor: Colors.green,
      lineColor: Colors.green,
      lineThickness: 4.0,
      companyTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      positionTextStyle: const TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.blueGrey,
      ),
      dateTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
      descriptionTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      dateFormatter: formatDate,
      customCardBuilder: (experience) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experience.company,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                experience.position,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${experience.startDate} - ${experience.endDate}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                experience.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.grey[200]), // Background placeholder
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: widget.user.avatarUrl != null
                                ? NetworkImage(widget.user.avatarUrl!)
                                : null,
                            child: widget.user.avatarUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showImageSourceDialog(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.user.fullName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          if (widget.user.headline != null)
                            Text(widget.user.headline!,
                                style: const TextStyle(fontSize: 16)),
                          if (widget.user.location != null)
                            Text(widget.user.location!,
                                style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: widget.user),
                  ),
                ).then((_) {
                  context.read<ProfileCubit>().fetchProfile(widget.user.id);
                });
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.user.bio != null) ...[
                  const Text('About',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.user.bio!),
                  const SizedBox(height: 16),
                ],
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Experience'),
                    Tab(text: 'Education'),
                    Tab(text: 'Skills'),
                    Tab(text: 'Job Applications'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Posts Tab
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.user.posts.length,
                itemBuilder: (context, index) {
                  final post = widget.user.posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.content),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on: ${post.createdAt.toString()}',
                            style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Experience Tab with ExperienceTimeline
              ExperienceTimelineContent(
                experiences: timelineExperiences,
                config: timelineConfig,
                userId: widget.userId,
              ),
              // Education Tab
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.user.educations.length,
                itemBuilder: (context, index) {
                  final education = widget.user.educations[index];
                  return ListTile(
                    title: Text(education.degree),
                    subtitle:
                    Text('${education.school}\n${education.fieldOfStudy}'),
                    trailing: Text(
                      '${education.startDate?.year ?? 'N/A'} - ${education.endDate?.year ?? 'Present'}',
                    ),
                  );
                },
              ),
              // Skills Tab
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.user.skills.length,
                itemBuilder: (context, index) {
                  final skill = widget.user.skills[index];
                  return ListTile(
                    title: Text(skill.title),
                    subtitle: Text(skill.description),
                    trailing: Text('Level: ${skill.level}'),
                  );
                },
              ),
              // Job Applications Tab
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.user.jobApplications.length,
                itemBuilder: (context, index) {
                  final application = widget.user.jobApplications[index];
                  return ListTile(
                    title: Text('Job ID: ${application.jobId}'),
                    subtitle: Text('Status: ${application.status.name}'),
                    trailing:
                    Text('Applied: ${application.appliedAt.toString()}'),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// New widget to encapsulate ExperienceTimeline content without Scaffold
class ExperienceTimelineContent extends StatefulWidget {
  final List<ExperienceModel> experiences;
  final TimelineConfig config;
  final String userId;

  const ExperienceTimelineContent({
    Key? key,
    required this.experiences,
    required this.config,
    required this.userId,
  }) : super(key: key);

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
      itemCount: _experiences.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == _experiences.length) {
          return TimelineTile(
            alignment: TimelineAlign.manual,
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

class TimelineConfig {
  final double lineXY;
  final double indicatorSize;
  final Color indicatorColor;
  final Color lineColor;
  final double lineThickness;
  final EdgeInsets padding;
  final EdgeInsets cardPadding;
  final TextStyle companyTextStyle;
  final TextStyle positionTextStyle;
  final TextStyle dateTextStyle;
  final TextStyle descriptionTextStyle;
  final String Function(String date)? dateFormatter;
  final Widget Function(ExperienceModel experience)? customCardBuilder;

  const TimelineConfig({
    this.lineXY = 0.2,
    this.indicatorSize = 20.0,
    this.indicatorColor = Colors.blueAccent,
    this.lineColor = Colors.blue,
    this.lineThickness = 3.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    this.cardPadding = const EdgeInsets.all(16.0),
    this.companyTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    this.positionTextStyle = const TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      color: Colors.grey,
    ),
    this.dateTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),
    this.descriptionTextStyle = const TextStyle(fontSize: 14),
    this.dateFormatter,
    this.customCardBuilder,
  });
}

// Experience Form Bottom Sheet
class ExperienceForm extends StatefulWidget {
  final ExperienceModel? experience;
  final Function(ExperienceModel) onSave;

  const ExperienceForm({Key? key, this.experience, required this.onSave})
      : super(key: key);

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
    _startDateController =
        TextEditingController(text: widget.experience?.startDate?.toString() ?? '');
    _endDateController =
        TextEditingController(text: widget.experience?.endDate?.toString() ?? '');
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
                      id: const Uuid().v4(),
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

// Timeline Tile Widget
class ExperienceTimelineTile extends StatelessWidget {
  final ExperienceModel experience;
  final bool isFirst;
  final bool isLast;
  final TimelineConfig config;
  final Function(ExperienceModel) onEdit;
  final Function(String) onDelete;

  const ExperienceTimelineTile({
    Key? key,
    required this.experience,
    required this.isFirst,
    required this.isLast,
    required this.config,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
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
          key: Key(experience.id!),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            onDelete(experience.id!);
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
      child: Padding(
        padding: config.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experience.company,
              style: config.companyTextStyle,
            ),
            const SizedBox(height: 4),
            Text(
              experience.position,
              style: config.positionTextStyle,
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
