# Firebase Setup Complete! 🎉

## What Has Been Done

### 1. ✅ Firebase Configuration
- Connected your Flutter app to **PsmManagementSystem** Firebase project
- Generated `firebase_options.dart` configuration file
- Registered app for all platforms (Android, iOS, macOS, Web, Windows)

### 2. ✅ Dependencies Added
- `firebase_core`: Core Firebase functionality
- `cloud_firestore`: Firebase Firestore database
- `firebase_auth`: Firebase Authentication

### 3. ✅ Models Updated
All models now support Firestore:
- **Preacher** (`lib/models/User.dart`)
- **KPI** (`lib/models/KPITarget.dart`)
- **KPIProgress** (`lib/models/KPIProgress.dart`)

Each model now has:
- `toFirestore()`: Convert model to Firestore format
- `fromFirestore()`: Create model from Firestore document
- String IDs instead of integer IDs

### 4. ✅ Firestore Service Created
**Location:** `lib/services/firestore_service.dart`

### 5. ✅ Main App Updated
- Firebase initialized in `main.dart`
- App now connects to Firebase on startup

### 6. ✅ Examples Created
**Location:** `lib/examples/firestore_examples.dart`

---

## Firebase Collections Structure

Your data will be organized in these Firestore collections:

```
PsmManagementSystem (Firebase Project)
│
├── preachers/                    # Collection for all preachers
│   ├── {preacher_id}/           # Auto-generated document ID
│   │   ├── name: string
│   │   ├── email: string
│   │   ├── phone: string
│   │   ├── avatar_url: string
│   │   ├── status: string
│   │   └── created_at: timestamp
│   
├── kpi_targets/                  # Collection for KPI targets
│   ├── {kpi_id}/                # Auto-generated document ID
│   │   ├── preacher_id: string
│   │   ├── monthly_session_target: number
│   │   ├── total_attendance_target: number
│   │   ├── new_converts_target: number
│   │   ├── baptisms_target: number
│   │   ├── community_projects_target: number
│   │   ├── charity_events_target: number
│   │   ├── youth_program_attendance_target: number
│   │   ├── start_date: timestamp
│   │   ├── end_date: timestamp
│   │   ├── created_at: timestamp
│   │   └── updated_at: timestamp
│   
└── kpi_progress/                 # Collection for KPI progress
    ├── {progress_id}/           # Auto-generated document ID
        ├── kpi_id: string
        ├── preacher_id: string
        ├── sessions_completed: number
        ├── total_attendance_achieved: number
        ├── new_converts_achieved: number
        ├── baptisms_achieved: number
        ├── community_projects_achieved: number
        ├── charity_events_achieved: number
        ├── youth_program_attendance_achieved: number
        └── last_updated: timestamp
```

---

## How to Use Firestore Service

### Quick Start Example

```dart
import 'package:flutter/material.dart';
import 'services/firestore_service.dart';
import 'models/User.dart';

class MyPage extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Preacher>>(
      stream: _firestore.getPreachers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final preacher = snapshot.data![index];
              return ListTile(
                title: Text(preacher.name),
                subtitle: Text(preacher.email),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Common Operations

#### 1. Add a Preacher
```dart
final firestore = FirestoreService();

final preacher = Preacher(
  name: 'Sheikh Hamza Yusuf',
  email: 'hamza@example.com',
  phone: '+1234567890',
  status: 'active',
);

