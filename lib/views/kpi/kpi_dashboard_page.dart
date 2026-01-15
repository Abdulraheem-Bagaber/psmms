import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/kpi_controller.dart';
import '../../models/kpi_progress.dart';

/// Preacher view: Display KPI targets and real-time progress
class KPIDashboardPage extends StatefulWidget {
  final String? preacherId;

  const KPIDashboardPage({super.key, this.preacherId});

  @override
  State<KPIDashboardPage> createState() => _KPIDashboardPageState();
}

class _KPIDashboardPageState extends State<KPIDashboardPage> {
  String _selectedPeriod = 'Monthly';
  String? _selectedPreacherId;

  @override
  void initState() {
    super.initState();
    _selectedPreacherId = widget.preacherId;

    // If preacher ID is provided, load progress
    if (_selectedPreacherId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<KPIController>().loadPreacherProgress(
          _selectedPreacherId!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text(
              'My KPI Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              if (_selectedPreacherId != null) {
                context.read<KPIController>().loadPreacherProgress(
                  _selectedPreacherId!,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<KPIController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Exception Flow: No KPIs Set
          if (controller.error != null && controller.currentKPI == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No KPI Targets Set',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your MUIP officer has not set KPI targets for you yet. Please contact your officer to create your performance targets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Info:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Searching for: ${_selectedPreacherId ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Error: ${controller.error ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
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

          final kpi = controller.currentKPI;
          final progress = controller.currentProgress;

          if (kpi == null || progress == null) {
            return const Center(child: Text('No data available'));
          }

          final overallProgress = controller.calculateOverallProgress();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Performance Status Card
                _buildPerformanceCard(progress, context),

                // Header Card with Overall Progress
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${overallProgress.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStatusText(overallProgress),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (progress.ranking > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.leaderboard, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Rank #${progress.ranking}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Period Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildPeriodChip('Monthly', _selectedPeriod == 'Monthly'),
                      const SizedBox(width: 12),
                      _buildPeriodChip(
                        'Quarterly',
                        _selectedPeriod == 'Quarterly',
                      ),
                      const SizedBox(width: 12),
                      _buildPeriodChip('Yearly', _selectedPeriod == 'Yearly'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // KPI Metrics Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildKPICard(
                        title: 'Monthly Sermons Delivered',
                        current: progress.sessionsCompleted,
                        target: kpi.monthlySessionTarget,
                        icon: Icons.mic,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'Total Attendance',
                        current: progress.totalAttendanceAchieved,
                        target: kpi.totalAttendanceTarget,
                        icon: Icons.people,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'New Member Registrations',
                        current: progress.newConvertsAchieved,
                        target: kpi.newConvertsTarget,
                        icon: Icons.person_add,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'Baptisms Performed',
                        current: progress.baptismsAchieved,
                        target: kpi.baptismsTarget,
                        icon: Icons.water_drop,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'Community Projects',
                        current: progress.communityProjectsAchieved,
                        target: kpi.communityProjectsTarget,
                        icon: Icons.handshake,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'Charity Events Organized',
                        current: progress.charityEventsAchieved,
                        target: kpi.charityEventsTarget,
                        icon: Icons.volunteer_activism,
                      ),
                      const SizedBox(height: 12),
                      _buildKPICard(
                        title: 'Youth Program Attendance',
                        current: progress.youthProgramAttendanceAchieved,
                        target: kpi.youthProgramAttendanceTarget,
                        icon: Icons.groups,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required int current,
    required int target,
    required IconData icon,
  }) {
    final percentage = (current / target * 100).clamp(0.0, 100.0);
    final statusColor = _getProgressColor(percentage);
    final statusText = _getStatusText(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$current / $target',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(percentage),
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${percentage.toStringAsFixed(1)}% Complete',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF10B981); // Green
    if (percentage >= 50) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  String _getStatusText(double percentage) {
    if (percentage >= 100) return 'Completed';
    if (percentage >= 75) return 'On Track';
    if (percentage >= 50) return 'At Risk';
    return 'Behind';
  }

  IconData _getStatusIcon(double percentage) {
    if (percentage >= 100) return Icons.check_circle;
    if (percentage >= 75) return Icons.check_circle;
    if (percentage >= 50) return Icons.warning;
    return Icons.error;
  }

  /// Build Performance Status Card with Points and Rank
  Widget _buildPerformanceCard(KPIProgress progress, BuildContext context) {
    Color bgColor;
    Color textColor;
    String emoji;
    String statusText;
    
    switch (progress.performanceStatus) {
      case 'excellent':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade900;
        emoji = '🏆';
        statusText = 'EXCELLENT PERFORMANCE';
        break;
      case 'good':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade900;
        emoji = '✅';
        statusText = 'GOOD PERFORMANCE';
        break;
      case 'warning':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        emoji = '⚠️';
        statusText = 'WARNING - NEEDS IMPROVEMENT';
        break;
      case 'critical':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        emoji = '🚨';
        statusText = 'CRITICAL - URGENT ATTENTION';
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade900;
        emoji = 'ℹ️';
        statusText = 'NO EVALUATION YET';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: textColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${progress.performancePoints} Points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (progress.ranking > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• Rank #${progress.ranking}',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (progress.performanceStatus == 'excellent')
                const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            ],
          ),
          if (progress.overallPercentage > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                progress.performanceStatus == 'excellent'
                    ? 'MashaAllah! Outstanding work! You have achieved ${progress.overallPercentage.toStringAsFixed(1)}% of your targets!'
                    : progress.performanceStatus == 'good'
                        ? 'Good effort! You are at ${progress.overallPercentage.toStringAsFixed(1)}%. Keep pushing forward!'
                        : progress.performanceStatus == 'warning'
                            ? 'You need to improve! Currently at ${progress.overallPercentage.toStringAsFixed(1)}%. Please increase your efforts.'
                            : 'Critical status! Only ${progress.overallPercentage.toStringAsFixed(1)}% completed. Contact your officer immediately.',
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final kpiController = context.read<KPIController>();
              await kpiController.calculatePerformance(_selectedPreacherId!);
              setState(() {}); // Refresh UI
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Update Performance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
