import 'package:flutter/material.dart';
import 'package:flutter_application/core/utils/format.dart';
import 'package:flutter_application/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application/features/post/widgets/job_card_details.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onClose;
  final VoidCallback? onOpenDetails;

  const JobCard({
    super.key,
    required this.job,
    this.onClose,
    this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClose != null) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobCardDetails(job: job),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${job.title}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Location
                      Text(
                        'Location: ${job.location}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Time Ago
                      Row(
                        children: [
                          Text(
                            timeAgo(job.createdAt),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'by ${job.userModel?.fullName ?? ""}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          if (job.creator == Supabase.instance.client.auth.currentUser?.id)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Mine",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