final id = await firestore.addPreacher(preacher);
print('Preacher added with ID: $id');
```

#### 2. Get All Preachers (Real-time)
```dart
StreamBuilder<List<Preacher>>(
  stream: firestore.getPreachers(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final preachers = snapshot.data!;
    // Use preachers list...
  },
);
```

#### 3. Update a Preacher
```dart
await firestore.updatePreacher(preacherId, updatedPreacher);
```

#### 4. Add KPI Target
```dart
final kpi = KPI(
  preacherId: 'preacher_id_here',
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

final kpiId = await firestore.addKPITarget(kpi);

// Initialize progress
await firestore.initializeKPIProgress(kpiId, preacherId);
```

#### 5. Update KPI Progress
```dart
final progress = await firestore.getKPIProgress(kpiId, preacherId);

if (progress != null) {
  await firestore.updateKPIAchievement(
    progress.id!,
    {
      'sessions_completed': 15,
      'total_attendance_achieved': 350,
      'new_converts_achieved': 8,
    },
  );
}
```

---

## Next Steps

### ⚠️ Important: Update Your Controllers

Your existing controllers (`kpi_controller.dart`, `preacher_controller.dart`) are still using the old SQLite database. You need to update them to use `FirestoreService` instead of `DatabaseService`.

**Option 1: Quick Migration** (Recommended for testing)
Replace `DatabaseService` with `FirestoreService` in your controllers and update the method calls.

**Option 2: Keep Both** (For gradual migration)
Keep SQLite for now and gradually migrate to Firestore.

### Setting Up Firestore Rules

Go to Firebase Console → Firestore Database → Rules

For development (UNSAFE for production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

For production (Recommended):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Preachers collection
    match /preachers/{preacherId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == preacherId;
    }
    
    // KPI Targets
    match /kpi_targets/{kpiId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Add role-based rules
    }
    
    // KPI Progress
    match /kpi_progress/{progressId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Test Your Firebase Connection

Run your app:
```bash
flutter run
```

If you encounter any errors, check:
1. Firebase console for correct project setup
2. Internet connection
3. Firebase rules are not blocking requests

---

## Working with Your Friends' Data

Since you're all sharing the same Firebase project (**PsmManagementSystem**), here's how collaboration works:

### 1. **Shared Collections**
- All team members can see the same collections
- Changes made by anyone appear in real-time for everyone
- Use `StreamBuilder` to get real-time updates

### 2. **Data Organization**
Each friend can work on different features:
- **Friend 1**: Manages `activities` collection (already exists)
- **Friend 2**: Manages `payment` collection (already exists)  
- **You**: Manage `preachers`, `kpi_targets`, `kpi_progress` collections

### 3. **Test Data**
Create test data with clear naming:
```dart
final testPreacher = Preacher(
  name: 'TEST - Your Name - Preacher 1',
  email: 'test.yourname.1@example.com',
  phone: '+1234567890',
  status: 'active',
);
```

This helps everyone identify who created what during development.

---

## Helpful Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Check for errors
flutter analyze

# Format code
flutter format lib/

# View Firebase CLI help
firebase --help

# Login to Firebase (if needed)
firebase login
```

---

## Firebase Console Access

**Firebase Project:** PsmManagementSystem
**Console URL:** https://console.firebase.google.com/project/psmmanagementsystem

From here you can:
- View/edit Firestore data
- Monitor real-time database activity
- Check authentication users
- View analytics
- Manage security rules

---

## Example: Complete CRUD Flow

```dart
import 'services/firestore_service.dart';
import 'models/User.dart';

class PreacherManagement {
  final FirestoreService _firestore = FirestoreService();

  // CREATE
  Future<void> createPreacher() async {
    final preacher = Preacher(
      name: 'Test Preacher',
      email: 'test@example.com',
      phone: '+1234567890',
      status: 'active',
    );
    
    final id = await _firestore.addPreacher(preacher);
    print('Created with ID: $id');
  }

  // READ (Real-time)
  Widget readPreachers() {
    return StreamBuilder<List<Preacher>>(
      stream: _firestore.getPreachers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        return ListView(
          children: snapshot.data!.map((preacher) => 
            ListTile(
              title: Text(preacher.name),
              subtitle: Text(preacher.email),
            )
          ).toList(),
        );
      },
    );
  }

  // UPDATE
  Future<void> updatePreacher(String id) async {
    final updatedPreacher = Preacher(
      id: id,
      name: 'Updated Name',
      email: 'updated@example.com',
      phone: '+9876543210',
      status: 'active',
    );
    
    await _firestore.updatePreacher(id, updatedPreacher);
  }

  // DELETE
  Future<void> deletePreacher(String id) async {
    await _firestore.deletePreacher(id);
  }
}
```

---

## Need Help?

Check these files for examples:
- `lib/services/firestore_service.dart` - All available database methods
- `lib/examples/firestore_examples.dart` - Usage examples with StreamBuilder

---

**You're all set to start using Firebase! 🚀**
