import 'package:flutter/material.dart';

class ResumeAnalysis extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const ResumeAnalysis({super.key, required this.analysisData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Applicant Name: ${analysisData["applicant_name"]}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('ID: ${analysisData["id"]}'),
              const SizedBox(height: 16),
              const Text(
                'Matched Skills:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                children: (analysisData["matched_skills"] as List<dynamic>)
                    .map((skill) => Chip(label: Text(skill)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Missing Skills:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8.0,
                children: (analysisData["missing_skills"] as List<dynamic>)
                    .map((skill) => Chip(label: Text(skill)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Score Breakdown:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: analysisData["score_breakdown"].entries.map<TableRow>((entry) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key.replaceAll('_', ' ').toUpperCase()}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Score: ${analysisData["total_score"]}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
