import 'package:flutter/material.dart';
import 'package:flutter_application/features/home/widgets/post_card_widget.dart';
import 'package:flutter_application/features/profile/widgets/resume_tab.dart';
import 'package:flutter_application/features/profile/widgets/skill_grid.dart';
import 'package:flutter_application/features/setting/page/account_setting_page.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
  late TimelineConfig<EducationModel> educationConfig;
  late TimelineConfig<ExperienceModel> experienceConfig;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    educationConfig = TimelineConfig<EducationModel>(
      lineXY: 0.2,
      indicatorSize: 30,
      indicatorColor: Colors.blue,
      lineColor: Colors.grey,
      lineThickness: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cardPadding: const EdgeInsets.all(16),
      companyTextStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      positionTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      descriptionTextStyle: const TextStyle(fontSize: 14),
      dateTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      typeName: 'Education',
      formBuilder: buildEducationForm,
      customCardBuilder: (education) =>
          EducationTile(education: education, config: educationConfig),
    );

    experienceConfig = TimelineConfig<ExperienceModel>(
      lineXY: 0.2,
      indicatorSize: 30,
      indicatorColor: Colors.green,
      lineColor: Colors.grey,
      lineThickness: 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      cardPadding: const EdgeInsets.all(16),
      companyTextStyle:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      positionTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      descriptionTextStyle: const TextStyle(fontSize: 14),
      dateTextStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      typeName: 'Experience',
      formBuilder: buildExperienceForm,
      customCardBuilder: (experience) =>
          ExperienceTile(experience: experience, config: experienceConfig),
    );
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
                  return PostCardWidget(postModel: post);
                },
              ),
              ExperienceTimelineContent(
                experiences: timelineExperiences,
                config: experienceConfig,
                userId: widget.userId,
              ),
              EducationTimelineContent(
                educations: widget.user.educations,
                config: educationConfig,
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
  final TextStyle descriptionTextStyle;
  final TextStyle dateTextStyle;
  final Widget Function(T)? customCardBuilder;
  final String Function(String)? dateFormatter;
  final String typeName; // e.g., "Education" or "Experience"
  final Widget Function(T?, Function(T))? formBuilder;

  TimelineConfig({
    required this.lineXY,
    required this.indicatorSize,
    required this.indicatorColor,
    required this.lineColor,
    required this.lineThickness,
    required this.padding,
    required this.cardPadding,
    required this.companyTextStyle,
    required this.positionTextStyle,
    required this.descriptionTextStyle,
    required this.dateTextStyle,
    this.customCardBuilder,
    this.dateFormatter,
    required this.typeName,
    this.formBuilder,
  });
}
