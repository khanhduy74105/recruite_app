import 'package:flutter/material.dart';
import 'package:flutter_application/features/profile/widgets/resume_tab.dart';
import 'package:flutter_application/features/profile/widgets/skill_grid.dart';
import 'package:flutter_application/features/setting/page/account_setting_page.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/education_model.dart';
import '../../../models/user_models.dart';
import '../../setting/cubit/setting_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/education_timeline_content.dart';
import '../widgets/experience_time_line_content.dart';

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

  const ProfileContent({required this.user, required this.userId, super.key});

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
    final List<ExperienceModel> timelineExperiences = widget.user.experiences;

    String formatDate(String date) {
      if (date.isEmpty) return "Present";
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM yyyy').format(parsedDate);
    }

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
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    final settingsCubit =
                        BlocProvider.of<SettingsCubit>(context);
                    settingsCubit.loadSettings();
                    return const AccountSettingsScreen();
                  }),
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
                    Tab(text: 'Resume')
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
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ExperienceTimelineContent(
                experiences: timelineExperiences,
                config: TimelineConfig<ExperienceModel>(
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
                      width: double.infinity,
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
                ),
                userId: widget.userId,
              ),
              EducationTimelineContent(
                educations: widget.user.educations,
                config: TimelineConfig<EducationModel>(
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
                  customCardBuilder: (education) {
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
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            education.school,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            education.degree,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            education.fieldOfStudy,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${formatDate(education.startDate)} - ${education.endDate != null ? formatDate(education.endDate!) : 'Present'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                userId: widget.userId,
              ),
              SkillsGrid(userId: widget.userId),
              const ResumeTab()
            ],
          ),
        ),
      ],
    );
  }
}

class TimelineConfig<T> {
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
  final Widget Function(T data)? customCardBuilder;

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
