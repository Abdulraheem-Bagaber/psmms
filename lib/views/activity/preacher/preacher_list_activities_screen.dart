import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/activity.dart';
import '../../../viewmodels/preacher_activity_view_model.dart';
import 'preacher_view_activity_screen.dart';
import 'preacher_upload_evidence_screen.dart';

class PreacherListActivitiesScreen extends StatelessWidget {
  final String preacherId;
  final String preacherName;

  const PreacherListActivitiesScreen({
    super.key,
    required this.preacherId,
    required this.preacherName,
  });

  static Widget withProvider({
    required String preacherId,
    required String preacherName,
  }) {
    return ChangeNotifierProvider(
      create: (_) => PreacherActivityViewModel()..loadMyActivities(preacherId),
      child: PreacherListActivitiesScreen(
        preacherId: preacherId,
        preacherName: preacherName,
      ),
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
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          },
        ),
        title: const Text(
          'My Activities',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black87),
                if (viewModel.myActivities
                    .where(
                      (a) =>
                          a.status == 'Approved' ||
                          a.status == 'Approved by MUIP Officer',
                    )
                    .isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showNotifications(context, viewModel);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusTabs(viewModel),
          Expanded(child: _buildContent(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by title or location',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusTabs(PreacherActivityViewModel viewModel) {
    final tabs = [
      {'status': 'Upcoming', 'firebaseStatus': 'Assigned'},
      {'status': 'Pending', 'firebaseStatus': 'Submitted'},
      {'status': 'Approved', 'firebaseStatus': 'Approved'},
      {'status': 'Rejected', 'firebaseStatus': 'Rejected'},
    ];

    // Count activities by status
    final counts = <String, int>{};
    for (var tab in tabs) {
      final status = tab['status']!;
      final firebaseStatus = tab['firebaseStatus']!;

      if (firebaseStatus == 'Approved') {
        counts[status] =
            viewModel.myActivities
                .where(
                  (a) =>
                      a.status == 'Approved' ||
                      a.status == 'Approved by MUIP Officer',
                )
                .length;
      } else {
        counts[status] =
            viewModel.myActivities
                .where((a) => a.status == firebaseStatus)
                .length;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              tabs.map((tab) {
                final status = tab['status']!;
                final isSelected = viewModel.myActivitiesStatus == status;
                final count = counts[status] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => viewModel.onMyActivitiesStatusChanged(status),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF0066FF)
                                : const Color(0xFFEFF1F3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        count > 0 ? '$status ($count)' : status,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PreacherActivityViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadMyActivities(preacherId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.myActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No activities found.\nPreacher ID: $preacherId\nStatus: ${viewModel.myActivitiesStatus}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadMyActivities(preacherId),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadMyActivities(preacherId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.myActivities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(
            context,
            viewModel,
            viewModel.myActivities[index],
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    PreacherActivityViewModel viewModel,
    Activity activity,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge at top left inside card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                _buildStatusDot(activity.status),
                const SizedBox(width: 8),
                Text(
                  _getStatusLabel(activity.status).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(activity.status),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Activity icon
                _getActivityIcon(activity.title),
                const SizedBox(width: 12),

                // Middle - Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date
                      Text(
                        _formatDate(activity.activityDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Location
                      Text(
                        activity.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right side - Action icon
                _buildActionIcon(activity.status),
              ],
            ),
          ),

          // Action button at bottom
          if (activity.status == 'Assigned')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PreacherViewActivityScreen.withProvider(
                                  activity: activity,
                                ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066FF),
                        side: const BorderSide(
                          color: Color(0xFF0066FF),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    PreacherUploadEvidenceScreen.withProvider(
                                      activity: activity,
                                      preacherId: preacherId,
                                      preacherName: preacherName,
                                    ),
                          ),
                        );
                        if (result == true) {
                          viewModel.loadMyActivities(preacherId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (activity.status == 'Submitted' ||
              activity.status == 'Approved' ||
              activity.status == 'Approved by MUIP Officer')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PreacherViewActivityScreen.withProvider(
                              activity: activity,
                            ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color bgColor;
    Color dotColor;
    String label;

    switch (status) {
      case 'Assigned':
        bgColor = const Color(0xFFDEEBFF);
        dotColor = const Color(0xFF0066FF);
        label = 'UPCOMING';
        break;
      case 'Submitted':
        bgColor = const Color(0xFFFFF4E5);
        dotColor = const Color(0xFFFF9800);
        label = 'PENDING';
        break;
      case 'Approved':
      case 'Approved by MUIP Officer':
        bgColor = const Color(0xFFE7F5ED);
        dotColor = const Color(0xFF4CAF50);
        label = 'APPROVED';
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFFEBEE);
        dotColor = const Color(0xFFF44336);
        label = 'REJECTED';
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        dotColor = const Color(0xFF9E9E9E);
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dotColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String status) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assigned':
        return const Color(0xFF0066FF);
      case 'Submitted':
        return const Color(0xFFFF9800);
      case 'Approved':
      case 'Approved by MUIP Officer':
        return const Color(0xFF4CAF50);
      case 'Rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Assigned':
        return 'Upcoming';
      case 'Submitted':
        return 'Pending';
      case 'Approved':
      case 'Approved by MUIP Officer':
        return 'Approved';
      case 'Rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Widget _buildActionIcon(String status) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'Assigned':
        bgColor = const Color(0xFF1E3A8A);
        iconColor = Colors.white;
        icon = Icons.description_outlined;
        break;
      case 'Submitted':
        bgColor = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF0066FF);
        icon = Icons.visibility_outlined;
        break;
      case 'Approved':
      case 'Approved by MUIP Officer':
        bgColor = const Color(0xFF1E3A8A);
        iconColor = Colors.white;
        icon = Icons.description_outlined;
        break;
      case 'Rejected':
        bgColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFF44336);
        icon = Icons.edit_outlined;
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        iconColor = const Color(0xFF64748B);
        icon = Icons.info_outline;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _getActivityIcon(String title) {
    IconData icon;
    Color color;

    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('sermon') || lowerTitle.contains('friday')) {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF1E293B);
    } else if (lowerTitle.contains('youth') ||
        lowerTitle.contains('mentorship')) {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF1E293B);
    } else if (lowerTitle.contains('charity') || lowerTitle.contains('drive')) {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF1E293B);
    } else if (lowerTitle.contains('community') ||
        lowerTitle.contains('outreach')) {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF1E293B);
    } else {
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF1E293B);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }

  String _formatDate(DateTime date) {
    final day = DateFormat('dd').format(date);
    final month = DateFormat('MMM').format(date);
    final year = DateFormat('yyyy').format(date);
    final time = DateFormat('h:mm a').format(date);
    return '$day $month $year, $time';
  }

  void _showNotifications(
    BuildContext context,
    PreacherActivityViewModel viewModel,
  ) {
    final approvedActivities =
        viewModel.myActivities
            .where(
              (a) =>
                  a.status == 'Approved' ||
                  a.status == 'Approved by MUIP Officer',
            )
            .toList();

    final upcomingActivities =
        viewModel.myActivities
            .where(
              (a) =>
                  a.status == 'Assigned' &&
                  a.activityDate.isAfter(DateTime.now()) &&
                  a.activityDate.isBefore(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
            )
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Color(0xFF0066FF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (approvedActivities.isNotEmpty) ...[
                        _buildNotificationSection(
                          'Approved Activities',
                          'Your activities have been approved',
                          Icons.check_circle_outline,
                          const Color(0xFF4CAF50),
                          approvedActivities.length,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (upcomingActivities.isNotEmpty) ...[
                        _buildNotificationSection(
                          'Upcoming Activities',
                          'You have activities starting soon',
                          Icons.calendar_today_outlined,
                          const Color(0xFF0066FF),
                          upcomingActivities.length,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (approvedActivities.isEmpty &&
                          upcomingActivities.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Color(0xFFCBD5E1),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No notifications',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildNotificationSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int count,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
