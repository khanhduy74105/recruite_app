import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application/features/auth/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user_models.dart';
import '../cubit/setting_cubit.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        if (state.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your settings...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.error != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => cubit.loadSettings(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // Modern App Bar with Profile Header
              SliverAppBar(
                title: const Text(
                  'Account Settings',
                  style: TextStyle(fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildProfileHeader(context, state.user),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    children: [
                      _buildProfileSection(context, state.user, cubit),
                      const SizedBox(height: 16),
                      _buildContactSection(context, state.user, cubit),
                      const SizedBox(height: 16),
                      _buildProfessionalSection(context, state.user, cubit),
                      const SizedBox(height: 16),
                      _buildPreferencesSection(context, state, cubit),
                      const SizedBox(height: 16),
                      _buildAccountInfoSection(context, state.user),
                      const SizedBox(height: 16),
                      _buildDangerZone(context, cubit),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: 64,
                  height: 64,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().slideX(duration: 300.ms, begin: 1),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.9),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate().slideX(duration: 300.ms, begin: 1, delay: 100.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showChevron && onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      BuildContext context, UserModel user, SettingsCubit cubit) {
    return _buildSectionCard(
      context: context,
      title: 'Profile Information',
      icon: Icons.person_outline,
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.badge_outlined,
          title: 'Full Name',
          value: user.fullName,
          onTap: () =>
              _showEditDialog(context, 'Full Name', user.fullName, (value) {
            cubit.updateField('full_name', value);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.photo_camera_outlined,
          title: 'Profile Picture',
          value: user.avatarUrl != null ? 'Custom avatar' : 'Default avatar',
          onTap: () => _showEditDialog(
              context, 'Avatar URL', user.avatarUrl ?? '', (value) {
            cubit.updateField('avatar_url', value);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.info_outline,
          title: 'Bio',
          value: user.bio ?? 'Add a bio to tell others about yourself',
          onTap: () => _showEditDialog(context, 'Bio', user.bio ?? '', (value) {
            cubit.updateField('bio', value);
          }),
        ),
      ],
    );
  }

  Widget _buildContactSection(
      BuildContext context, UserModel user, SettingsCubit cubit) {
    return _buildSectionCard(
      context: context,
      title: 'Contact Information',
      icon: Icons.contact_mail_outlined,
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.email_outlined,
          title: 'Email Address',
          value: user.email,
          onTap: () => _showEditDialog(context, 'Email', user.email, (value) {
            cubit.updateField('email', value);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          value: user.phone ?? 'Add your phone number',
          onTap: () =>
              _showEditDialog(context, 'Phone', user.phone ?? '', (value) {
            cubit.updateField('phone', value);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: user.location ?? 'Add your location',
          onTap: () => _showEditDialog(context, 'Location', user.location ?? '',
              (value) {
            cubit.updateField('location', value);
          }),
        ),
      ],
    );
  }

  Widget _buildProfessionalSection(
      BuildContext context, UserModel user, SettingsCubit cubit) {
    return _buildSectionCard(
      context: context,
      title: 'Professional Details',
      icon: Icons.work_outline,
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.title_outlined,
          title: 'Professional Headline',
          value: user.headline ?? 'Add your professional headline',
          onTap: () => _showEditDialog(context, 'Headline', user.headline ?? '',
              (value) {
            cubit.updateField('headline', value);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.badge,
          title: 'Role',
          value: user.role != null
              ? userRoleToString(user.role!)
              : 'Select your role',
          onTap: () => _showRoleDialog(context, user.role, (role) {
            cubit.updateRole(role);
          }),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.description_outlined,
          title: 'Resume',
          value: user.resume != null ? 'Resume uploaded' : 'No resume',
          showChevron: false,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
      BuildContext context, SettingsState state, SettingsCubit cubit) {
    return _buildSectionCard(
      context: context,
      title: 'Preferences',
      icon: Icons.tune_outlined,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Receive notifications about updates',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: true,
                onChanged: (value) => cubit.toggleNotifications(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Switch between light and dark themes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: state.isDarkMode,
                onChanged: (value) => cubit.toggleDarkMode(value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoSection(BuildContext context, UserModel user) {
    return _buildSectionCard(
      context: context,
      title: 'Account Information',
      icon: Icons.info_outline,
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.fingerprint,
          title: 'Account ID',
          value: user.id,
          showChevron: false,
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          context: context,
          icon: Icons.calendar_today_outlined,
          title: 'Member Since',
          value: user.createdAt?.toIso8601String().split('T')[0] ?? 'Unknown',
          showChevron: false,
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, SettingsCubit cubit) {
    return _buildSectionCard(
      context: context,
      title: 'Account Actions',
      icon: Icons.warning_outlined,
      children: [
        _buildSettingsTile(
          context: context,
          icon: Icons.logout,
          title: 'Sign Out',
          value: 'Sign out of your account',
          iconColor: Colors.red[600],
          titleColor: Colors.red[600],
          onTap: () => _showLogoutDialog(context, cubit),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, String field, String currentValue,
      Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _getFieldIcon(field),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('Edit $field'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: field == 'Bio' ? 3 : 1,
              decoration: InputDecoration(
                hintText: 'Enter $field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(
      BuildContext context, UserRole? currentRole, Function(UserRole) onSave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.work_outline),
            SizedBox(width: 8),
            Text('Select Your Role'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values
              .map((role) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentRole == role
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                        width: currentRole == role ? 2 : 1,
                      ),
                    ),
                    child: RadioListTile<UserRole>(
                      title: Text(userRoleToString(role)),
                      value: role,
                      groupValue: currentRole,
                      onChanged: (value) {
                        if (value != null) {
                          onSave(value);
                          Navigator.pop(context);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ))
              .toList(),
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

  void _showLogoutDialog(BuildContext context, SettingsCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(
          Icons.logout,
          color: Colors.red[600],
          size: 32,
        ),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
            ),
            onPressed: () {
              cubit.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  IconData _getFieldIcon(String field) {
    switch (field.toLowerCase()) {
      case 'full name':
        return Icons.person_outline;
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'bio':
        return Icons.info_outline;
      case 'headline':
        return Icons.title_outlined;
      case 'location':
        return Icons.location_on_outlined;
      case 'avatar url':
        return Icons.photo_camera_outlined;
      default:
        return Icons.edit_outlined;
    }
  }
}
