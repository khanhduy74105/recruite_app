import 'package:flutter/material.dart';
import 'package:flutter_application/features/home/widgets/post_card_widget.dart';
import 'package:flutter_application/features/profile/widgets/resume_tab.dart';
import 'package:flutter_application/features/profile/widgets/skill_grid.dart';
import 'package:flutter_application/models/experience_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/education_model.dart';
import '../../../models/user_connection.dart';
import '../../../models/user_models.dart';
import '../../message/pages/chat_box_page.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/education_timeline_content.dart';
import '../widgets/experience_time_line_content.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return BlocProvider(
      create: (context) =>
          ProfileCubit()..fetchProfile(userId, viewerId: currentUserId),
      child: Scaffold(
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
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
              return ProfileContent(
                user: state.user,
                userId: userId,
                connectionStatus: state.connectionStatus,
                isOwnProfile: userId == currentUserId,
              );
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
  final ConnectionStatus? connectionStatus;
  final bool isOwnProfile;

  const ProfileContent({
    required this.user,
    required this.userId,
    this.connectionStatus,
    required this.isOwnProfile,
    super.key,
  });

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
      formBuilder: widget.isOwnProfile
          ? (item, onSave) => EducationFormWidget(
                education: item,
                onSave: onSave,
              )
          : null,
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
      formBuilder: widget.isOwnProfile
          ? (item, onSave) => ExperienceFormWidget(
                experience: item,
                onSave: onSave,
              )
          : null,
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

  void _startChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: ChatBoxPage(
            userId: widget.userId,
            userName: widget.user.fullName,
          ),
        ),
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
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.darken,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/drawer_background.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                          if (widget.isOwnProfile)
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black87,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                          if (widget.user.headline != null)
                            Text(
                              widget.user.headline!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFFFCC),
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black87,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.user.location != null)
                            Text(
                              widget.user.location!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFFFFFFCC),
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black87,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                            ),
                          if (!widget.isOwnProfile) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.connectionStatus ==
                                        ConnectionStatus.accepted) {
                                      context
                                          .read<ProfileCubit>()
                                          .deleteConnection(
                                              widget.userId, widget.userId);
                                    } else {
                                      context
                                          .read<ProfileCubit>()
                                          .createConnection(
                                              widget.userId, widget.userId);
                                    }
                                  },
                                  icon: Icon(
                                    widget.connectionStatus ==
                                            ConnectionStatus.accepted
                                        ? Icons.remove_circle
                                        : Icons.add_circle,
                                  ),
                                  label: Text(
                                    widget.connectionStatus ==
                                            ConnectionStatus.accepted
                                        ? 'Disconnect'
                                        : widget.connectionStatus ==
                                                ConnectionStatus.pending
                                            ? 'Pending'
                                            : 'Connect',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.connectionStatus ==
                                            ConnectionStatus.pending
                                        ? Colors.grey
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _startChat(context),
                                  icon: Image.asset(
                                    'assets/ic_message.png',
                                    width: 20,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  label: const Text('Message'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    Tab(text: 'Resume'),
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
              buildListPosts(),
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
              ResumeTab(
                userId: widget.userId,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildListPosts() {
    if (widget.user.posts.isNotEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: widget.user.posts.length,
          itemBuilder: (context, index) {
            final post = widget.user.posts[index];
            return PostCardWidget(postModel: post);
          },
        ),
      );
    } else
      return const Center(child: Text('No posts available'));
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
  final String typeName;
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
