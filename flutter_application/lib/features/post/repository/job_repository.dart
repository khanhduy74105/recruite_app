import 'dart:convert';
import 'package:flutter_application/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<JobModel> createJob(JobModel jobModel) async {
    try {
      final respones = await supabase.from('job').insert({
        'title': jobModel.title,
        'description': jobModel.description,
        'jd_urls': jsonEncode(jobModel.jdUrls),
        'company_name': jobModel.companyName,
        'location': jobModel.location,
      }).select();
      return JobModel.fromJson(respones[0]);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> updateJob(JobModel jobModel) async {
    try {
      await supabase.from('job').update({
        'title': jobModel.title,
        'description': jobModel.description,
        'jd_urls': jsonEncode(jobModel.jdUrls),
        'company_name': jobModel.companyName,
        'location': jobModel.location,
      }).eq('id', jobModel.id);
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await supabase.from('job').delete().eq('id', jobId);
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<JobModel> fetchJobById(String jobId) async {
    try {
      final response = await supabase
          .from('job')
          .select()
          .eq('id', jobId)
          .single();
      return JobModel.fromJson(response);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<JobModel>> fetchJobs() async {
    try {
      final response = await supabase
          .from('job')
          .select('''
            *,
            user: creator(*)
          ''')
          .order('created_at', ascending: false);
      return (response as List).map((e) => JobModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
}
}