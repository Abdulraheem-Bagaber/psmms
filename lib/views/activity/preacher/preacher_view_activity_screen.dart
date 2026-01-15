import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/activity.dart';
import '../../../models/activity_submission.dart';
import '../../../viewmodels/preacher_activity_view_model.dart';
import 'preacher_upload_evidence_screen.dart';

class PreacherViewActivityScreen extends StatelessWidget {
  final Activity activity;

  const PreacherViewActivityScreen({super.key, required this.activity});

  static Widget withProvider({required Activity activity}) {
    return ChangeNotifierProvider(
      create: (_) => PreacherActivityViewModel(),
      child: PreacherViewActivityScreen(activity: activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreacherActivityViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Activity Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Status Badge
                    _buildStatusBadge(activity.status),
                    const SizedBox(height: 20),
                    
                    // Schedule
                    _buildSectionLabel('Schedule'),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('dd MMMM yyyy').format(activity.activityDate)}, ${activity.startTime} - ${activity.endTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Topic
                    _buildSectionLabel('Topic'),
                    const SizedBox(height: 8),
                    Text(
                      activity.topic,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Location
                    _buildSectionLabel('Location'),
                    const SizedBox(height: 8),
                    Text(
                      '${activity.location}${activity.venue.isNotEmpty ? ', ${activity.venue}' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Map Image with Button
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(activity.location)}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D7377), Color(0xFF14FFEC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Decorative elements
                            Positioned(
                              top: 20,
                              right: 30,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 30,
                              left: 20,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            // Mosque icon
                            Center(
                              child: Icon(
                                Icons.mosque_outlined,
                                size: 80,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            // Pin marker on top
                            Positioned(
                              top: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.yellow.shade700,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(activity.location)}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.map_outlined,
                              color: Color(0xFF0066FF),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'View on Map',
                              style: TextStyle(
                                color: Color(0xFF0066FF),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (activity.specialRequirements.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSectionLabel('Special Instructions'),
                      const SizedBox(height: 8),
                      Text(
                        activity.specialRequirements,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.6,
                        ),
                      ),
                    ],
                    
                    if (activity.status == 'Submitted') ...[
                      const SizedBox(height: 20),
                      FutureBuilder<ActivitySubmission?>(
                        future: viewModel.getActivitySubmission(activity.activityId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return _buildSubmissionCard(snapshot.data!);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom button
          if (activity.status == 'Assigned')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreacherUploadEvidenceScreen.withProvider(
                          activity: activity,
                          preacherId: activity.assignedPreacherId ?? '',
                          preacherName: activity.assignedPreacherName ?? '',
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText = status;

    switch (status) {
      case 'Assigned':
        bgColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        break;
      case 'Submitted':
        bgColor = const Color(0xFFFFF4E5);
        textColor = const Color(0xFFFF9800);
        displayText = 'Pending Review';
        break;
      case 'Approved':
        bgColor = const Color(0xFFE7F5ED);
        textColor = const Color(0xFF4CAF50);
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFF44336);
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(ActivitySubmission submission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Evidence Photos'),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: submission.photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(submission.photoUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Submitted: ${DateFormat('dd MMM yyyy, h:mm a').format(submission.submittedAt)}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
