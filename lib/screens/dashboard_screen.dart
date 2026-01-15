import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../views/payment/officer/activity_payments_screen.dart' as officer;
import '../views/payment/admin/approved_payments_screen.dart';
import '../views/activity/officer/officer_list_activities_screen.dart';
import '../views/activity/preacher/preacher_list_activities_screen.dart';
import '../views/activity/preacher/preacher_assign_activity_screen.dart';
import '../views/kpi/kpi_dashboard_page.dart';
import '../views/kpi/kpi_preacher_list_page.dart';
import '../viewmodels/kpi_controller.dart';
import '../viewmodels/preacher_controller.dart';
import '../views/reports/reporting_dashboard_screen.dart';
import '../views/payment/preacher/preacher_payment_history_screen.dart';
import '../views/preacher/preacher_directory_screen.dart';
import 'ProfilePage.dart';
import 'PendingApprovalPage.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userService.getCurrentUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Unable to load user data. Please try logging in again.',
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          body: _buildBody(context, user),
          bottomNavigationBar: _buildBottomNavBar(context, user),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserModel user) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome(user);
      case 1:
        return _buildActivitiesPage(context, user);
      case 2:
        return _buildPaymentsPage(context, user);
      case 3:
        return _buildKPIPage(user);
      case 4:
        return _buildReportsPage(context, user);
      case 5:
        return _buildPreacherManagementPage(user);
      case 6:
        return const PendingApprovalPage();
      case 7:
        return const ProfilePage();
      default:
        return _buildDashboardHome(user);
    }
  }

  Widget _buildDashboardHome(UserModel user) {
    String dashboardTitle = 'Dashboard';
    if (user.isPreacher) {
      dashboardTitle = 'Dashboard';
    } else if (user.isOfficer) {
      dashboardTitle = 'Officer Dashboard';
    } else if (user.isAdmin) {
      dashboardTitle = 'Dashboard';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          dashboardTitle,
          style: const TextStyle(
            color: Color(0xFF1a1a1a),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1a1a1a),
            ),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1a1a1a)),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
              } else if (value == 'switch_role') {
                final userService = UserService();
                final currentUser = await userService.getCurrentUser();
                if (currentUser != null && mounted) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Switch Role (Testing)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRoleTile(
                                context,
                                'Admin',
                                Icons.admin_panel_settings,
                                'admin',
                                currentUser,
                                userService,
                              ),
                              _buildRoleTile(
                                context,
                                'Officer',
                                Icons.work,
                                'officer',
                                currentUser,
                                userService,
                              ),
                              _buildRoleTile(
                                context,
                                'Preacher',
                                Icons.person,
                                'preacher',
                                currentUser,
                                userService,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                  );
                }
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'switch_role',
                    child: Text('Switch Role'),
                  ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(user),
            const SizedBox(height: 32),
            _buildQuickActions(context, user),
            const SizedBox(height: 32),
            _buildRecentActivity(user),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTile(
    BuildContext context,
    String name,
    IconData icon,
    String role,
    UserModel currentUser,
    UserService userService,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF667eea)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          currentUser.role.toLowerCase() == role
              ? const Icon(Icons.check_circle, color: Color(0xFF667eea))
              : null,
      onTap: () async {
        await userService.updateUser(currentUser.copyWith(role: role));
        Navigator.pop(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Role changed to $name'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildQuickStats(UserModel user) {
    if (user.isPreacher) {
      return _buildPreacherStats();
    } else if (user.isOfficer) {
      return _buildOfficerStats();
    } else {
      return _buildAdminStats();
    }
  }

  // Preacher Dashboard - Left Layout
  Widget _buildPreacherStats() {
    return StreamBuilder<UserModel?>(
      stream: UserService().getCurrentUserStream(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = userSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('activities')
                  .where('assignedTo', isEqualTo: user.uid)
                  .snapshots(),
          builder: (context, activitiesSnapshot) {
            final activitiesCount =
                activitiesSnapshot.hasData
                    ? activitiesSnapshot.data!.docs.length
                    : 0;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('payment')
                      .where('preacherId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .limit(1)
                      .snapshots(),
              builder: (context, paymentsSnapshot) {
                final latestPayment =
                    paymentsSnapshot.hasData &&
                            paymentsSnapshot.data!.docs.isNotEmpty
                        ? paymentsSnapshot.data!.docs.first
                        : null;

                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('activity_submissions')
                          .where('preacherId', isEqualTo: user.uid)
                          .where('status', isEqualTo: 'Approved')
                          .snapshots(),
                  builder: (context, submissionsSnapshot) {
                    final completedActivities =
                        submissionsSnapshot.hasData
                            ? submissionsSnapshot.data!.docs.length
                            : 0;
                    final kpiScore =
                        activitiesCount > 0
                            ? ((completedActivities / activitiesCount) * 100)
                                .toInt()
                            : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFB5D8D5),
                                image:
                                    user.profileImageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            user.profileImageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  user.profileImageUrl == null
                                      ? Center(
                                        child: Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1a1a1a),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Preacher ID: ${user.uid.substring(0, 8)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'KPI Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // KPI Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8E8E8),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Activities',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '$activitiesCount',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1a1a1a),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE8E8E8),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KPI Score',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '$kpiScore%',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1a1a1a),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Payment Status Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Status',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                latestPayment != null &&
                                        latestPayment['status'] == 'Approved'
                                    ? 'Paid'
                                    : 'Pending',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      latestPayment != null &&
                                              latestPayment['status'] ==
                                                  'Approved'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Latest Payment Card
                        const Text(
                          'Latest Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child:
                              latestPayment != null
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment for ${_formatDate(latestPayment['createdAt'])}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1a1a1a),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amount: RM ${latestPayment['amount']?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (latestPayment.data() != null &&
                                          (latestPayment.data()
                                                  as Map<String, dynamic>)
                                              .containsKey('receiptUrl') &&
                                          latestPayment['receiptUrl'] != null)
                                        GestureDetector(
                                          onTap: () {
                                            // View receipt image
                                          },
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[100],
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  latestPayment['receiptUrl'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Colors.grey[100],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.receipt,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const PreacherPaymentHistoryScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'View Details',
                                          style: TextStyle(
                                            color: Color(0xFF0066FF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'No payments yet',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 24),
                        // Submit Activity Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PreacherListActivitiesScreen.withProvider(
                                            preacherId: user.uid,
                                            preacherName: user.name,
                                          ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Submit Activity',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    final date = (timestamp as Timestamp).toDate();
    return '${date.month}/${date.year}';
  }

  // Officer Dashboard - Middle Layout
  Widget _buildOfficerStats() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'preacher')
              .where('isApproved', isEqualTo: false)
              .snapshots(),
      builder: (context, preacherAppsSnapshot) {
        final preacherAppsCount =
            preacherAppsSnapshot.hasData
                ? preacherAppsSnapshot.data!.docs.length
                : 0;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('activity_submissions')
                  .where('status', isEqualTo: 'Pending')
                  .snapshots(),
          builder: (context, reportsSnapshot) {
            final reportsCount =
                reportsSnapshot.hasData ? reportsSnapshot.data!.docs.length : 0;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('activity_submissions')
                      .orderBy('submittedAt', descending: true)
                      .limit(3)
                      .snapshots(),
              builder: (context, recentActivitiesSnapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Approvals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Preacher Applications Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preacher Applications',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$preacherAppsCount application${preacherAppsCount != 1 ? 's' : ''} pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const PendingApprovalPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1a1a1a),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Activity Reports Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Activity Reports',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$reportsCount report${reportsCount != 1 ? 's' : ''} pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const OfficerListActivitiesScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1a1a1a),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // KPI Setup Section
                    const Text(
                      'KPI Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Set KPI for Preachers',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1a1a1a),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Define key performance indicators',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1a1a1a),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Setup',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1477281765962-ef34e8bb0967?w=400',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recent Activities Section
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child:
                          recentActivitiesSnapshot.hasData &&
                                  recentActivitiesSnapshot.data!.docs.isNotEmpty
                              ? Column(
                                children:
                                    recentActivitiesSnapshot.data!.docs.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final submission = entry.value;
                                      return Column(
                                        children: [
                                          if (index > 0)
                                            const Divider(height: 24),
                                          FutureBuilder<DocumentSnapshot>(
                                            future:
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(
                                                      submission['preacherId'],
                                                    )
                                                    .get(),
                                            builder: (context, userSnapshot) {
                                              final preacherName =
                                                  userSnapshot.hasData &&
                                                          userSnapshot
                                                              .data!
                                                              .exists
                                                      ? userSnapshot
                                                              .data!['name'] ??
                                                          'Unknown'
                                                      : 'Unknown';
                                              return FutureBuilder<
                                                DocumentSnapshot
                                              >(
                                                future:
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                          'activities',
                                                        )
                                                        .doc(
                                                          submission['activityId'],
                                                        )
                                                        .get(),
                                                builder: (
                                                  context,
                                                  activitySnapshot,
                                                ) {
                                                  final activityTitle =
                                                      activitySnapshot
                                                                  .hasData &&
                                                              activitySnapshot
                                                                  .data!
                                                                  .exists
                                                          ? activitySnapshot
                                                                  .data!['title'] ??
                                                              'Unknown Activity'
                                                          : 'Unknown Activity';
                                                  return _buildOfficerActivityItem(
                                                    'Preacher: $preacherName',
                                                    '$activityTitle - ${submission['status']}',
                                                    userSnapshot.hasData &&
                                                            userSnapshot
                                                                .data!
                                                                .exists &&
                                                            userSnapshot
                                                                    .data!['profileImageUrl'] !=
                                                                null
                                                        ? userSnapshot
                                                            .data!['profileImageUrl']
                                                        : 'https://i.pravatar.cc/150?u=$preacherName',
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              )
                              : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No recent activities',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOfficerActivityItem(
    String name,
    String status,
    String avatarUrl,
  ) {
    return Row(
      children: [
        CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Admin Dashboard - Right Layout
  Widget _buildAdminStats() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'preacher')
              .where('isApproved', isEqualTo: false)
              .snapshots(),
      builder: (context, pendingSnapshot) {
        final pendingCount =
            pendingSnapshot.hasData ? pendingSnapshot.data!.docs.length : 0;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('payment')
                  .where('status', isEqualTo: 'Approved')
                  .snapshots(),
          builder: (context, paymentsSnapshot) {
            double totalPayments = 0.0;
            if (paymentsSnapshot.hasData) {
              for (var doc in paymentsSnapshot.data!.docs) {
                totalPayments += (doc['amount'] ?? 0.0);
              }
            }

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('activities')
                      .snapshots(),
              builder: (context, activitiesSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('activity_submissions')
                          .where('status', isEqualTo: 'Approved')
                          .snapshots(),
                  builder: (context, submissionsSnapshot) {
                    final totalActivities =
                        activitiesSnapshot.hasData
                            ? activitiesSnapshot.data!.docs.length
                            : 0;
                    final completedActivities =
                        submissionsSnapshot.hasData
                            ? submissionsSnapshot.data!.docs.length
                            : 0;
                    final overallKPI =
                        totalActivities > 0
                            ? ((completedActivities / totalActivities) * 100)
                                .toInt()
                            : 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('role', isEqualTo: 'preacher')
                              .where('isApproved', isEqualTo: true)
                              .limit(3)
                              .snapshots(),
                      builder: (context, preachersSnapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Grid
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  const PendingApprovalPage(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pending\nRegistrations',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '$pendingCount',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1a1a1a),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Payments',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'RM ${totalPayments.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1a1a1a),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall KPI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$overallKPI%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1a1a1a),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Preachers Section
                            const Text(
                              'Preachers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (preachersSnapshot.hasData &&
                                preachersSnapshot.data!.docs.isNotEmpty)
                              ...preachersSnapshot.data!.docs.map((preacher) {
                                final preacherData =
                                    preacher.data() as Map<String, dynamic>;
                                final isActive =
                                    preacherData['isActive'] ?? true;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildAdminPreacherItem(
                                    'Preacher ${preacher.id.substring(0, 4)}',
                                    preacherData['name'] ?? 'Unknown',
                                    isActive ? 'Active' : 'Inactive',
                                    preacherData['profileImageUrl'] ??
                                        'https://i.pravatar.cc/150?u=${preacher.id}',
                                  ),
                                );
                              }).toList()
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No preachers yet',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            // Activities Section
                            const Text(
                              'Activities',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('activities')
                                      .orderBy('createdAt', descending: true)
                                      .limit(2)
                                      .snapshots(),
                              builder: (context, activitiesListSnapshot) {
                                if (activitiesListSnapshot.hasData &&
                                    activitiesListSnapshot
                                        .data!
                                        .docs
                                        .isNotEmpty) {
                                  return Column(
                                    children:
                                        activitiesListSnapshot.data!.docs
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final index = entry.key;
                                              final activity = entry.value;
                                              final activityData =
                                                  activity.data()
                                                      as Map<String, dynamic>;
                                              return Column(
                                                children: [
                                                  if (index > 0)
                                                    const SizedBox(height: 12),
                                                  _buildAdminActivityItem(
                                                    'Activity ${activity.id.substring(0, 4)}',
                                                    activityData['title'] ??
                                                        'Unknown Activity',
                                                    activityData['status'] ??
                                                        'Pending',
                                                    activityData['imageUrl'] ??
                                                        'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=400',
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                  );
                                } else {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'No activities yet',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAdminPreacherItem(
    String id,
    String name,
    String status,
    String avatarUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        status == 'Active'
                            ? Colors.green[700]
                            : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActivityItem(
    String id,
    String title,
    String status,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        status == 'Completed'
                            ? Colors.green[700]
                            : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        if (user.isOfficer) ...[
          _buildPremiumActionCard(
            context: context,
            title: 'Review Payments',
            subtitle: 'Approve pending payment requests',
            icon: Icons.payments_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => officer.ActivityPaymentsScreen.withProvider(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildPremiumActionCard(
            context: context,
            title: 'Manage Activities',
            subtitle: 'Create and manage activities',
            icon: Icons.event_note_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfficerListActivitiesScreen.withProvider(),
                ),
              );
            },
          ),
        ],
        if (user.isAdmin) ...[
          _buildPremiumActionCard(
            context: context,
            title: 'Pending Registrations',
            subtitle: 'Approve or reject new user accounts',
            icon: Icons.approval_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFff9966), Color(0xFFff5e62)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PendingApprovalPage()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildPremiumActionCard(
            context: context,
            title: 'Approved Payments',
            subtitle: 'Forward approved payments to Yayasan',
            icon: Icons.check_circle_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApprovedPaymentsScreen.withProvider(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildPremiumActionCard(
            context: context,
            title: 'Manage Activities',
            subtitle: 'Create and manage activities',
            icon: Icons.event_note_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfficerListActivitiesScreen.withProvider(),
                ),
              );
            },
          ),
        ],
        if (user.isPreacher) ...[
          _buildPremiumActionCard(
            context: context,
            title: 'Browse Activities',
            subtitle: 'Find and apply for activities',
            icon: Icons.search_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PreacherAssignActivityScreen.withProvider(
                        preacherId: user.uid,
                        preacherName: user.name,
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildPremiumActionCard(
            context: context,
            title: 'My Activities',
            subtitle: 'View and submit evidence',
            icon: Icons.assignment_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PreacherListActivitiesScreen.withProvider(
                        preacherId: user.uid,
                        preacherName: user.name,
                      ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPremiumActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildModernActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Activity Completed',
          subtitle: 'Friday Sermon at Masjid Al-Nur',
          time: '2 hours ago',
          iconColor: const Color(0xFF43e97b),
          iconBg: const Color(0xFF43e97b).withOpacity(0.1),
        ),
        const SizedBox(height: 12),
        _buildModernActivityItem(
          icon: Icons.payments_rounded,
          title: user.isPreacher ? 'Payment Received' : 'Payment Approved',
          subtitle: 'Monthly activities payment',
          time: '1 day ago',
          iconColor: const Color(0xFF667eea),
          iconBg: const Color(0xFF667eea).withOpacity(0.1),
        ),
        const SizedBox(height: 12),
        _buildModernActivityItem(
          icon: Icons.event_available_rounded,
          title: user.isPreacher ? 'Activity Assigned' : 'Activity Created',
          subtitle: 'Weekend Islamic class',
          time: '3 days ago',
          iconColor: const Color(0xFFf5576c),
          iconBg: const Color(0xFFf5576c).withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildModernActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesPage(BuildContext context, UserModel user) {
    // Show activities list directly based on user role
    if (user.isPreacher) {
      return PreacherListActivitiesScreen.withProvider(
        preacherId: user.uid,
        preacherName: user.name,
      );
    } else {
      // Officer or Admin
      return OfficerListActivitiesScreen.withProvider();
    }
  }

  Widget _buildPaymentsPage(BuildContext context, UserModel user) {
    if (user.isPreacher) {
      return PreacherPaymentHistoryScreen.withProvider(preacherId: user.uid);
    } else if (user.isAdmin) {
      return ApprovedPaymentsScreen.withProvider();
    } else {
      return officer.ActivityPaymentsScreen.withProvider();
    }
  }

  Widget _buildPreacherManagementPage(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preacher Management'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Preacher Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Search and review preacher profiles',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreacherDirectoryScreen.withProvider(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('View Directory'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIPage(UserModel user) {
    // Officers see Manage KPI Targets page, Preachers see their dashboard
    print('DEBUG KPI Page - User role: ${user.role}');
    if (user.role.toLowerCase() == 'officer' ||
        user.role.toLowerCase() == 'admin') {
      print('DEBUG: Showing Officer KPI Management page');
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => KPIController()),
          ChangeNotifierProvider(create: (_) => PreacherController()),
        ],
        child: const Scaffold(body: KPIPreacherListPage()),
      );
    } else {
      // Preacher view
      print(
        'DEBUG: Showing Preacher KPI Dashboard for user: ${user.name}, uid: ${user.uid}',
      );
      return ChangeNotifierProvider(
        create: (_) => KPIController(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My KPI Dashboard'),
            automaticallyImplyLeading: false,
          ),
          body: KPIDashboardPage(preacherId: user.uid),
        ),
      );
    }
  }

  Widget _buildReportsPage(BuildContext context, UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'View detailed reports and statistics',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportingDashboardScreen.withProvider(),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Reports'),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, UserModel user) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Activities',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.track_changes),
          label:
              user.role.toLowerCase() == 'officer'
                  ? 'KPI Target'
                  : 'KPI Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Reports',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'Preachers',
        ),

        if (user.isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Approvals',
          ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
