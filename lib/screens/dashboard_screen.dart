import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          actions: [
            // Temporary role switcher for testing
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings),
              onSelected: (role) async {
                final userService = UserService();
                final currentUser = await userService.getCurrentUser();
                if (currentUser != null) {
                  await userService.updateUser(currentUser.copyWith(role: role));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Role changed to $role. Reload the app.')),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'admin', child: Text('Admin')),
                const PopupMenuItem(value: 'officer', child: Text('Officer')),
                const PopupMenuItem(value: 'preacher', child: Text('Preacher')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Logout',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome, ${user.name}',
              style: const TextStyle(fontSize: 18),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: user.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.profileImageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(user),
                const SizedBox(height: 24),
                _buildQuickActions(user),
                const SizedBox(height: 24),
                _buildRecentActivity(user),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.event,
                title: user.isPreacher ? 'My Activities' : 'Total Activities',
                value: '12',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.payment,
                title: user.isPreacher ? 'Pending Payments' : 'Pending Approvals',
                value: '3',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                title: user.isPreacher ? 'Completed' : 'Approved',
                value: '8',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'KPI Progress',
                value: '75%',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (user.isOfficer) ...[
          _buildActionCard(
            title: 'Review Payments',
            subtitle: 'Approve pending payment requests',
            icon: Icons.payment,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => officer.ActivityPaymentsScreen.withProvider(),
                ),
              );
            },
          ),
          _buildActionCard(
            title: 'Manage Activities',
            subtitle: 'Create and manage activities',
            icon: Icons.event,
            color: Colors.green,
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
          _buildActionCard(
            title: 'Approved Payments',
            subtitle: 'Forward approved payments to Yayasan',
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApprovedPaymentsScreen.withProvider(),
                ),
              );
            },
          ),
          _buildActionCard(
            title: 'Manage Activities',
            subtitle: 'Create and manage activities',
            icon: Icons.event,
            color: Colors.blue,
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
          _buildActionCard(
            title: 'Browse Activities',
            subtitle: 'Find and apply for activities',
            icon: Icons.search,
            color: Colors.blue,
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
          _buildActionCard(
            title: 'My Activities',
            subtitle: 'View and submit evidence',
            icon: Icons.assignment,
            color: Colors.green,
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
          _buildActionCard(
            title: 'KPI Dashboard',
            subtitle: 'Track your performance',
            icon: Icons.analytics,
            color: Colors.purple,
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

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentActivity(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.check_circle,
                  title: 'Activity Completed',
                  subtitle: 'Friday Sermon at Masjid Al-Nur',
                  time: '2 hours ago',
                  color: Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.payment,
                  title: user.isPreacher ? 'Payment Received' : 'Payment Approved',
                  subtitle: 'Monthly activities payment',
                  time: '1 day ago',
                  color: Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.event_available,
                  title: user.isPreacher ? 'Activity Assigned' : 'Activity Created',
                  subtitle: 'Weekend Islamic class',
                  time: '3 days ago',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
