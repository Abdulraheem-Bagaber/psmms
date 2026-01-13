import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../views/payment/officer/activity_payments_screen.dart' as officer;
import '../views/payment/admin/approved_payments_screen.dart';
import '../views/activity/officer/officer_list_activities_screen.dart';
import '../views/activity/preacher/preacher_list_activities_screen.dart';
import '../views/activity/preacher/preacher_assign_activity_screen.dart';
import '../views/kpi/kpi_dashboard_page.dart';
import '../views/reports/reporting_dashboard_screen.dart';
import '../views/payment/preacher/preacher_payment_history_screen.dart';
import 'profile_screen.dart';
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
              child: Text('Unable to load user data. Please try logging in again.'),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          body: _buildBody(user),
          bottomNavigationBar: _buildBottomNavBar(user),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainMenuScreen()),
              );
            },
            child: const Icon(Icons.apps),
            tooltip: 'All Modules',
          ),
        );
      },
    );
  }

  Widget _buildBody(UserModel user) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome(user);
      case 1:
        return _buildActivitiesPage(user);
      case 2:
        return _buildPaymentsPage(user);
      case 3:
        return _buildReportsPage(user);
      case 4:
        return const ProfileScreen();
      default:
        return _buildDashboardHome(user);
    }
  }

  Widget _buildDashboardHome(UserModel user) {
    return CustomScrollView(
      slivers: [
        // Modern gradient header with glass morphism
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Premium gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                        const Color(0xFFf093fb),
                      ],
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with glow effect
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: user.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.profileImageUrl!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667eea),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Welcome text
                        Text(
                          'Assalamu\'alaikum',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Premium role badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.isPreacher ? Icons.person : user.isAdmin ? Icons.admin_panel_settings : Icons.work,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.role.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings, size: 20),
              ),
              onPressed: () async {
                final userService = UserService();
                final currentUser = await userService.getCurrentUser();
                if (currentUser != null && mounted) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                          _buildRoleTile(context, 'Admin', Icons.admin_panel_settings, 'admin', currentUser, userService),
                          _buildRoleTile(context, 'Officer', Icons.work, 'officer', currentUser, userService),
                          _buildRoleTile(context, 'Preacher', Icons.person, 'preacher', currentUser, userService),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, size: 20),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(user),
                const SizedBox(height: 32),
                _buildQuickActions(user),
                const SizedBox(height: 32),
                _buildRecentActivity(user),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile(BuildContext context, String name, IconData icon, String role, UserModel currentUser, UserService userService) {
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
      trailing: currentUser.role.toLowerCase() == role
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
    );
  }

  Widget _buildQuickStats(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        // Premium grid layout
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildModernStatCard(
              icon: Icons.event_note_rounded,
              title: user.isPreacher ? 'My Activities' : 'Total Activities',
              value: '12',
              change: '+3',
              isPositive: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            _buildModernStatCard(
              icon: Icons.payments_rounded,
              title: user.isPreacher ? 'Pending' : 'Approvals',
              value: '3',
              subtitle: 'payments',
              gradient: const LinearGradient(
                colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
              ),
            ),
            _buildModernStatCard(
              icon: Icons.check_circle_rounded,
              title: user.isPreacher ? 'Completed' : 'Approved',
              value: '8',
              change: '+2',
              isPositive: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              ),
            ),
            _buildModernStatCard(
              icon: Icons.trending_up_rounded,
              title: 'KPI Progress',
              value: '75%',
              isPercentage: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    String? change,
    bool? isPositive,
    bool isPercentage = false,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (change != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive! ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          change,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(UserModel user) {
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
                  builder: (_) => PreacherAssignActivityScreen.withProvider(
                    preacherId: user.uid,
                    preacherName: user.name,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildPremiumActionCard(
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
                  builder: (_) => PreacherListActivitiesScreen.withProvider(
                    preacherId: user.uid,
                    preacherName: user.name,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildPremiumActionCard(
            title: 'KPI Dashboard',
            subtitle: 'Track your performance',
            icon: Icons.analytics_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KPIDashboardPage(preacherId: 'PREACHER-001'),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPremiumActionCard({
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
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

  Widget _buildActivitiesPage(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Activities Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.isPreacher
                  ? 'View and manage your activities'
                  : 'Manage all activities',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (user.isPreacher)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreacherListActivitiesScreen.withProvider(
                        preacherId: user.uid,
                        preacherName: user.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('My Activities'),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfficerListActivitiesScreen.withProvider(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Manage Activities'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsPage(UserModel user) {
    if (user.isPreacher) {
      return PreacherPaymentHistoryScreen.withProvider(
        preacherId: user.uid,
      );
    } else if (user.isAdmin) {
      return ApprovedPaymentsScreen.withProvider();
    } else {
      return officer.ActivityPaymentsScreen.withProvider();
    }
  }

  Widget _buildReportsPage(UserModel user) {
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

  BottomNavigationBar _buildBottomNavBar(UserModel user) {
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Activities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
