import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_seeder.dart';
import 'firebase_options.dart';
import 'views/payment/activity_payments_screen.dart';
import 'views/payment/payment_form_screen.dart';
import 'views/payment/approved_payments_screen.dart';
import 'views/payment/payment_history_screen.dart';
import 'views/payment/preacher_payment_history_screen.dart';
import 'views/activity/officer/officer_list_activities_screen.dart';
import 'views/activity/preacher/preacher_assign_activity_screen.dart';
import 'views/activity/preacher/preacher_list_activities_screen.dart';
import 'views/preacher/preacher_directory_screen.dart';
import 'views/reports/reporting_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'views/kpi/kpi_preacher_list_page.dart';
import 'views/kpi/kpi_dashboard_page.dart';
import 'viewmodels/kpi_management_controller.dart';
import 'viewmodels/preacher_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PsmmsApp());
}

class PsmmsApp extends StatelessWidget {
  const PsmmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSMMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
        useMaterial3: true,
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainMenuScreen(),

        // keep your existing routes
        '/payment-form': (context) => const PaymentFormScreen(),
        '/activity-seeder': (context) => const ActivitySeederPage(),
      },

      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainMenuScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String? userRole;
  String? userName;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            userRole = doc.data()?['role'] ?? 'Preacher';
            userName = doc.data()?['fullName'] ?? 'User';
            userId = user.uid;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.mosque, color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            const Text(
              'PSMMS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildModulesList(context),
    );
  }

  Widget _buildModulesList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (userRole != null)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userRole ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // Officer-only modules
        if (userRole == 'Officer' || userRole == 'MUIP Admin') ..._buildOfficerModules(context),
        
        // Preacher-only modules
        if (userRole == 'Preacher') ..._buildPreacherModules(context),
        
        // Admin-only modules
        if (userRole == 'MUIP Admin') ..._buildAdminModules(context),
        
        // Development tools (show for all in development)
        const SizedBox(height: 24),
        _buildSectionHeader('Development Tools'),
        _buildModuleCard(
          context,
          title: 'Activity Seeder',
          subtitle: 'Insert sample activities into Firestore.',
          icon: Icons.add_circle,
          builder: (_) => const ActivitySeederPage(),
        ),
        
        // Settings (show for all users)
        const SizedBox(height: 24),
        _buildSectionHeader('Settings'),
        _buildModuleCard(
          context,
          title: 'My Profile',
          subtitle: 'View or edit your profile',
          icon: Icons.person_outline,
          builder: (_) => const ProfileScreen(),
        ),
        _buildModuleCard(
          context,
          title: 'Log Out',
          subtitle: 'Log out from your account',
          icon: Icons.logout,
          builder: (_) => const SizedBox(),
          onTapOverride: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildOfficerModules(BuildContext context) {
    return [
      _buildSectionHeader('Activity Management - Officer'),
      _buildModuleCard(
        context,
        title: 'Manage Activities',
        subtitle: 'Create, edit, approve, and delete activities.',
        icon: Icons.admin_panel_settings,
        builder: (_) => OfficerListActivitiesScreen.withProvider(),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('Payment Management'),
      _buildModuleCard(
        context,
        title: 'Activity Payments',
        subtitle: 'Review and manage activity payment requests.',
        icon: Icons.payment,
        builder: (_) => ActivityPaymentsScreen.withProvider(),
      ),
      _buildModuleCard(
        context,
        title: 'Payment Form',
        subtitle: 'Prepare payment requests for completed preacher activities.',
        icon: Icons.edit_document,
        builder: (_) => const PaymentFormScreen(),
      ),
      _buildModuleCard(
        context,
        title: 'Approved Payments',
        subtitle: 'View and forward approved payments to Yayasan.',
        icon: Icons.check_circle,
        builder: (_) => ApprovedPaymentsScreen.withProvider(),
      ),
      _buildModuleCard(
        context,
        title: 'Payment History',
        subtitle: 'View all payment records with status filters.',
        icon: Icons.history,
        builder: (_) => PaymentHistoryScreen.withProvider(),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('Preacher Management'),
      _buildModuleCard(
        context,
        title: 'Preacher Directory',
        subtitle: 'Search and review preacher profiles.',
        icon: Icons.people_alt,
        builder: (_) => PreacherDirectoryScreen.withProvider(),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('KPI Management'),
      _buildModuleCard(
        context,
        title: 'Manage KPI Targets',
        subtitle: 'Set and edit KPI targets for preachers.',
        icon: Icons.track_changes,
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PreacherController()),
            ChangeNotifierProvider(create: (_) => KPIManagementController()),
          ],
          child: const KPIPreacherListPage(),
        ),
      ),
    ];
  }

  List<Widget> _buildPreacherModules(BuildContext context) {
    return [
      _buildSectionHeader('Activity Management - Preacher'),
      _buildModuleCard(
        context,
        title: 'Available Activities',
        subtitle: 'Browse and apply for available activities.',
        icon: Icons.event_available,
        builder: (_) => PreacherAssignActivityScreen.withProvider(
          preacherId: userId ?? 'PREACHER-001',
          preacherName: userName ?? 'Ahmad bin Ali',
        ),
      ),
      _buildModuleCard(
        context,
        title: 'My Activities',
        subtitle: 'View assigned activities and submit evidence.',
        icon: Icons.assignment_ind,
        builder: (_) => PreacherListActivitiesScreen.withProvider(
          preacherId: userId ?? 'PREACHER-001',
          preacherName: userName ?? 'Ahmad bin Ali',
        ),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('My KPI Dashboard'),
      _buildModuleCard(
        context,
        title: 'KPI Dashboard',
        subtitle: 'View your KPI progress and targets.',
        icon: Icons.analytics_outlined,
        builder: (_) => ChangeNotifierProvider(
          create: (_) => KPIManagementController(),
          child: KPIDashboardPage(
            preacherId: userId ?? 'PREACHER-001',
          ),
        ),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('Payment History'),
      _buildModuleCard(
        context,
        title: 'My Payment History',
        subtitle: 'View your payment history.',
        icon: Icons.history,
        builder: (_) => PreacherPaymentHistoryScreen.withProvider(
          preacherId: userId ?? 'PREACHER-001',
        ),
      ),
    ];
  }

  List<Widget> _buildAdminModules(BuildContext context) {
    return [
      _buildSectionHeader('KPI Management'),
      _buildModuleCard(
        context,
        title: 'Manage KPI Targets',
        subtitle: 'Set and edit KPI targets for preachers.',
        icon: Icons.track_changes,
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PreacherController()),
            ChangeNotifierProvider(create: (_) => KPIManagementController()),
          ],
          child: const KPIPreacherListPage(),
        ),
      ),
      const SizedBox(height: 24),
      _buildSectionHeader('Reports & Analytics'),
      _buildModuleCard(
        context,
        title: 'Reports Dashboard',
        subtitle: 'Generate activity, payment, KPI, and coverage reports.',
        icon: Icons.analytics,
        builder: (_) => ReportingDashboardScreen.withProvider(),
      ),
    ];
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required WidgetBuilder builder,
    VoidCallback? onTapOverride,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapOverride ??
              () {
                Navigator.of(context).push(MaterialPageRoute(builder: builder));
              },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
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
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class ActivitySeederPage extends StatelessWidget {
  const ActivitySeederPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Seeder')),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(16), child: ActivitySeeder()),
      ),
    );
  }
}
