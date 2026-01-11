# 🚀 How to Create Data in Firebase

## Quick Start Guide

Your Firebase is now ready! Follow these simple steps to populate it with sample data.

---

## Method 1: Using the Data Populator UI (EASIEST) ✅

### Step 1: Run Your App
```bash
flutter run
```

### Step 2: Click "Populate Firebase Data"
On the home screen, click the **"Populate Firebase Data"** button.

### Step 3: Create Sample Data
Click **"Create Sample Data"** button.

This will create:
- ✅ **5 Preachers** (Sheikh Hamza Yusuf, Omar Suleiman, etc.)
- ✅ **5 Preacher Profiles** (detailed information)
- ✅ **5 KPI Targets** (monthly goals for each preacher)
- ✅ **5 KPI Progress** (current achievement data)

### Step 4: View Data
Go back to the home screen and:
- Click **"Manage KPI (MUIP Official)"** to see the list of preachers
- Click **"View Dashboard (Preacher)"** to see KPI progress

---

## Method 2: Manual Creation via Code

### Create a Single Preacher
```dart
import 'services/firestore_service.dart';
import 'models/User.dart';

final firestore = FirestoreService();

// Create preacher
final preacher = Preacher(
  name: 'Your Preacher Name',
  email: 'email@example.com',
  phone: '+60123456789',
  status: 'active',
);

final preacherId = await firestore.addPreacher(preacher);
print('Created preacher: $preacherId');

// Create KPI target for this preacher
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
  endDate: DateTime.now().add(Duration(days: 90)),
);

final kpiId = await firestore.addKPITarget(kpi);

// Initialize progress
await firestore.initializeKPIProgress(kpiId, preacherId);
```

---

## What Data Gets Created

### 1. Preachers Collection
```
preachers/
  ├── {preacher_id_1}
  │     ├── name: "Sheikh Hamza Yusuf"
  │     ├── email: "hamza.yusuf@muip.org"
  │     ├── phone: "+60123456789"
  │     ├── status: "active"
  │     └── created_at: (timestamp)
  │
  ├── {preacher_id_2}
  │     ├── name: "Sheikh Omar Suleiman"
  │     └── ...
```

### 2. Preacher Profiles Collection
```
preacher_profiles/
  ├── {profile_id_1}
  │     ├── user_id: "preacher_id_1"
  │     ├── full_name: "Sheikh Hamza Yusuf bin Abdul Latif"
  │     ├── id_number: "IC-001-2024"
  │     ├── qualifications: ["Bachelor in Islamic Studies", ...]
  │     ├── skills: ["Youth Counseling", "Arabic Language", ...]
  │     └── profile_status: "Active"
```

### 3. KPI Targets Collection
```
kpi_targets/
  ├── {kpi_id_1}
  │     ├── preacher_id: "preacher_id_1"
  │     ├── monthly_session_target: 20
  │     ├── total_attendance_target: 500
  │     ├── new_converts_target: 10
  │     ├── baptisms_target: 5
  │     ├── community_projects_target: 3
  │     ├── charity_events_target: 4
  │     ├── youth_program_attendance_target: 100
  │     ├── start_date: (timestamp)
  │     └── end_date: (timestamp)
```

### 4. KPI Progress Collection
```
kpi_progress/
  ├── {progress_id_1}
  │     ├── kpi_id: "kpi_id_1"
  │     ├── preacher_id: "preacher_id_1"
  │     ├── sessions_completed: 15
  │     ├── total_attendance_achieved: 380
  │     ├── new_converts_achieved: 8
  │     ├── baptisms_achieved: 4
  │     ├── community_projects_achieved: 2
  │     ├── charity_events_achieved: 3
  │     ├── youth_program_attendance_achieved: 75
  │     └── last_updated: (timestamp)
```

---

## Verify Data in Firebase Console

1. Go to: https://console.firebase.google.com/project/psmmanagementsystem
2. Click **Firestore Database** in the left menu
3. You should see these collections:
   - `preachers`
   - `preacher_profiles`
   - `kpi_targets`
   - `kpi_progress`

4. Click on any collection to see the documents inside

---

## Sample Preachers Created

| Name | Email | Phone | Specialization |
|------|-------|-------|----------------|
| Sheikh Hamza Yusuf | hamza.yusuf@muip.org | +60123456789 | Youth Counseling, Arabic Language |
| Sheikh Omar Suleiman | omar.suleiman@muip.org | +60123456790 | Community Outreach, Islamic History |
| Sheikh Yasir Qadhi | yasir.qadhi@muip.org | +60123456791 | Tafseer, Islamic Philosophy |
| Sheikh Nouman Ali Khan | nouman.khan@muip.org | +60123456792 | Quran Translation, Youth Programs |
| Sheikh Mufti Menk | mufti.menk@muip.org | +60123456793 | Fatwa Issuance, Family Counseling |

Each preacher has:
- ✅ Complete profile with qualifications
- ✅ KPI targets for 3 months
- ✅ Progress data showing different achievement levels (50%-100%)

---

## Clear All Data (If Needed)

If you want to start fresh:

1. Open the app
2. Go to **"Populate Firebase Data"** page
3. Click **"Clear All Data"** (red button)
4. Confirm deletion

⚠️ **Warning:** This permanently deletes all KPI-related data!

---

## Troubleshooting

### "Permission Denied" Error
**Solution:** Update Firestore Rules in Firebase Console:

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

### "Collection Not Found"
**Solution:** Run the data populator first. Collections are created automatically when you add the first document.

### Data Not Showing in App
**Solution:** 
1. Check your internet connection
2. Verify Firebase initialization in `main.dart`
3. Check console for errors: `flutter run`

---

## Files Created

### Models
- ✅ `lib/models/User.dart` (Preacher) - Updated with Firestore
- ✅ `lib/models/KPITarget.dart` - Updated with Firestore
- ✅ `lib/models/KPIProgress.dart` - Updated with Firestore
- ✅ `lib/models/PreacherProfile.dart` - NEW
- ✅ `lib/models/SavedReport.dart` - NEW

### Services
- ✅ `lib/services/firestore_service.dart` - Complete CRUD operations

### Utilities
- ✅ `lib/utils/populate_firebase_data.dart` - Data population script

### Configuration
- ✅ `lib/firebase_options.dart` - Auto-generated Firebase config
- ✅ `pubspec.yaml` - Updated with Firebase dependencies

---

## Next Steps

1. ✅ Run `flutter run`
2. ✅ Click "Populate Firebase Data"
3. ✅ Create sample data
4. ✅ Test the KPI Management pages
5. ✅ View data in Firebase Console

**Your Firebase database is ready to use! 🎉**
