// Example: How to Use FirestoreService
// This file demonstrates how to create and manage your data in Firebase

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/User.dart';
import '../models/KPITarget.dart';
import '../models/KPIProgress.dart';

class FirestoreExamples {
  final FirestoreService _firestoreService = FirestoreService();

  // ==================== EXAMPLE 1: Add a New Preacher ====================
  Future<void> addNewPreacher() async {
    try {
      final preacher = Preacher(
        name: 'Sheikh Hamza Yusuf',
        email: 'hamza@example.com',
        phone: '+1234567890',
        status: 'active',
      );

      final preacherId = await _firestoreService.addPreacher(preacher);
      print('Preacher added successfully with ID: $preacherId');
    } catch (e) {
      print('Error adding preacher: $e');
    }
  }

  // ==================== EXAMPLE 2: Get All Preachers ====================
  Widget getPreachers() {
    return StreamBuilder<List<Preacher>>(
      stream: _firestoreService.getPreachers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No preachers found');
        }

        final preachers = snapshot.data!;
        return ListView.builder(
          itemCount: preachers.length,
          itemBuilder: (context, index) {
            final preacher = preachers[index];
            return ListTile(
              title: Text(preacher.name),
              subtitle: Text(preacher.email),
              trailing: Text(preacher.status),
            );
          },
        );
      },
    );
  }

  // ==================== EXAMPLE 3: Update a Preacher ====================
  Future<void> updatePreacher(String preacherId) async {
    try {
      final updatedPreacher = Preacher(
        id: preacherId,
        name: 'Updated Name',
        email: 'updated@example.com',
        phone: '+0987654321',
        status: 'active',
      );

      await _firestoreService.updatePreacher(preacherId, updatedPreacher);
      print('Preacher updated successfully');
    } catch (e) {
      print('Error updating preacher: $e');
    }
  }

  // ==================== EXAMPLE 4: Add KPI Target ====================
  Future<void> addKPITarget(String preacherId) async {
    try {
      final kpi = KPI(
        preacherId: preacherId,
        monthlySessionTarget: 20,
        totalAttendanceTarget: 500,
        newConvertsTarget: 10,
        baptismsTarget: 5,
        communityProjectsTarget: 3,
        charityEventsTarget: 4,
        youthProgramAttendanceTarget: 100,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 365)),
      );

      final kpiId = await _firestoreService.addKPITarget(kpi);
      print('KPI Target added successfully with ID: $kpiId');

      // Initialize progress for this KPI
      await _firestoreService.initializeKPIProgress(kpiId, preacherId);
      print('KPI Progress initialized');
    } catch (e) {
      print('Error adding KPI target: $e');
    }
  }

  // ==================== EXAMPLE 5: Update KPI Progress ====================
  Future<void> updateProgress(String kpiId, String preacherId) async {
    try {
      // First, get existing progress
      final existingProgress = await _firestoreService.getKPIProgress(kpiId, preacherId);

      if (existingProgress != null) {
        // Update specific achievements
        await _firestoreService.updateKPIAchievement(
          existingProgress.id!,
          {
            'sessions_completed': 15,
            'total_attendance_achieved': 350,
            'new_converts_achieved': 8,
          },
        );
        print('Progress updated successfully');
      } else {
        print('No progress found for this KPI');
      }
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  // ==================== EXAMPLE 6: Get KPI with Progress ====================
  Widget getKPIDashboard(String preacherId) {
    return StreamBuilder<List<KPI>>(
      stream: _firestoreService.getActiveKPITargets(preacherId),
      builder: (context, kpiSnapshot) {
        if (kpiSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!kpiSnapshot.hasData || kpiSnapshot.data!.isEmpty) {
          return Text('No active KPI targets');
        }

        final kpi = kpiSnapshot.data!.first;

        return StreamBuilder<List<KPIProgress>>(
          stream: _firestoreService.getKPIProgressByPreacher(preacherId),
          builder: (context, progressSnapshot) {
            if (!progressSnapshot.hasData) {
              return CircularProgressIndicator();
            }

            final progress = progressSnapshot.data!.firstWhere(
              (p) => p.kpiId == kpi.id,
              orElse: () => KPIProgress(
                kpiId: kpi.id!,
                preacherId: preacherId,
              ),
            );

            return Column(
              children: [
                Text('Monthly Sessions: ${progress.sessionsCompleted} / ${kpi.monthlySessionTarget}'),
                Text('Attendance: ${progress.totalAttendanceAchieved} / ${kpi.totalAttendanceTarget}'),
                Text('New Converts: ${progress.newConvertsAchieved} / ${kpi.newConvertsTarget}'),
                Text('Baptisms: ${progress.baptismsAchieved} / ${kpi.baptismsTarget}'),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== EXAMPLE 7: Delete Operations ====================
  Future<void> deletePreacher(String preacherId) async {
    try {
      await _firestoreService.deletePreacher(preacherId);
      print('Preacher deleted successfully');
    } catch (e) {
      print('Error deleting preacher: $e');
    }
  }

  // ==================== EXAMPLE 8: Get Preachers by Status ====================
  Widget getActivePreachers() {
    return StreamBuilder<List<Preacher>>(
      stream: _firestoreService.getPreachersByStatus('active'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No active preachers found');
        }

        final preachers = snapshot.data!;
        return ListView.builder(
          itemCount: preachers.length,
          itemBuilder: (context, index) {
            final preacher = preachers[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: preacher.avatarUrl != null
                      ? NetworkImage(preacher.avatarUrl!)
                      : null,
                  child: preacher.avatarUrl == null
                      ? Text(preacher.name[0])
                      : null,
                ),
                title: Text(preacher.name),
                subtitle: Text(preacher.email),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    // Navigate to preacher details
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
