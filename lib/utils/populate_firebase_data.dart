// Script to populate Firebase with sample data
// Run this once to create test data for KPI Management module

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/User.dart';
import '../models/KPITarget.dart';
import '../models/KPIProgress.dart';
import '../models/PreacherProfile.dart';

class PopulateFirebaseData {
  final FirestoreService _firestore = FirestoreService();

  /// Main function to populate all data
  Future<void> populateAllData() async {
    try {
      print('🚀 Starting Firebase data population...\n');

      // Step 1: Create Preachers
      print('📝 Creating Preachers...');
      final preacherIds = await createPreachers();
      print('✅ Created ${preacherIds.length} preachers\n');

      // Step 2: Create Preacher Profiles
      print('👤 Creating Preacher Profiles...');
      await createPreacherProfiles(preacherIds);
      print('✅ Created ${preacherIds.length} profiles\n');

      // Step 3: Create KPI Targets
      print('🎯 Creating KPI Targets...');
      final kpiIds = await createKPITargets(preacherIds);
      print('✅ Created ${kpiIds.length} KPI targets\n');

      // Step 4: Create KPI Progress
      print('📊 Creating KPI Progress records...');
      await createKPIProgress(kpiIds, preacherIds);
      print('✅ Created ${kpiIds.length} progress records\n');

      print('🎉 Firebase data population completed successfully!');
    } catch (e) {
      print('❌ Error populating data: $e');
      rethrow;
    }
  }

  /// Create sample preachers
  Future<List<String>> createPreachers() async {
    final List<String> createdIds = [];

    final preachers = [
      Preacher(
        name: 'Sheikh Hamza Yusuf',
        email: 'hamza.yusuf@muip.org',
        phone: '+60123456789',
        status: 'active',
        avatarUrl: 'https://ui-avatars.com/api/?name=Hamza+Yusuf&size=200',
      ),
      Preacher(
        name: 'Sheikh Omar Suleiman',
        email: 'omar.suleiman@muip.org',
        phone: '+60123456790',
        status: 'active',
        avatarUrl: 'https://ui-avatars.com/api/?name=Omar+Suleiman&size=200',
      ),
      Preacher(
        name: 'Sheikh Yasir Qadhi',
        email: 'yasir.qadhi@muip.org',
        phone: '+60123456791',
        status: 'active',
        avatarUrl: 'https://ui-avatars.com/api/?name=Yasir+Qadhi&size=200',
      ),
      Preacher(
        name: 'Sheikh Nouman Ali Khan',
        email: 'nouman.khan@muip.org',
        phone: '+60123456792',
        status: 'active',
        avatarUrl: 'https://ui-avatars.com/api/?name=Nouman+Khan&size=200',
      ),
      Preacher(
        name: 'Sheikh Mufti Menk',
        email: 'mufti.menk@muip.org',
        phone: '+60123456793',
        status: 'active',
        avatarUrl: 'https://ui-avatars.com/api/?name=Mufti+Menk&size=200',
      ),
    ];

    for (final preacher in preachers) {
      final id = await _firestore.addPreacher(preacher);
      createdIds.add(id);
      print('  ➕ ${preacher.name} (ID: $id)');
    }

    return createdIds;
  }

  /// Create preacher profiles
  Future<void> createPreacherProfiles(List<String> preacherIds) async {
    final profiles = [
      PreacherProfile(
        userId: preacherIds[0],
        fullName: 'Sheikh Hamza Yusuf bin Abdul Latif',
        idNumber: 'IC-001-2024',
        phoneNumber: '+60123456789',
        address: 'Kuala Lumpur, Malaysia',
        qualifications: [
          'Bachelor in Islamic Studies',
          'Master in Quranic Sciences',
          'PhD in Islamic Theology'
        ],
        skills: ['Youth Counseling', 'Arabic Language', 'Quran Recitation'],
        profileStatus: 'Active',
      ),
      PreacherProfile(
        userId: preacherIds[1],
        fullName: 'Sheikh Omar Suleiman bin Hassan',
        idNumber: 'IC-002-2024',
        phoneNumber: '+60123456790',
        address: 'Penang, Malaysia',
        qualifications: [
          'Bachelor in Islamic Studies',
          'Master in Hadith Sciences'
        ],
        skills: ['Community Outreach', 'Islamic History', 'Public Speaking'],
        profileStatus: 'Active',
      ),
      PreacherProfile(
        userId: preacherIds[2],
        fullName: 'Sheikh Yasir Qadhi bin Muhammad',
        idNumber: 'IC-003-2024',
        phoneNumber: '+60123456791',
        address: 'Johor Bahru, Malaysia',
        qualifications: [
          'Bachelor in Islamic Studies',
          'PhD in Islamic Theology'
        ],
        skills: ['Tafseer', 'Islamic Philosophy', 'Interfaith Dialogue'],
        profileStatus: 'Active',
      ),
      PreacherProfile(
        userId: preacherIds[3],
        fullName: 'Sheikh Nouman Ali Khan bin Ahmad',
        idNumber: 'IC-004-2024',
        phoneNumber: '+60123456792',
        address: 'Selangor, Malaysia',
        qualifications: [
          'Bachelor in Arabic Language',
          'Master in Quranic Studies'
        ],
        skills: ['Quran Translation', 'Youth Programs', 'Arabic Grammar'],
        profileStatus: 'Active',
      ),
      PreacherProfile(
        userId: preacherIds[4],
        fullName: 'Sheikh Mufti Ismail Menk',
        idNumber: 'IC-005-2024',
        phoneNumber: '+60123456793',
        address: 'Melaka, Malaysia',
        qualifications: [
          'Mufti Certification',
          'Bachelor in Islamic Law'
        ],
        skills: ['Fatwa Issuance', 'Family Counseling', 'Social Media Dawah'],
        profileStatus: 'Active',
      ),
    ];

    for (final profile in profiles) {
      await _firestore.addPreacherProfile(profile);
      print('  ➕ ${profile.fullName}');
    }
  }

