import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/activity.dart';
import '../../viewmodels/preacher_controller.dart';
import 'preacher_edit_form_page.dart';

class PreacherDetailScreen extends StatelessWidget {
  const PreacherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PreacherController>();
    final preacher = controller.selected;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Preacher Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0066FF)),
            onPressed:
                preacher == null
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: PreacherEditFormPage(preacher: preacher),
                              ),
                        ),
                      );
                    },
            tooltip: 'Edit Preacher',
          ),
        ],
      ),
      body:
          preacher == null
              ? const Center(child: Text('No preacher selected'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(preacher),
                    const SizedBox(height: 16),
                    _skills(preacher.specialization, preacher.skills),
                    const SizedBox(height: 16),
                    _metricsCard(controller),
                    const SizedBox(height: 16),
                    _paymentsCard(controller),
                    const SizedBox(height: 16),
                    _trainingScheduleSection(controller),
                  ],
                ),
              ),
    );
  }

  Widget _header(preacher) {
    Color badgeBg;
    Color badgeText;
    if (preacher.status == 'Active') {
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF166534);
    } else {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFB91C1C);
    }

    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Text(
              _initials(preacher.fullName),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0369A1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preacher.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preacher.preacherId,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  preacher.region,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (preacher.bio != null && preacher.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    preacher.bio!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              preacher.status,
              style: TextStyle(
                color: badgeText,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skills(List<String> spec, List<String> skills) {
    return Container(
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
          const Text(
            'Specializations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                spec
                    .map(
                      (s) => _chip(
                        text: s,
                        color: const Color(0xFFE0E7FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Skills',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                skills
                    .map(
                      (s) => _chip(
                        text: s,
                        color: const Color(0xFFECFEFF),
                        textColor: const Color(0xFF0EA5E9),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _metricsCard(PreacherController controller) {
    if (controller.isDetailLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.detailError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: Text(controller.detailError!),
      );
    }
    final metrics = controller.metrics;
    if (metrics == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: const Text('No metrics available'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                label: 'Activities',
                value: metrics.totalActivities.toString(),
              ),
              _metric(
                label: 'Approved',
                value: metrics.approvedActivities.toString(),
              ),
              _metric(
                label: 'Rejected',
                value: metrics.rejectedActivities.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                label: 'Submitted',
                value: metrics.submittedActivities.toString(),
              ),
              _metric(
                label: 'Approval Rate',
                value: '${metrics.approvalRate.toStringAsFixed(1)}%',
              ),
              _metric(
                label: 'Total Paid',
                value: 'RM ${metrics.totalPayments.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentsCard(PreacherController controller) {
    final metrics = controller.metrics;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                label: 'Total',
                value:
                    metrics == null
                        ? '-'
                        : 'RM ${metrics.totalPayments.toStringAsFixed(2)}',
              ),
              _metric(
                label: 'Last Payment',
                value:
                    metrics?.lastPaymentDate == null
                        ? '-'
                        : DateFormat(
                          'dd MMM yyyy',
                        ).format(metrics!.lastPaymentDate!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trainingScheduleSection(PreacherController controller) {
    if (controller.isTrainingLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.trainingError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card,
        child: Text(controller.trainingError!),
      );
    }

    final schedules = controller.trainingSchedules;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming =
        schedules.where((a) => !a.activityDate.isBefore(today)).toList();
    final completed =
        schedules.where((a) => a.activityDate.isBefore(today)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card,
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Schedules',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                tabs: [Tab(text: 'Upcoming'), Tab(text: 'Completed')],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: TabBarView(
                children: [
                  _scheduleList(upcoming, emptyLabel: 'No upcoming trainings'),
                  _scheduleList(
                    completed,
                    emptyLabel: 'No completed trainings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleList(List<Activity> items, {required String emptyLabel}) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _trainingTile(items[index]),
    );
  }

  Widget _trainingTile(Activity activity) {
    final dateText = DateFormat('dd MMM yyyy').format(activity.activityDate);
    final timeRange =
        activity.startTime.isNotEmpty && activity.endTime.isNotEmpty
            ? '${activity.startTime} - ${activity.endTime}'
            : 'Time not set';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd').format(activity.activityDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(activity.activityDate),
                  style: const TextStyle(color: Color(0xFF0369A1)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      timeRange,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: TextStyle(color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusChip(activity.status),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'Approved':
      case 'Available':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF166534);
        break;
      case 'Submitted':
      case 'Assigned':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF1D4ED8);
        break;
      case 'Rejected':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        text = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _metric({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  BoxDecoration get _card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
