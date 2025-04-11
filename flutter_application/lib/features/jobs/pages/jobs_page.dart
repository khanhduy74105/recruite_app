import 'package:flutter/material.dart';
import 'package:flutter_application/features/post/repository/job_repository.dart';
import 'package:flutter_application/features/post/widgets/job_card.dart';
import 'package:flutter_application/models/job_model.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  List<JobModel> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    await Future.delayed(const Duration(seconds: 2));
    jobs = await JobRepository().fetchJobs();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: JobCard(
                    job: job
                  ),
                );
              },
            ),
    );
  }
}