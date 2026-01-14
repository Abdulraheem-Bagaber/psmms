import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import '../../../models/activity.dart';
import '../../../viewmodels/officer_activity_view_model.dart';
import 'officer_add_activity_screen.dart';
import 'officer_view_activity_screen.dart';
import 'officer_edit_activity_screen.dart';

class OfficerListActivitiesScreen extends StatelessWidget {
  const OfficerListActivitiesScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => OfficerActivityViewModel()..loadActivities(),
      child: const OfficerListActivitiesScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OfficerActivityViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Activities',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [_buildNotificationButton(context)],
      ),
      body: Column(
        children: [
          _buildSearchBar(viewModel),
          _buildFilterTabs(viewModel),
          Expanded(child: _buildContent(context, viewModel)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfficerAddActivityScreen.withProvider(),
            ),
          );
          if (result == true) {
            viewModel.loadActivities();
          }
        },
        backgroundColor: const Color(0xFF0066FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(OfficerActivityViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: viewModel.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by title, preacher...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(OfficerActivityViewModel viewModel) {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children:
            filters.map((filter) {
              final isSelected = viewModel.statusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => viewModel.onStatusFilterChanged(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF0066FF)
                              : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OfficerActivityViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.activities.isEmpty) {
      return const Center(child: Text('No activities found.'));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadActivities(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: viewModel.activities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(
            context,
            viewModel,
            viewModel.activities[index],
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    OfficerActivityViewModel viewModel,
    Activity activity,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(activity.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity.assignedPreacherName ?? 'Not assigned',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity.location,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(activity.activityDate),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OfficerViewActivityScreen.withProvider(
                            activity: activity,
                          ),
                    ),
                  );
                  if (result == true) {
                    viewModel.loadActivities();
                  }
                },
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OfficerEditActivityScreen.withProvider(
                            activity: activity,
                          ),
                    ),
                  );
                  if (result == true) {
                    viewModel.loadActivities();
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed:
                    () => _showDeleteConfirmation(context, viewModel, activity),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Available':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0369A1);
        break;
      case 'Assigned':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'Submitted':
        bgColor = const Color(0xFFFFF4CC);
        textColor = const Color(0xFFB58100);
        break;
      case 'Approved':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    OfficerActivityViewModel viewModel,
    Activity activity,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Activity'),
            content: Text(
              'Are you sure you want to delete "${activity.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await viewModel.deleteActivity(activity.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Activity deleted'
                              : 'Failed to delete activity',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getNotificationCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
              onPressed: () => _showNotifications(context),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Stream<int> _getNotificationCountStream() {
    final db = FirebaseFirestore.instance;

    final assignedStream = db
        .collection('activities')
        .where('status', isEqualTo: 'Assigned')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    final submissionsStream = db
        .collection('activity_submissions')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    final paymentsStream = db
        .collection('payments')
        .where('status', isEqualTo: 'Pending Payment')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    return StreamZip([
      assignedStream,
      submissionsStream,
      paymentsStream,
    ]).map((values) => values.fold<int>(0, (sum, count) => sum + count));
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildNotificationSection(
                              context,
                              'Activity Assignments',
                              Icons.check_circle,
                              Colors.green,
                              FirebaseFirestore.instance
                                  .collection('activities')
                                  .where('status', isEqualTo: 'Assigned')
                                  .snapshots(),
                            ),
                            _buildNotificationSection(
                              context,
                              'Evidence Submissions',
                              Icons.assignment,
                              Colors.orange,
                              FirebaseFirestore.instance
                                  .collection('activity_submissions')
                                  .where('status', isEqualTo: 'Pending')
                                  .snapshots(),
                            ),
                            _buildNotificationSection(
                              context,
                              'Payment Requests',
                              Icons.payment,
                              Colors.blue,
                              FirebaseFirestore.instance
                                  .collection('payments')
                                  .where('status', isEqualTo: 'Pending Payment')
                                  .snapshots(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    Stream<QuerySnapshot> stream,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$title (${docs.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp =
                  data['createdAt'] as Timestamp? ??
                  data['submittedAt'] as Timestamp? ??
                  Timestamp.now();

              return _buildNotificationItem(
                icon: icon,
                iconColor: iconColor,
                title:
                    data['title'] ?? data['activityId'] ?? 'New notification',
                message: _getNotificationMessage(title, data),
                time: _getTimeAgo(timestamp.toDate()),
                isUnread: true,
                onTap: () {
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String _getNotificationMessage(String section, Map<String, dynamic> data) {
    if (section.contains('Assignment')) {
      return 'Assigned to ${data['assignedPreacherName'] ?? 'preacher'}';
    } else if (section.contains('Submission')) {
      return 'Evidence submitted by ${data['preacherName'] ?? 'preacher'}';
    } else if (section.contains('Payment')) {
      return 'Payment request for RM ${data['amount'] ?? '0.00'}';
    }
    return 'New notification';
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hour(s) ago';
    if (difference.inDays < 7) return '${difference.inDays} day(s) ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
