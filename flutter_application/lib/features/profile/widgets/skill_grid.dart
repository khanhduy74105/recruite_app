import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/skill_model.dart';
import '../../../models/user_skill_model.dart';

class SkillsState extends Equatable {
  final List<UserSkillModel> userSkills;
  final bool isLoading;
  final String? error;

  const SkillsState({
    this.userSkills = const [],
    this.isLoading = false,
    this.error,
  });

  SkillsState copyWith({
    List<UserSkillModel>? userSkills,
    bool? isLoading,
    String? error,
  }) {
    return SkillsState(
      userSkills: userSkills ?? this.userSkills,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [userSkills, isLoading, error];
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
            itemCount: state.userSkills.length,
            itemBuilder: (context, index) {
              final userSkill = state.userSkills[index];
              return _buildSkillCard(context, userSkill);
            },
          );
        },
      ),
    );
  }

  Widget _buildSkillCard(BuildContext context, UserSkillModel userSkill) {
    final cubit = context.read<SkillsCubit>();

    return Card(
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
        child: Column(
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
                  const Icon(Icons.timer, size: 16, color: Colors.black54),
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
      ),
    );
  }
}