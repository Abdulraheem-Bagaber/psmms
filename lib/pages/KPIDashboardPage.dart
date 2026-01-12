// Page: My KPI Dashboard (Preacher View)
// Component Name for SDD: My_KPI_Dashboard_Page.dart
// Package: com.muip.psm.pages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/kpi_controller.dart';
import '../controllers/preacher_controller.dart';

/// Preacher view: Display KPI targets and real-time progress
/// Corresponds to Basic Flow Steps 10-12 and Exception Flow [E2]
class MyKPIDashboardPage extends StatefulWidget {
  final String? preacherId;

  const MyKPIDashboardPage({
    super.key,
    this.preacherId,
  });

  @override
  State<MyKPIDashboardPage> createState() => _MyKPIDashboardPageState();
}

class _MyKPIDashboardPageState extends State<MyKPIDashboardPage> {
  String _selectedPeriod = 'Monthly';
  String? _selectedPreacherId;

  @override
  void initState() {
    super.initState();
    _selectedPreacherId = widget.preacherId;
    
    // If preacher ID is provided, load progress
    if (_selectedPreacherId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<KPIController>().loadPreacherProgress(_selectedPreacherId!);
      });
    } else {
      // For demo purposes, load first preacher
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<PreacherController>().loadPreachers();
        if (context.read<PreacherController>().preachers.isNotEmpty) {
          setState(() {
            _selectedPreacherId = context.read<PreacherController>().preachers.first.id;
          });
          if (mounted) {
            context.read<KPIController>().loadPreacherProgress(_selectedPreacherId!);
          }
        }
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
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<KPIController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Exception Flow [E2]: No KPIs Set
          if (controller.error != null && controller.currentKPI == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.orange[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Go Back'),
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
                // Welcome Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome, Preacher',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Period Selection
                      Row(
                        children: [
                          _buildPeriodChip('Monthly', _selectedPeriod == 'Monthly'),
                          const SizedBox(width: 12),
                          _buildPeriodChip('Quarterly', _selectedPeriod == 'Quarterly'),
                          const SizedBox(width: 12),
                          _buildPeriodChip('Yearly', _selectedPeriod == 'Yearly'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Summary Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Overall Monthly Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Overall Progress Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${overallProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Keep up the great work!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: overallProgress / 100,
                              backgroundColor: Colors.grey[200],
                              color: _getProgressColor(overallProgress),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // KPI Metrics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildKPICard(
                        title: 'Sermons Delivered',
                        current: progress.sessionsCompleted,
                        target: kpi.monthlySessionTarget,
                        icon: Icons.campaign,
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
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // KPI tab selected
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              // Navigate to Dashboard (Home)
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              break;
            case 1:
              // Activities - Show coming soon
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activities page coming soon')),
              );
              break;
            case 2:
              // Already on KPI page
              break;
            case 3:
              // Reports - Show coming soon
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reports page coming soon')),
              );
              break;
            case 4:
              // Profile - Show coming soon
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile page coming soon')),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'KPI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$current / $target (${percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: statusColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getStatusIcon(percentage),
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
}
