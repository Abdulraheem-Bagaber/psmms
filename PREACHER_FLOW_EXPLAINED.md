# Preacher Dashboard Flow - Fully Explained

## 📋 Basic Flow from Your SDD Document

According to your Software Requirements Specification (page 37), here's the complete flow:

### For MUIP Official (Steps 1-9):
1. MUIP Official navigates to "Manage KPI" section
2. System displays list of all Preachers
3. MUIP Official selects a Preacher to manage
4. System shows form to set the Preacher's KPI targets
5. MUIP Official enters target values (Monthly Sessions, Total Attendance, etc.)
6. MUIP Official clicks "Save Targets" button
7. System saves KPI targets in the database
8. System displays success message
9. Use case ends for MUIP Official

### For Preacher (Steps 10-12):
10. **A Preacher logs in to the system and navigates to their "Dashboard"**
11. **System displays the Preacher's progress** (e.g., "Monthly Sessions: 3/10")
12. Use case ends for the Preacher

## 🔄 How This Works with Firebase Integration

### Current Implementation

Your app now has **THREE main entry points** on the home screen:

```
┌─────────────────────────────────────┐
│      MUIP PSM                       │
│   KPI Management System             │
│                                     │
│  📊 Manage KPI (MUIP Official)     │  ← Steps 1-9
│  📈 View Dashboard (Preacher)      │  ← Steps 10-12
│  ☁️  Populate Firebase Data         │  ← Setup tool
└─────────────────────────────────────┘
```

## 🔑 The Flow Now Works Like This:

### Step 1: First Time Setup
```
User → Click "Populate Firebase Data"
     → Creates 5 sample preachers in Firestore
     → Creates KPI targets for each preacher
     → Creates progress records for each preacher
```

**Firebase Collections Created:**
- `preachers` - Ahmad Ibrahim, Fatimah Zahra, Ali Hassan, etc.
- `kpi_targets` - Target goals for each preacher
- `kpi_progress` - Current achievement data
- `preacher_profiles` - Extended profile info
- `saved_reports` - Report metadata

### Step 2: Preacher Logs In (NEW!)
```
User → Click "View Dashboard (Preacher)"
     → Opens PreacherLoginPage
     → Shows list of all preachers from Firestore
     → User selects their name (e.g., "Ahmad Ibrahim")
     → App navigates to MyKPIDashboardPage with that preacher's ID
```

### Step 3: Dashboard Displays Data
```
MyKPIDashboardPage receives preacherId
                  ↓
        Calls loadPreacherProgress(preacherId)
                  ↓
        KPIController fetches from Firestore:
        - kpi_targets for this preacher
        - kpi_progress for this preacher
                  ↓
        Dashboard shows:
        ✅ Overall Progress (90%)
        ✅ Sermons Delivered (18/25 = 72%)
        ✅ New Member Registrations (8/10 = 80%)
        ✅ Baptisms Conducted (5/5 = 100%)
        ✅ Community Projects (3/4 = 75%)
        ✅ Charity Events (7/8 = 87.5%)
        ✅ Youth Program Attendance (850/1000 = 85%)
```

## 📊 Model Integration Explained

### How All 5 Models Work Together:

#### 1. **Preacher Model (User.dart)**
```dart
class Preacher {
  String? id;              // Firebase document ID
  String name;             // "Ahmad Ibrahim"
  String email;            // "ahmad@muip.org"
  String? phone;           // "0123456789"
  String role;             // "preacher"
  DateTime createdAt;
}
```
**Purpose:** Identifies who the person is
**Used by:** Login selection, dashboard header, KPI assignment

#### 2. **PreacherProfile Model**
```dart
class PreacherProfile {
  String? id;
  String preacherId;                    // Links to Preacher
  String fullAddress;
  String icNumber;
  List<String> qualifications;          // ["Bachelor in Islamic Studies"]
  List<String> specializedSkills;       // ["Youth mentoring"]
  int yearsOfExperience;
  String preferredLanguage;
}
```
**Purpose:** Extended biographical info
**Used by:** Profile pages, reports, admin management
**Relationship:** One Preacher → One PreacherProfile

#### 3. **KPITarget Model**
```dart
class KPITarget {
  String? id;
  String preacherId;                    // Links to Preacher
  int monthlySessionTarget;             // e.g., 25
  int totalAttendanceTarget;            // e.g., 200
  int newConvertsTarget;                // e.g., 10
  int baptismsTarget;                   // e.g., 5
  int communityProjectsTarget;          // e.g., 4
  int charityEventsTarget;              // e.g., 8
  int youthProgramAttendanceTarget;     // e.g., 1000
  String period;                        // "Monthly"
  DateTime startDate;
  DateTime endDate;
}
```
**Purpose:** Goals set by MUIP Official
**Used by:** Dashboard progress calculations, forms
**Relationship:** One Preacher → Many KPITargets (different periods)

#### 4. **KPIProgress Model**
```dart
class KPIProgress {
  String? id;
  String kpiTargetId;                   // Links to KPITarget
  String preacherId;                    // Links to Preacher
  
  // Actual achievements
  int sessionsCompleted;                // e.g., 18 (out of 25)
  int totalAttendanceAchieved;          // e.g., 180 (out of 200)
  int newConvertsAchieved;              // e.g., 8
  int baptismsAchieved;                 // e.g., 5
  int communityProjectsAchieved;        // e.g., 3
  int charityEventsAchieved;            // e.g., 7
  int youthProgramAttendanceAchieved;   // e.g., 850
  
  DateTime lastUpdated;
}
```
**Purpose:** Track actual performance vs targets
**Used by:** Dashboard displays, progress bars, reports
**Relationship:** One KPITarget → One KPIProgress (1:1 tracking)

