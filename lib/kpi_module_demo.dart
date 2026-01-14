import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/kpi/kpi_preacher_list_page.dart';
import 'views/kpi/kpi_dashboard_page.dart';
import 'viewmodels/kpi_controller.dart';
import 'viewmodels/preacher_controller.dart';

/// KPI Module Demo/Test Page
/// Use this to test the integrated KPI module functionality
class KPIModuleDemo extends StatelessWidget {
  const KPIModuleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI Module - Integration Test'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'KPI Module Integration Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test the integrated KPI module features:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // MUIP Official Features
            const Text(
              'MUIP Official Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => PreacherController(),
                            ),
                            ChangeNotifierProvider(
                              create: (_) => KPIController(),
                            ),
                          ],
                          child: const KPIPreacherListPage(),
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Manage KPI - Select Preacher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Preacher Features
            const Text(
              'Preacher Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                // For demo: Use a test preacher ID
                // In production, get this from auth context
                const testPreacherId = 'TEST_PREACHER_001';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => KPIController(),
                          child: const KPIDashboardPage(
                            preacherId: testPreacherId,
                          ),
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View My KPI Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Module Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Integration Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatusItem(
                    '✅ Models Created',
                    'kpi_target.dart, kpi_progress.dart',
                  ),
                  _buildStatusItem(
                    '✅ Controller Ready',
                    'kpi_management_controller.dart',
                  ),
                  _buildStatusItem(
                    '✅ Views Integrated',
                    '3 pages: Dashboard, Form, List',
                  ),
                  _buildStatusItem(
                    '✅ Dependencies OK',
                    'provider, intl, cloud_firestore',
                  ),
                  _buildStatusItem(
                    '⚠️ Firebase Setup',
                    'Create Firestore collections',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Next Steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Next Steps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Create Firebase collections:\n   • kpi_targets\n   • kpi_progress',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2. Add Firebase security rules',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3. Test with real preacher data',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '4. Integrate with Activity module',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
