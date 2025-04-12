import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

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
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cubit.loadSettings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Settings'),
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          body: SettingsList(
            contentPadding: const EdgeInsets.all(16),
            sections: [
              SettingsSection(
                title: const Text('Profile').animate().fadeIn(duration: 300.ms),
                tiles: [
                  SettingsTile.navigation(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: state.user.avatarUrl ??
                              'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    title: const Text('Avatar URL')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(
                      state.user.avatarUrl ?? 'No URL',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(
                          context, 'Avatar URL', state.user.avatarUrl ?? '',
                          (value) {
                        cubit.updateField('avatar_url', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.person)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Full Name')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(state.user.fullName)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(context, 'Full Name', state.user.fullName,
                          (value) {
                        cubit.updateField('full_name', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.email)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title:
                        const Text('Email').animate().fadeIn(duration: 300.ms),
                    value: Text(state.user.email)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(context, 'Email', state.user.email,
                          (value) {
                        cubit.updateField('email', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.phone)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title:
                        const Text('Phone').animate().fadeIn(duration: 300.ms),
                    value: Text(state.user.phone ?? 'No phone')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(context, 'Phone', state.user.phone ?? '',
                          (value) {
                        cubit.updateField('phone', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.info)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Bio').animate().fadeIn(duration: 300.ms),
                    value: Text(
                      state.user.bio ?? 'No bio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(context, 'Bio', state.user.bio ?? '',
                          (value) {
                        cubit.updateField('bio', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.work)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title:
                        const Text('Role').animate().fadeIn(duration: 300.ms),
                    value: Text(state.user.role != null
                            ? userRoleToString(state.user.role!)
                            : 'No role')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showRoleDialog(context, state.user.role, (role) {
                        cubit.updateRole(role);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.title)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Headline')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(
                      state.user.headline ?? 'No headline',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(
                          context, 'Headline', state.user.headline ?? '',
                          (value) {
                        cubit.updateField('headline', value);
                      });
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.location_on)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Location')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(state.user.location ?? 'No location')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      _showEditDialog(
                          context, 'Location', state.user.location ?? '',
                          (value) {
                        cubit.updateField('location', value);
                      });
                    },
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.fingerprint)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('ID').animate().fadeIn(duration: 300.ms),
                    value:
                        Text(state.user.id).animate().fadeIn(duration: 300.ms),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.description)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Resume ID')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(state.user.resume ?? 'No resume')
                        .animate()
                        .fadeIn(duration: 300.ms),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.calendar_today)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Created At')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    value: Text(state.user.createdAt?.toIso8601String() ??
                            'Unknown')
                        .animate()
                        .fadeIn(duration: 300.ms),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Preferences')
                    .animate()
                    .fadeIn(duration: 300.ms),
                tiles: [
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.notifications)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Notifications')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    initialValue: true,
                    onToggle: (value) => cubit.toggleNotifications(value),
                  ),
                  SettingsTile.switchTile(
                    leading: const Icon(Icons.dark_mode)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Dark Mode')
                        .animate()
                        .fadeIn(duration: 300.ms),
                    initialValue: state.isDarkMode,
                    onToggle: (value) => cubit.toggleDarkMode(value),
                  ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout, color: Colors.red)
                        .animate()
                        .fadeIn(duration: 300.ms),
                    title: const Text('Logout',
                            style: TextStyle(color: Colors.red))
                        .animate()
                        .fadeIn(duration: 300.ms),
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                cubit.logout();
                                Navigator.pop(context);
                              },
                              child: const Text('Logout',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String field, String currentValue,
      Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $field',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values
              .map((role) => RadioListTile<UserRole>(
                    title: Text(userRoleToString(role)),
                    value: role,
                    groupValue: currentRole,
                    onChanged: (value) {
                      if (value != null) {
                        onSave(value);
                        Navigator.pop(context);
                      }
                    },
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
}
