import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'activity_seeder.dart';
import 'firebase_options.dart';
import 'views/payment/officer/activity_payments_screen.dart';
import 'views/payment/officer/payment_form_screen.dart';
import 'views/payment/admin/approved_payments_screen.dart';
import 'views/payment/admin/payment_history_screen.dart';
import 'views/payment/preacher/preacher_payment_history_screen.dart';
import 'views/activity/officer/officer_list_activities_screen.dart';
import 'views/activity/preacher/preacher_assign_activity_screen.dart';
import 'views/activity/preacher/preacher_list_activities_screen.dart';
import 'views/preacher/preacher_directory_screen.dart';
import 'views/reports/reporting_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/ProfilePage.dart';
import 'screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'views/kpi/kpi_preacher_list_page.dart';
import 'views/kpi/kpi_dashboard_page.dart';
import 'viewmodels/kpi_controller.dart';
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
        '/dashboard': (context) => const DashboardScreen(),

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
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PSMMS Modules'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            subtitle:
                'Prepare payment requests for completed preacher activities.',
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
          _buildModuleCard(
            context,
            title: 'Preacher Payment History',
            subtitle: 'View payment history for a specific preacher.',
            icon: Icons.person_search,
            builder:
                (_) => PreacherPaymentHistoryScreen.withProvider(
                  preacherId: 'PREACHER-001',
                ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Activity Management - Officer'),
          _buildModuleCard(
            context,
            title: 'Manage Activities',
            subtitle: 'Create, edit, approve, and delete activities.',
            icon: Icons.admin_panel_settings,
            builder: (_) => OfficerListActivitiesScreen.withProvider(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Activity Management - Preacher'),
          _buildModuleCard(
            context,
            title: 'Available Activities',
            subtitle: 'Browse and apply for available activities.',
            icon: Icons.event_available,
            builder:
                (_) => PreacherAssignActivityScreen.withProvider(
                  preacherId: 'PREACHER-001',
                  preacherName: 'Ahmad bin Ali',
                ),
          ),
          _buildModuleCard(
            context,
            title: 'My Activities',
            subtitle: 'View assigned activities and submit evidence.',
            icon: Icons.assignment_ind,
            builder:
                (_) => PreacherListActivitiesScreen.withProvider(
                  preacherId: 'PREACHER-001',
                  preacherName: 'Ahmad bin Ali',
                ),
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
          _buildSectionHeader('Reports & Analytics'),
          _buildModuleCard(
            context,
            title: 'Reports Dashboard',
            subtitle: 'Generate activity, payment, KPI, and coverage reports.',
            icon: Icons.analytics,
            builder: (_) => ReportingDashboardScreen.withProvider(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('KPI Management'),
          _buildModuleCard(
            context,
            title: 'Manage KPI Targets',
            subtitle: 'Set and edit KPI targets for preachers.',
            icon: Icons.track_changes,
            builder:
                (_) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => PreacherController()),
                    ChangeNotifierProvider(
                      create: (_) => KPIController(),
                    ),
                  ],
                  child: const KPIPreacherListPage(),
                ),
          ),
          _buildModuleCard(
            context,
            title: 'Preacher KPI Dashboard',
            subtitle: 'View real-time KPI progress for preachers.',
            icon: Icons.analytics_outlined,
            builder:
                (_) => ChangeNotifierProvider(
                  create: (_) => KPIController(),
                  child: const KPIDashboardPage(
                    preacherId: 'PREACHER-001', // Demo preacher
                  ),
                ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Development Tools'),
          _buildModuleCard(
            context,
            title: 'Activity Seeder',
            subtitle: 'Insert sample activities into Firestore.',
            icon: Icons.data_object,
            builder: (_) => const ActivitySeederPage(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Settings'),

          _buildModuleCard(
            context,
            title: 'My Profile',
            subtitle: 'View or edit your own profile',
            icon: Icons.person_outline,
            builder: (_) => const ProfilePage(),
          ),

          _buildModuleCard(
            context,
            title: 'Log Out',
            subtitle: 'Log out from your account',
            icon: Icons.logout,
            builder: (_) => const SizedBox(), // dummy, we intercept onTap
            onTapOverride: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0066FF),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required WidgetBuilder builder,
    VoidCallback? onTapOverride,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0066FF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap:
            onTapOverride ??
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: builder));
            },
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
