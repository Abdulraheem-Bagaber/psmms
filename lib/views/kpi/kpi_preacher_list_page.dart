import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/preacher_controller.dart';
import '../../viewmodels/kpi_controller.dart';
import '../../models/preacher.dart';
import 'kpi_form_page.dart';

/// MUIP Official view: List of all preachers for KPI management
class KPIPreacherListPage extends StatefulWidget {
  const KPIPreacherListPage({super.key});

  @override
  State<KPIPreacherListPage> createState() => _KPIPreacherListPageState();
}

class _KPIPreacherListPageState extends State<KPIPreacherListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load preachers when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreacherController>().loadInitial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text(
          'Manage KPI - Select Preacher',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top Performers Leaderboard
          _buildTopPerformersSection(context),
          const Divider(height: 1),
          // Preacher List
          Expanded(
            child: Consumer<PreacherController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error != null && controller.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(controller.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.loadInitial(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final preachers = controller.items;

                if (preachers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No preachers found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                    'Add preachers to manage their KPIs',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search preachers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) => controller.onSearchChanged(value),
                ),
              ),

              // Preacher List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: preachers.length,
                  itemBuilder: (context, index) {
                    final preacher = preachers[index];
                    return _PreacherCard(
                      preacher: preacher,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider(
                                  create: (_) => KPIController(),
                                  child: KPIFormPage(preacher: preacher),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ), // Consumer
    ), // Expanded
        ], // Column children
      ), // Column (body)
    ); // Scaffold
  }

  /// Build Top Performers Section
  Widget _buildTopPerformersSection(BuildContext context) {
    final kpiController = context.read<KPIController>();
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await kpiController.updateRankings();
                    setState(() {}); // Refresh UI
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: kpiController.getTopPerformers(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No performance data yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                
                final topPerformers = snapshot.data!;
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: topPerformers.length,
                  itemBuilder: (context, index) {
                    final performer = topPerformers[index];
                    return _buildPerformerCard(performer, index + 1);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Build individual performer card
  Widget _buildPerformerCard(Map<String, dynamic> performer, int rank) {
    Color rankColor;
    String rankEmoji;
    
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankEmoji = '🥇';
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankEmoji = '🥈';
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankEmoji = '🥉';
    } else {
      rankColor = Colors.grey.shade400;
      rankEmoji = '#$rank';
    }

    Color statusColor;
    switch (performer['status']) {
      case 'excellent':
        statusColor = Colors.green;
        break;
      case 'good':
        statusColor = Colors.blue;
        break;
      case 'warning':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [rankColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rankEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              performer['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${performer['points']} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${performer['percentage'].toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual Preacher Card Widget
class _PreacherCard extends StatelessWidget {
  final Preacher preacher;
  final VoidCallback onTap;

  const _PreacherCard({required this.preacher, required this.onTap});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getAvatarColor(preacher.fullName),
                  child: Text(
                    _getInitials(preacher.fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Preacher Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preacher.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${preacher.preacherId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preacher.region,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