  /// Create KPI targets
  Future<List<String>> createKPITargets(List<String> preacherIds) async {
    final List<String> createdIds = [];
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1); // First day of current month
    final endDate = DateTime(now.year, now.month + 3, 0); // End of 3 months from now

    for (final preacherId in preacherIds) {
      final kpi = KPI(
        preacherId: preacherId,
        monthlySessionTarget: 20,
        totalAttendanceTarget: 500,
        newConvertsTarget: 10,
        baptismsTarget: 5,
        communityProjectsTarget: 3,
        charityEventsTarget: 4,
        youthProgramAttendanceTarget: 100,
        startDate: startDate,
        endDate: endDate,
      );

      final id = await _firestore.addKPITarget(kpi);
      createdIds.add(id);
      print('  ➕ KPI Target for Preacher (ID: $id)');
    }

    return createdIds;
  }

  /// Create KPI progress with realistic data
  Future<void> createKPIProgress(List<String> kpiIds, List<String> preacherIds) async {
    // Different progress levels for variety
    final progressLevels = [
      {'sessions': 15, 'attendance': 380, 'converts': 8, 'baptisms': 4, 'projects': 2, 'charity': 3, 'youth': 75}, // 75% progress
      {'sessions': 18, 'attendance': 450, 'converts': 9, 'baptisms': 4, 'projects': 3, 'charity': 4, 'youth': 90}, // 90% progress
      {'sessions': 12, 'attendance': 300, 'converts': 6, 'baptisms': 3, 'projects': 2, 'charity': 2, 'youth': 60}, // 60% progress
      {'sessions': 20, 'attendance': 510, 'converts': 11, 'baptisms': 6, 'projects': 3, 'charity': 4, 'youth': 105}, // 100%+ progress
      {'sessions': 10, 'attendance': 250, 'converts': 5, 'baptisms': 2, 'projects': 1, 'charity': 2, 'youth': 50}, // 50% progress
    ];

    for (int i = 0; i < kpiIds.length; i++) {
      final level = progressLevels[i % progressLevels.length];
      
      final progress = KPIProgress(
        kpiId: kpiIds[i],
        preacherId: preacherIds[i],
        sessionsCompleted: level['sessions']!,
        totalAttendanceAchieved: level['attendance']!,
        newConvertsAchieved: level['converts']!,
        baptismsAchieved: level['baptisms']!,
        communityProjectsAchieved: level['projects']!,
        charityEventsAchieved: level['charity']!,
        youthProgramAttendanceAchieved: level['youth']!,
      );

      await _firestore.setKPIProgress(progress);
      print('  ➕ Progress: ${level['sessions']}/20 sessions');
    }
  }

  /// Clear all data (use with caution!)
  Future<void> clearAllData() async {
    print('⚠️  WARNING: Clearing all KPI data from Firebase...\n');

    try {
      // Clear KPI Progress
      final progressSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.kpiProgressCollection)
          .get();
      for (final doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${progressSnapshot.docs.length} progress records');

      // Clear KPI Targets
      final kpiSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.kpiTargetsCollection)
          .get();
      for (final doc in kpiSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${kpiSnapshot.docs.length} KPI targets');

      // Clear Preacher Profiles
      final profilesSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.preacherProfilesCollection)
          .get();
      for (final doc in profilesSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${profilesSnapshot.docs.length} profiles');

      // Clear Preachers
      final preachersSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.preachersCollection)
          .get();
      for (final doc in preachersSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Cleared ${preachersSnapshot.docs.length} preachers\n');

      print('🎉 All data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}

/// Widget to trigger data population
class FirebaseDataPopulatorPage extends StatefulWidget {
  const FirebaseDataPopulatorPage({Key? key}) : super(key: key);

  @override
  State<FirebaseDataPopulatorPage> createState() => _FirebaseDataPopulatorPageState();
}

class _FirebaseDataPopulatorPageState extends State<FirebaseDataPopulatorPage> {
  final PopulateFirebaseData populator = PopulateFirebaseData();
  bool isLoading = false;
  String? message;

  Future<void> _populateData() async {
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      await populator.populateAllData();
      setState(() {
        message = '✅ Successfully created sample data in Firebase!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = '❌ Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all preachers, KPI targets, and progress data. This action cannot be undone!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      await populator.clearAllData();
      setState(() {
        message = '✅ All data cleared successfully!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        message = '❌ Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Data Populator'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Firebase Data Populator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will create sample data for:\n'
                '• 5 Preachers\n'
                '• 5 Preacher Profiles\n'
                '• 5 KPI Targets\n'
                '• 5 KPI Progress Records',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _populateData,
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Create Sample Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _clearData,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear All Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              if (message != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message!.contains('Error') 
                        ? Colors.red.shade50 
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: message!.contains('Error') 
                          ? Colors.red 
                          : Colors.green,
                    ),
                  ),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: message!.contains('Error') 
                          ? Colors.red.shade900 
                          : Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
