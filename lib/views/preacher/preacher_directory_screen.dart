import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/preacher.dart';
import '../../viewmodels/preacher_controller.dart';
import 'preacher_detail_screen.dart';

class PreacherDirectoryScreen extends StatelessWidget {
  const PreacherDirectoryScreen({super.key});

  static Widget withProvider() {
    return ChangeNotifierProvider(
      create: (_) => PreacherController()..loadInitial(),
      child: const PreacherDirectoryScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PreacherController>();

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
          'Preacher Directory',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildFilters(controller),
          Expanded(child: _buildList(context, controller)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PreacherController controller) {
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
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
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

  Widget _buildFilters(PreacherController controller) {
    final regions = const ['All', 'North', 'Central', 'South', 'East', 'West'];
    final specs = const ['All', 'Youth', 'Family', 'Education', 'Counseling'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.region,
              items:
                  regions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
              onChanged: (val) {
                if (val != null) controller.onRegionChanged(val);
              },
              decoration: InputDecoration(
                labelText: 'Region',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.specialization,
              items:
                  specs
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (val) {
                if (val != null) controller.onSpecializationChanged(val);
              },
              decoration: InputDecoration(
                labelText: 'Specialization',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, PreacherController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(child: Text(controller.error!));
    }
    if (controller.items.isEmpty) {
      return const Center(child: Text('No preachers found for this filter.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200 &&
            controller.hasMore &&
            !controller.isLoadingMore) {
          controller.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: controller.loadInitial,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final preacher = controller.items[index];
            return _buildCard(context, controller, preacher);
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    PreacherController controller,
    Preacher preacher,
  ) {
    final initials = _initials(preacher.fullName);
    final approvalRate =
        preacher.completedActivities == 0
            ? 0
            : (preacher.approvedActivities / preacher.completedActivities * 100)
                .round();

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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(
                  initials,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${preacher.region} • ${preacher.preacherId}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                preacher.specialization
                    .take(3)
                    .map(
                      (s) => _chip(
                        text: s,
                        color: const Color(0xFFE0E7FF),
                        textColor: const Color(0xFF4338CA),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                label: 'Completed',
                value: preacher.completedActivities.toString(),
              ),
              _metric(
                label: 'Approved',
                value: preacher.approvedActivities.toString(),
              ),
              _metric(label: 'Approval', value: '$approvalRate%'),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await controller.selectPreacher(preacher);
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => ChangeNotifierProvider.value(
                            value: controller,
                            child: const PreacherDetailScreen(),
                          ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View Profile'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0066FF),
              ),
            ),
          ),
        ],
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
}