#### 5. **SavedReport Model**
```dart
class SavedReport {
  String? id;
  String reportName;
  String reportType;                    // "monthly", "quarterly", "yearly"
  Map<String, dynamic> filters;         // Search criteria used
  DateTime generatedDate;
  String generatedBy;                   // User ID who created it
}
```
**Purpose:** Metadata for generated reports
**Used by:** Report history, re-running reports
**Relationship:** Many reports can reference same preacher

## 🔗 Complete Data Flow Example

Let's trace what happens when Ahmad Ibrahim logs in:

### 1. Login Selection
```
PreacherLoginPage
  └─ Calls: preacherController.loadPreachers()
       └─ Queries Firestore: collection('preachers').get()
            └─ Returns: [Ahmad, Fatimah, Ali, Sarah, Yusuf]
  
  └─ User taps: "Ahmad Ibrahim"
       └─ Navigates with: preacherId = "preacher_001"
```

### 2. Dashboard Initialization
```
MyKPIDashboardPage(preacherId: "preacher_001")
  └─ Calls: kpiController.loadPreacherProgress("preacher_001")
       
       Step A: Load KPI Target
       └─ Queries: kpi_targets WHERE preacherId = "preacher_001"
            └─ Returns: KPITarget {
                 id: "kpi_target_001",
                 monthlySessionTarget: 25,
                 totalAttendanceTarget: 200,
                 ...
               }
       
       Step B: Load Progress
       └─ Queries: kpi_progress WHERE kpiTargetId = "kpi_target_001"
            └─ Returns: KPIProgress {
                 id: "progress_001",
                 sessionsCompleted: 18,
                 totalAttendanceAchieved: 180,
                 ...
               }
       
       Step C: Calculate Percentages
       └─ Controller calculates:
            • Sermons: 18/25 = 72%
            • Attendance: 180/200 = 90%
            • Baptisms: 5/5 = 100%
            • Overall: Average = 90%
```

### 3. Display Results
```
Dashboard UI shows:
┌────────────────────────────────────┐
│ Welcome, Ahmad Ibrahim             │  ← From Preacher model
│                                    │
│ Overall Monthly Progress: 90%     │  ← Calculated from Progress
│ ████████████████████░░ Keep it up! │
│                                    │
│ 📢 Sermons Delivered               │
│    18 / 25 (72%)                   │  ← Progress vs Target
│ ⚠️ At Risk                         │  ← Status logic
│                                    │
│ 👥 New Member Registrations        │
│    8 / 10 (80%)                    │
│ ✅ On Track                        │
└────────────────────────────────────┘
```

## 🎯 Key Features Now Working

### For Preachers:
✅ **Login/Selection** - Choose your profile from list
✅ **Real-time Progress** - See live data from Firestore
✅ **Period Toggle** - Switch between Monthly/Quarterly/Yearly
✅ **Visual Indicators** - Progress bars, status icons
✅ **Metric Details** - Each KPI shows target vs achievement

### For MUIP Officials:
✅ **Preacher Management** - View all preachers
✅ **KPI Assignment** - Set targets via KPIFormPage
✅ **Progress Monitoring** - See all preachers' performance

### Data Flow Features:
✅ **Firestore Sync** - All data stored in cloud
✅ **Automatic Calculations** - Progress % computed automatically
✅ **Period Filtering** - Data segmented by time periods
✅ **Error Handling** - Graceful failures with retry options

## 🚀 Next Steps for Enhancement

### 1. Add Real Authentication
```dart
// Instead of selecting from a list, use Firebase Auth
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: "ahmad@muip.org",
  password: "password123"
);
```

### 2. Add Progress Updates
```dart
// Let preachers update their own achievements
FloatingActionButton(
  onPressed: () {
    // Open form to add +1 sermon, +10 attendance, etc.
  },
  child: Icon(Icons.add),
);
```

### 3. Add Profile Editing
```dart
// Let preachers update their PreacherProfile
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditProfilePage(preacherId: preacherId),
  ),
);
```

### 4. Add Notifications
```dart
// Alert when approaching targets or falling behind
if (progress < 50% && daysRemaining < 10) {
  showNotification("You're behind schedule!");
}
```

## 📝 Summary

**Your basic flow is now fully implemented:**

| Step | Description | Implementation |
|------|-------------|----------------|
| 1-9 | MUIP sets targets | `KPIPreacherListPage` → `KPIFormPage` |
| 10 | Preacher logs in | `PreacherLoginPage` (NEW!) |
| 11 | Dashboard shows progress | `MyKPIDashboardPage` with Firestore data |
| 12 | End | User can navigate back or view details |

**All 5 models work together:**
- **Preacher** = Who you are
- **PreacherProfile** = Your detailed info
- **KPITarget** = What you should achieve
- **KPIProgress** = What you've achieved
- **SavedReport** = Historical records

**Firebase handles:**
- ✅ Data storage (Firestore collections)
- ✅ Real-time sync (Stream updates)
- ✅ Cloud access (Multiple devices)
- ✅ Data relationships (Document references)

Your app is now a **complete KPI management system** with cloud database integration! 🎉
