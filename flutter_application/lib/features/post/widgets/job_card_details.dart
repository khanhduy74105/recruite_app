import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/env.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/post/widgets/resume_analysis.dart';
import 'package:flutter_application/models/job_application_model.dart';
import 'package:flutter_application/models/job_model.dart';
import 'package:flutter_application/models/resume_model.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class JobCardDetails extends StatelessWidget {
  final JobModel job;

  const JobCardDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        job.creator == Supabase.instance.client.auth.currentUser?.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(job.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Apply'),
            ],
          ),
          actions: [
            if (isCurrentUser)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
        body: TabBarView(
          children: [
            JobDetailsTab(job: job),
            ApplyTabContent(job: job),
          ],
        ),
      ),
    );
  }
}

class JobDetailsTab extends StatelessWidget {
  final JobModel job;

  const JobDetailsTab({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Company: ${job.companyName}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Location: ${job.location}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Posted by: ${job.userModel?.fullName ?? "Unknown"}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Description:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            style: const TextStyle(fontSize: 16),
          ),
          if (job.jdUrls.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attachments:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...job.jdUrls.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        String urlPath = SupabaseService.getUrl(url);
                        if (await canLaunchUrl(Uri.parse(urlPath))) {
                          await launchUrl(Uri.parse(urlPath),
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not download now')),
                          );
                        }
                      },
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

class ApplicationListTile extends StatelessWidget {
  final Map application;

  const ApplicationListTile({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(application['user'].fullName),
      subtitle: Text('Headline: ${application['user'].headline}'),
      trailing: application['score'] != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 25.0,
                  lineWidth: 4.0,
                  percent: application['score']['total_score'] / 100,
                  center: Text("${application['score']['total_score']}%"),
                  progressColor: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ResumeAnalysis(analysisData: application['score']);
                    }));
                  },
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}

class ApplyTabContent extends StatefulWidget {
  const ApplyTabContent({
    super.key,
    required this.job,
  });

  final JobModel job;

  @override
  State<ApplyTabContent> createState() => _ApplyTabContentState();
}

class _ApplyTabContentState extends State<ApplyTabContent> {
  bool hasApplied = false;
  List<Map> applicationsData = [];

  @override
  void initState() {
    super.initState();
    _initializeAppliedStatus();
    _fetchApplicationsData();
  }

  Future<void> _initializeAppliedStatus() async {
    hasApplied = await checkAppliedStatus();
    setState(() {});
  }

  Future<void> _fetchApplicationsData() async {
    _fetchApplicationsIfCreator();
  }

  Future<void> _fetchApplicationsIfCreator() async {
    String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == widget.job.creator) {
      final response =
          await Supabase.instance.client.from('job_application').select("""
          *,
            user:user_id(*)
          """).eq('job_id', widget.job.id);

      if (response.isNotEmpty) {
        for (var application in response) {
          final res = await Supabase.instance.client
              .from('resume')
              .select()
              .eq('user_id', application['user_id']);
          if (res.isNotEmpty) {
            application['resume'] = ResumeModel.fromJson(res[0]);
            application['user'] = UserModel.fromJson(application['user']);
          } else {
            application['resume'] = null;
          }
          applicationsData.add(application);
        }
      }
    }
    getResumeScores();
    setState(() {});
  }

  Future<File> downloadPdfFile(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final uniqueFileName = 'jd_${const Uuid().v4()}.pdf';
      final filePath = '${tempDir.path}/$uniqueFileName';

      final dio = Dio.Dio();
      await dio.download(
        url,
        filePath,
        options: Dio.Options(responseType: Dio.ResponseType.bytes),
      );

      return File(filePath);
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  Future<void> getResumeScores() async {
    List<dynamic> resumesData = applicationsData.map((e) {
      Map a = jsonDecode(e['resume'].data);
      a['id'] = e['user'].id;
      return a;
    }).toList();
    String jobDescription = widget.job.description;

    String extractedJobDescription = jobDescription;

    if (widget.job.jdUrls.isNotEmpty) {
      for (var url in widget.job.jdUrls) {
        String urlPath = SupabaseService.getUrl(url, bucket: 'jd');
        try {
          File file = await downloadPdfFile(urlPath);
          Dio.FormData formData = Dio.FormData.fromMap({
            'job_description': await Dio.MultipartFile.fromFile(file.path),
          });
          final responeExtractJd = await Dio.Dio().post(
            '${Env.beUrl}/extract_job_description',
            data: formData,
            options: Dio.Options(
              headers: {
                'Content-Type': 'application/json',
              },
            ),
          );

          extractedJobDescription += responeExtractJd.data['text'];
        } catch (e) {
          debugPrint('Error downloading or extracting text from PDF: $e');
        }
      }
    }

    Map<String, dynamic> body = {
      'resumes_data': jsonEncode(resumesData),
      'job_description': jsonEncode(extractedJobDescription),
    };

    try {
      final respone = await Dio.Dio().post(
        '${Env.beUrl}/resume_scores',
        data: jsonEncode(body),
        options: Dio.Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (respone.statusCode == 200) {
        List<dynamic> scores = respone.data['scores'];
        for (int i = 0; i < applicationsData.length; i++) {
          final temporaryApplication = applicationsData[i];
          for (int j = 0; j < scores.length; j++) {
            if (temporaryApplication['user'].id == scores[j]['id']) {
              applicationsData[i]['score'] = scores[j];
            }
          }
        }
        setState(() {});
      } else {
        debugPrint('Error: ${respone.statusCode} - ${respone.data}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<ResumeModel?> getCurrentResume() async {
    String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      final response = await Supabase.instance.client
          .from('resume')
          .select()
          .eq('user_id', currentUserId);
      if (response.isNotEmpty) {
        return ResumeModel.fromJson(response[0]);
      } else {
        return null;
      }
    }
    return null;
  }

  Future<bool> checkAppliedStatus() async {
    String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      final response = await Supabase.instance.client
          .from('job_application')
          .select()
          .eq('user_id', currentUserId)
          .eq('job_id', widget.job.id);
      return response.isNotEmpty;
    }
    return false;
  }

  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> removeApplication() async {
    String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      await Supabase.instance.client
          .from('job_application')
          .delete()
          .eq('user_id', currentUserId)
          .eq('job_id', widget.job.id);

      setState(() {
        hasApplied = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application removed successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == widget.job.creator) {
      return applicationsData.isEmpty
          ? const Center(
              child: Text('No applications for this job yet.'),
            )
          : ListView.builder(
              itemCount: applicationsData.length,
              itemBuilder: (context, index) {
                final application = applicationsData[index];
                return ApplicationListTile(application: application);
              },
            );
    }

    return hasApplied
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You have already applied for this job.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'Remove Application',
                    content:
                        'Are you sure you want to remove your application?',
                    onConfirm: removeApplication,
                  );
                },
                child: const Text('Remove Application'),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Apply for this job',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'Apply for Job',
                    content: 'Are you sure you want to apply for this job?',
                    onConfirm: () async {
                      ResumeModel? resume = await getCurrentResume();
                      if (resume == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('No resume found! Please upload one.'),
                          ),
                        );
                        return;
                      }

                      await Supabase.instance.client
                          .from('job_application')
                          .insert({
                        'user_id': currentUserId,
                        'job_id': widget.job.id,
                        'status': ApplicationStatus.applied.name,
                      });

                      setState(() {
                        hasApplied = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application submitted successfully!'),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Apply Now'),
              ),
            ],
          );
  }
}
