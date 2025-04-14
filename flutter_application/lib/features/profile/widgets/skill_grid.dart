import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/skill_model.dart';
import '../../../models/user_skill_model.dart';

class SkillsState extends Equatable {
  final List<UserSkillModel> userSkills;
  final String? selectedSkillId;
  final bool isLoading;
  final String? error;

  const SkillsState({
    this.userSkills = const [],
    this.selectedSkillId,
    this.isLoading = false,
    this.error,
  });

  SkillsState copyWith({
    List<UserSkillModel>? userSkills,
    String? selectedSkillId,
    bool? isLoading,
    String? error,
  }) {
    return SkillsState(
      userSkills: userSkills ?? this.userSkills,
      selectedSkillId: selectedSkillId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [userSkills, selectedSkillId, isLoading, error];
}

class SkillsCubit extends Cubit<SkillsState> {
  final String userId;
  final SupabaseClient supabaseClient;

  SkillsCubit({
    required this.userId,
    required this.supabaseClient,
  }) : super(const SkillsState()) {
    fetchUserSkills();
  }

  String getSkillImageUrl(SkillModel skill) {
    return supabaseClient.storage
        .from('images')
        .getPublicUrl('skill/${skill.imgIllustrationLink}');
  }

  String formatYearExp(double yearExp) {
    final years = yearExp.floor();
    final months = ((yearExp - years) * 12).round();
    if (years == 0 && months == 0) return 'No experience';
    if (years == 0) return '$months month${months == 1 ? '' : 's'}';
    if (months == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years year${years == 1 ? '' : 's'} $months month${months == 1 ? '' : 's'}';
  }

  Future<void> fetchUserSkills() async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await supabaseClient
          .from('user_skill')
          .select('*, skill(*)')
          .eq('user_id', userId);
      final userSkills = response.map((json) {
        final skill = SkillModel.fromJson(json['skill']);
        return UserSkillModel.fromJson(json, skill);
      }).toList();
      emit(state.copyWith(userSkills: userSkills, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<SkillModel>> fetchAvailableSkills() async {
    try {
      final response = await supabaseClient.from('skill').select();
      return response.map((json) => SkillModel.fromJson(json)).toList();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return [];
    }
  }

  void selectSkillForDeletion(String skillId) {
    emit(state.copyWith(selectedSkillId: skillId));
  }

  void clearSelection() {
    emit(state.copyWith(selectedSkillId: null));
  }

  Future<void> addUserSkill(SkillModel skill, int level, double yearExp) async {
    try {
      final newUserSkill = UserSkillModel(
        userId: userId,
        skillId: skill.id,
        level: level,
        yearExp: yearExp,
        skill: skill,
      );
      await supabaseClient.from('user_skill').insert({
        'user_id': userId,
        'skill_id': skill.id,
        'level': level,
        'year_exp': yearExp,
      });
      emit(state.copyWith(
        userSkills: [...state.userSkills, newUserSkill],
        selectedSkillId: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateUserSkill(UserSkillModel userSkill) async {
    try {
      await supabaseClient
          .from('user_skill')
          .update({
            'level': userSkill.level,
            'year_exp': userSkill.yearExp,
          })
          .eq('user_id', userSkill.userId)
          .eq('skill_id', userSkill.skillId);
      final updatedSkills = state.userSkills.map((skill) {
        return skill.skillId == userSkill.skillId ? userSkill : skill;
      }).toList();
      emit(state.copyWith(userSkills: updatedSkills, selectedSkillId: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteUserSkill(String skillId) async {
    try {
      await supabaseClient
          .from('user_skill')
          .delete()
          .eq('user_id', userId)
          .eq('skill_id', skillId);
      final updatedSkills =
          state.userSkills.where((skill) => skill.skillId != skillId).toList();
      emit(state.copyWith(userSkills: updatedSkills, selectedSkillId: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

class SkillsGrid extends StatelessWidget {
  final String userId;

  const SkillsGrid({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillsCubit(
        userId: userId,
        supabaseClient: Supabase.instance.client,
      ),
      child: BlocBuilder<SkillsCubit, SkillsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.userSkills.isEmpty) {
            return const Center(
              child: Text(
                'No skills added yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: state.userSkills.length + 1,
            itemBuilder: (context, index) {
              if (index == state.userSkills.length &&
                  userId == SupabaseService.getCurrentUserId()) {
                return _buildAddSkillCard(context);
              }
              final userSkill = state.userSkills[index];
              return _buildSkillCard(context, userSkill, state);
            },
          );
        },
      ),
    );
  }

  Widget _buildSkillCard(
      BuildContext context, UserSkillModel userSkill, SkillsState state) {
    final cubit = context.read<SkillsCubit>();
    final isSelected = state.selectedSkillId == userSkill.skillId;

    return GestureDetector(
      onTap: () => _showEditSkillDialog(context, userSkill),
      onLongPress: () => cubit.selectSkillForDeletion(userSkill.skillId),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: cubit.getSkillImageUrl(userSkill.skill),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      userSkill.skill.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'Level: ${userSkill.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          'Exp: ${cubit.formatYearExp(userSkill.yearExp)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                    onPressed: () => _confirmDeleteSkill(context, userSkill),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSkillCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAddSkillDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade100,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Add Skill',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSkillDialog(BuildContext context, UserSkillModel userSkill) {
    final cubit = context.read<SkillsCubit>();
    final levelController =
        TextEditingController(text: userSkill.level.toString());
    final yearExpController =
        TextEditingController(text: userSkill.yearExp.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${userSkill.skill.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(
                    labelText: 'Level',
                    hintText: 'Enter skill level (e.g., 1-5)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: yearExpController,
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience',
                    hintText:
                        'Enter as decimal (e.g., 2.5 for 2 years 6 months)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newLevel =
                    int.tryParse(levelController.text) ?? userSkill.level;
                final newYearExp = double.tryParse(yearExpController.text) ??
                    userSkill.yearExp;
                if (newLevel < 1 || newYearExp <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Level must be at least 1 and experience must be greater than 0')),
                  );
                  return;
                }
                final updatedSkill = UserSkillModel(
                  userId: userSkill.userId,
                  skillId: userSkill.skillId,
                  level: newLevel,
                  yearExp: newYearExp,
                  skill: userSkill.skill,
                );
                cubit.updateUserSkill(updatedSkill);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final cubit = context.read<SkillsCubit>();
    SkillModel? selectedSkill;
    final levelController = TextEditingController(text: '1');
    final yearExpController = TextEditingController(text: '0.0');

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<SkillModel>>(
          future: cubit.fetchAvailableSkills(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load skills'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            }

            final availableSkills = snapshot.data!
                .where((skill) =>
                    !cubit.state.userSkills.any((us) => us.skillId == skill.id))
                .toList();

            return AlertDialog(
              title: const Text('Add New Skill'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<SkillModel>(
                      hint: const Text('Select Skill'),
                      isExpanded: true,
                      value: selectedSkill,
                      items: availableSkills.map((skill) {
                        return DropdownMenuItem<SkillModel>(
                          value: skill,
                          child: Text(skill.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedSkill = value;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: levelController,
                      decoration: const InputDecoration(
                        labelText: 'Level',
                        hintText: 'Enter skill level (e.g., 1-5)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: yearExpController,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience',
                        hintText:
                            'Enter as decimal (e.g., 2.5 for 2 years 6 months)',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedSkill == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a skill')),
                      );
                      return;
                    }
                    final level = int.tryParse(levelController.text) ?? 1;
                    final yearExp =
                        double.tryParse(yearExpController.text) ?? 0.0;
                    if (level < 1 || yearExp <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Level must be at least 1 and experience must be greater than 0')),
                      );
                      return;
                    }
                    cubit.addUserSkill(selectedSkill!, level, yearExp);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSkill(BuildContext context, UserSkillModel userSkill) {
    final cubit = context.read<SkillsCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Skill'),
          content:
              Text('Are you sure you want to delete ${userSkill.skill.title}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cubit.deleteUserSkill(userSkill.skillId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
