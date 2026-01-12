# 🚀 KPI Module - Team Integration Guide

## ✅ Your Firebase is Ready!

I can see your Firestore already has:
- ✅ `kpi_progress` collection
- ✅ `kpi_targets` collection
- ✅ `preachers` collection

Perfect! Now let's integrate the KPI module into your team project.

---

## 📍 Your KPI Files Location

### Controller
```
lib/viewmodels/kpi_management_controller.dart
```

### Models
```
lib/models/kpi_target.dart
lib/models/kpi_progress.dart
```

### Views (Pages)
```
lib/views/kpi/kpi_dashboard_page.dart      (Preacher view)
lib/views/kpi/kpi_form_page.dart           (MUIP Official form)
lib/views/kpi/kpi_preacher_list_page.dart  (Preacher selection)
```

---

## 🎯 How to Use in Your App

### 1️⃣ Add KPI Navigation to Your Main Screen

**Example: Add to Officer Dashboard**
```dart
// In your officer home screen
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PreacherController()),
            ChangeNotifierProvider(create: (_) => KPIManagementController()),
          ],
          child: const KPIPreacherListPage(),
        ),
      ),
    );
  },
  child: const Text('Manage KPIs'),
),
```

### 2️⃣ Add to Preacher Dashboard

**Example: Add KPI view for preachers**
```dart
// In your preacher home screen
import 'package:psmms/views/kpi/kpi_dashboard_page.dart';
import 'package:psmms/viewmodels/kpi_management_controller.dart';

// Get preacher ID from your auth system
final String preacherId = 'PREACHER-001'; // Replace with actual ID

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => KPIManagementController(),
          child: KPIDashboardPage(preacherId: preacherId),
        ),
      ),
    );
  },
  icon: const Icon(Icons.analytics),
  label: const Text('My KPI Dashboard'),
),
```

---

## 🔗 Integration with Your Existing Activity System

### Update KPI Progress When Activity is Submitted

**In your activity submission code, add:**

```dart
import 'package:psmms/viewmodels/kpi_management_controller.dart';

// After successfully submitting an activity
Future<void> _submitActivity() async {
  // Your existing activity submission code...
  
  // Update KPI progress
  final kpiController = KPIManagementController();
  await kpiController.updateProgressFromActivity(
    preacherId: assignedPreacherId,
    sessionsIncrement: 1,              // Activity completed
    attendanceIncrement: attendanceCount,  // From your activity form
    // Add other metrics based on activity type:
    // convertsIncrement: newMembersCount,
    // baptismsIncrement: baptismCount,
    // projectsIncrement: isProjectType ? 1 : 0,
    // eventsIncrement: isEventType ? 1 : 0,
    // youthAttendanceIncrement: youthCount,
  );
}
```

---

## 📱 Quick Test

### Test KPI Module Now:

1. **Create the demo page in your app:**

```dart
// Add to your main.dart or create a test screen
import 'package:psmms/kpi_module_demo.dart';

// Navigate to it:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const KPIModuleDemo()),
);
```

2. **Or directly test the pages:**

**For Officers (Set KPI):**
```dart
import 'package:psmms/views/kpi/kpi_preacher_list_page.dart';
import 'package:psmms/viewmodels/preacher_controller.dart';
import 'package:psmms/viewmodels/kpi_management_controller.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreacherController()),
        ChangeNotifierProvider(create: (_) => KPIManagementController()),
      ],
      child: const KPIPreacherListPage(),
    ),
  ),
);
```

**For Preachers (View Progress):**
```dart
import 'package:psmms/views/kpi/kpi_dashboard_page.dart';
import 'package:psmms/viewmodels/kpi_management_controller.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (_) => KPIManagementController(),
      child: const KPIDashboardPage(
        preacherId: 'PREACHER-001', // Use actual preacher ID
      ),
    ),
  ),
);
```

---

## 🎨 Where to Add KPI Links in Your Team App

### Option 1: Add to Bottom Navigation
If you have a bottom nav bar, add a KPI tab:

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Activities'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'KPI'),  // New!
    BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
  ],
  onTap: (index) {
    if (index == 2) {
      // Navigate to KPI based on user role
      if (userRole == 'preacher') {
        // Show KPI Dashboard
      } else if (userRole == 'officer') {
        // Show KPI Management
      }
    }
  },
)
```

### Option 2: Add to Drawer Menu
```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: const Icon(Icons.analytics),
        title: const Text('KPI Management'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => PreacherController()),
                  ChangeNotifierProvider(create: (_) => KPIManagementController()),
                ],
                child: const KPIPreacherListPage(),
              ),
            ),
          );
        },
      ),
    ],
  ),
)
```

### Option 3: Add Card in Dashboard
```dart
// In your officer dashboard grid
GridView.count(
  children: [
    _buildDashboardCard(
      icon: Icons.analytics,
      title: 'Manage KPIs',
      subtitle: 'Set preacher targets',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PreacherController()),
                ChangeNotifierProvider(create: (_) => KPIManagementController()),
              ],
              child: const KPIPreacherListPage(),
            ),
          ),
        );
      },
    ),
  ],
)
```

---

## 🔍 Your Controller Methods

### Available Methods in `KPIManagementController`:

```dart
// Load KPI for a specific period
await controller.loadKPI(preacherId, startDate, endDate);

// Save/Update KPI targets (MUIP Officer)
await controller.saveKPITargets(
  preacherId: 'PREACHER-001',
  monthlySessionTarget: 20,
  totalAttendanceTarget: 500,
  newConvertsTarget: 15,
  baptismsTarget: 10,
  communityProjectsTarget: 5,
  charityEventsTarget: 8,
  youthProgramAttendanceTarget: 100,
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 1, 31),
);

// Load progress for dashboard (Preacher)
await controller.loadPreacherProgress(preacherId);

// Calculate overall progress percentage
double progress = controller.calculateOverallProgress();

// Update progress from Activity module
await controller.updateProgressFromActivity(
  preacherId: 'PREACHER-001',
  sessionsIncrement: 1,
  attendanceIncrement: 50,
);

// Clear data
controller.clearKPI();
controller.clearMessages();
```

---

## ✅ Checklist for Team Integration

- [ ] Test KPI pages work with your Firebase
- [ ] Add KPI navigation to officer dashboard
- [ ] Add KPI navigation to preacher dashboard
- [ ] Connect KPI progress updates to activity submissions
- [ ] Test with real preacher IDs from your database
- [ ] Add to your app's routing/navigation system
- [ ] Update team documentation

---

## 🆘 Need Help?

**Common Issues:**

1. **"Preacher not found"** → Make sure you're using the correct `preacherId` from your `preachers` collection
2. **"No KPI set"** → Use the KPI Form page to create targets first
3. **Provider errors** → Make sure to wrap pages with `ChangeNotifierProvider`

---

**Your KPI module is ready to use! Just add the navigation links above to your existing app screens.** 🚀
