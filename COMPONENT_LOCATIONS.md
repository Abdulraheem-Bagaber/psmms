# 📋 KPI Management Module - Component Location Guide

**MUIP Preacher Monitoring System**  
**Module**: 2.2.6 - KPI Management  
**Date**: November 28, 2025

---

## 📁 PROJECT STRUCTURE

```
c:\xampp\htdocs\SEP\flutter_application_1\lib\
├── main.dart                                    # Application Entry Point
│
├── models/                                      # DOMAIN LAYER (3 Models)
│   ├── preacher.dart                           # ✓ Preacher Model
│   ├── kpi.dart                                # ✓ KPI Model
│   └── kpi_progress.dart                       # ✓ KPIProgress Model
│
├── controllers/                                 # CONTROLLER LAYER (2 Controllers)
│   ├── preacher_controller.dart                # ✓ PreacherController
│   └── kpi_controller.dart                     # ✓ KPIController
│
├── services/                                    # SERVICE LAYER (1 Service)
│   └── database_service.dart                   # ✓ DatabaseService
│
└── pages/                                       # PRESENTATION LAYER (4 Pages)
    ├── senarai_pendakwah_page.dart             # ✓ Page 1: Preacher Directory
    ├── manage_kpi_page.dart                    # ✓ Page 2: Edit KPI Form
    ├── my_kpi_dashboard_page.dart              # ✓ Page 3: Preacher KPI Dashboard
    └── (preacher_detail_page.dart)             # ⚠️ Page 4: TO BE CREATED
```

---

## 🎯 YOUR 4 PAGES FOR KPI MODULE

### **Page 1: Preacher Directory** ✓ EXISTS
- **Current File**: `lib/pages/senarai_pendakwah_page.dart`
- **Component Name for SDD**: `PreacherDirectoryPage`
- **Actor**: MUIP Official
- **Purpose**: Displays searchable directory of all preachers
- **Features**: 
  - Search by name
  - List all preachers with avatars
  - Navigate to Edit KPI page
- **Current Implementation**: ✓ Complete

---

### **Page 2: Edit KPI Form** ✓ EXISTS
- **Current File**: `lib/pages/manage_kpi_page.dart`
- **Component Name for SDD**: `EditKPIPage`
- **Actor**: MUIP Official
- **Purpose**: Form to set/update KPI targets
- **Features**:
  - 7 KPI metric input fields
  - Date range picker
  - Form validation
  - Save/Update button
- **Current Implementation**: ✓ Complete

---

### **Page 3: Preacher KPI Dashboard** ✓ EXISTS
- **Current File**: `lib/pages/my_kpi_dashboard_page.dart`
- **Component Name for SDD**: `PreacherKPIDashboardPage`
- **Actor**: Preacher
- **Purpose**: View KPI targets and real-time progress
- **Features**:
  - Overall progress summary
  - Individual KPI progress bars
  - Color-coded status (Green/Yellow/Red)
  - Period selection (Monthly/Quarterly/Yearly)
- **Current Implementation**: ✓ Complete

---

### **Page 4: Preacher Detail/Profile** ⚠️ NOT CREATED YET
- **File to Create**: `lib/pages/preacher_detail_page.dart`
- **Component Name for SDD**: `PreacherDetailPage`
- **Actor**: MUIP Official / Preacher
- **Purpose**: Comprehensive profile view with tabs
- **Features to Implement**:
  - Personal information display
  - Tabs:
    - Performance History (KPI over time)
    - Skill Profiles
    - Training Schedules
    - Payment Summaries
- **Status**: ⚠️ **NEEDS TO BE CREATED**

---

## 📊 DOMAIN LAYER - MODELS (3 Total)

### **Model 1: Preacher** ✓
- **File**: `lib/models/preacher.dart`
- **Package**: `com.muip.psm.domain`
- **Component Name for SDD**: `Preacher`

**Attributes (6):**
```dart
- id: int?
- name: String
- email: String
- phone: String
- avatarUrl: String?
- status: String
```

**Methods (3):**
```dart
- toMap(): Map<String, dynamic>
- fromMap(Map): Preacher
- copyWith(...): Preacher
```

---

### **Model 2: KPI** ✓
- **File**: `lib/models/kpi.dart`
- **Package**: `com.muip.psm.domain`
- **Component Name for SDD**: `KPI`

**Attributes (12):**
```dart
- id: int?
- preacherId: int
- monthlySessionTarget: int
- totalAttendanceTarget: int
- newConvertsTarget: int
- baptismsTarget: int
- communityProjectsTarget: int
- charityEventsTarget: int
- youthProgramAttendanceTarget: int
- startDate: DateTime
- endDate: DateTime
- createdAt: DateTime
- updatedAt: DateTime?
```

**Methods (3):**
```dart
- toMap(): Map<String, dynamic>
- fromMap(Map): KPI
- copyWith(...): KPI
```

---

### **Model 3: KPIProgress** ✓
- **File**: `lib/models/kpi_progress.dart`
- **Package**: `com.muip.psm.domain`
- **Component Name for SDD**: `KPIProgress`

**Attributes (10):**
```dart
- id: int?
- kpiId: int
- preacherId: int
- sessionsCompleted: int
- totalAttendanceAchieved: int
- newConvertsAchieved: int
- baptismsAchieved: int
- communityProjectsAchieved: int
- charityEventsAchieved: int
- youthProgramAttendanceAchieved: int
- lastUpdated: DateTime
```

**Methods (5):**
```dart
- toMap(): Map<String, dynamic>
- fromMap(Map): KPIProgress
- copyWith(...): KPIProgress
- calculateProgress(int, int): double
- getStatusColor(double): String
```

---

## 🎮 CONTROLLER LAYER (2 Total)

### **Controller 1: PreacherController** ✓
- **File**: `lib/controllers/preacher_controller.dart`
- **Package**: `com.muip.psm.controllers`
- **Component Name for SDD**: `PreacherController`
- **Pattern**: Provider (ChangeNotifier)

**State Variables (5):**
```dart
- _preachers: List<Preacher>
- _filteredPreachers: List<Preacher>
- _selectedPreacher: Preacher?
- _isLoading: bool
- _error: String?
```

**Public Methods (5):**
```dart
- loadPreachers(): Future<void>
- searchPreachers(String): Future<void>
- selectPreacher(Preacher): void
- clearSelection(): void
- getPreacherById(int): Future<Preacher?>
```

**Getters (5):**
```dart
- preachers
- filteredPreachers
- selectedPreacher
- isLoading
- error
```

---

### **Controller 2: KPIController** ✓
- **File**: `lib/controllers/kpi_controller.dart`
- **Package**: `com.muip.psm.controllers`
- **Component Name for SDD**: `KPIController`
- **Pattern**: Provider (ChangeNotifier)

**State Variables (5):**
```dart
- _currentKPI: KPI?
- _currentProgress: KPIProgress?
- _isLoading: bool
- _error: String?
- _successMessage: String?
```

**Public Methods (7):**
```dart
- loadKPI(int, DateTime, DateTime): Future<void>
- saveKPITargets({...}): Future<bool>
- loadPreacherProgress(int): Future<void>
- calculateOverallProgress(): double
- updateProgressFromActivity({...}): Future<void>
- clearMessages(): void
- clearKPI(): void
```

**Getters (5):**
```dart
- currentKPI
- currentProgress
- isLoading
- error
- successMessage
```

---

## 🔧 SERVICE LAYER (1 Service)

### **Service 1: DatabaseService** ✓
- **File**: `lib/services/database_service.dart`
- **Package**: `com.muip.psm.services`
- **Component Name for SDD**: `DatabaseService`
- **Pattern**: Singleton

**Database Methods (11):**

**Preacher Operations (3):**
```dart
- getAllPreachers(): Future<List<Preacher>>
- getPreacherById(int): Future<Preacher?>
- searchPreachers(String): Future<List<Preacher>>
```

**KPI Operations (4):**
```dart
- createKPI(KPI): Future<int>
- updateKPI(KPI): Future<int>
- getKPIByPreacherId(int, DateTime, DateTime): Future<KPI?>
- getAllKPIsByPreacherId(int): Future<List<KPI>>
```

**Progress Operations (4):**
```dart
- createKPIProgress(KPIProgress): Future<int>
- updateKPIProgress(KPIProgress): Future<int>
- getProgressByKPIId(int): Future<KPIProgress?>
- getProgressByPreacherId(int): Future<KPIProgress?>
```

---

## 💾 DATABASE LAYER (3 Tables)

### **Table 1: preachers**
```sql
Columns (6):
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: TEXT NOT NULL
- email: TEXT NOT NULL UNIQUE
- phone: TEXT NOT NULL
- avatar_url: TEXT
- status: TEXT DEFAULT 'active'
```

### **Table 2: kpis**
```sql
Columns (12):
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- preacher_id: INTEGER NOT NULL (FK)
- monthly_session_target: INTEGER NOT NULL
- total_attendance_target: INTEGER NOT NULL
- new_converts_target: INTEGER NOT NULL
- baptisms_target: INTEGER NOT NULL
- community_projects_target: INTEGER NOT NULL
- charity_events_target: INTEGER NOT NULL
- youth_program_attendance_target: INTEGER NOT NULL
- start_date: TEXT NOT NULL
- end_date: TEXT NOT NULL
- created_at: TEXT NOT NULL
- updated_at: TEXT
```

### **Table 3: kpi_progress**
```sql
Columns (10):
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- kpi_id: INTEGER NOT NULL (FK)
- preacher_id: INTEGER NOT NULL (FK)
- sessions_completed: INTEGER DEFAULT 0
- total_attendance_achieved: INTEGER DEFAULT 0
- new_converts_achieved: INTEGER DEFAULT 0
- baptisms_achieved: INTEGER DEFAULT 0
- community_projects_achieved: INTEGER DEFAULT 0
- charity_events_achieved: INTEGER DEFAULT 0
- youth_program_attendance_achieved: INTEGER DEFAULT 0
- last_updated: TEXT NOT NULL
```

---

## 📝 FOR YOUR SDD DOCUMENT

### **Component Count Summary:**

| Layer | Count | Components |
|-------|-------|------------|
| **Pages** | **4** | PreacherDirectoryPage, EditKPIPage, PreacherKPIDashboardPage, PreacherDetailPage* |
| **Controllers** | **2** | PreacherController, KPIController |
| **Models** | **3** | Preacher, KPI, KPIProgress |
| **Services** | **1** | DatabaseService |
| **Database Tables** | **3** | preachers, kpis, kpi_progress |
| **TOTAL** | **13** | Complete components |

*Note: PreacherDetailPage needs to be created

---

## 🎯 COMPONENT NAMES FOR SDD DOCUMENTATION

Copy these **exact names** into your SDD document:

### **Presentation Layer (Pages)**
1. `PreacherDirectoryPage` - Preacher list with search
2. `EditKPIPage` - KPI target management form
3. `PreacherKPIDashboardPage` - Preacher progress dashboard
4. `PreacherDetailPage` - Comprehensive profile view ⚠️ TO CREATE

### **Controller Layer (Providers)**
5. `PreacherController` - Manages preacher data and state
6. `KPIController` - Manages KPI and progress state

### **Domain Layer (Models)**
7. `Preacher` - Preacher entity model
8. `KPI` - KPI targets model
9. `KPIProgress` - Progress tracking model

### **Service Layer**
10. `DatabaseService` - Database operations service

### **Data Layer (Tables)**
11. `preachers` - Preacher information table
12. `kpis` - KPI targets table
13. `kpi_progress` - Progress tracking table

---

## 📦 PACKAGE STRUCTURE FOR SDD

```
com.muip.psm
├── pages                    # Presentation Layer
│   ├── PreacherDirectoryPage
│   ├── EditKPIPage
│   ├── PreacherKPIDashboardPage
│   └── PreacherDetailPage (⚠️ to create)
│
├── controllers              # Controller Layer
│   ├── PreacherController
│   └── KPIController
│
├── domain                   # Domain Layer
│   ├── Preacher
│   ├── KPI
│   └── KPIProgress
│
└── services                 # Service Layer
    └── DatabaseService
```

---

## 🔗 PAGE NAVIGATION FLOW

```
main.dart (HomePage)
    │
    ├─> PreacherDirectoryPage (MUIP Official)
    │       │
    │       └─> EditKPIPage (Selected Preacher)
    │               │
    │               └─> PreacherDetailPage* (View Profile)
    │
    └─> PreacherKPIDashboardPage (Preacher)
            │
            └─> PreacherDetailPage* (Own Profile)
```

*Note: PreacherDetailPage needs to be created

---

## 📊 METHOD COUNT BY COMPONENT

| Component | Public Methods | Private Methods | Getters | Total |
|-----------|----------------|-----------------|---------|-------|
| Preacher | 3 | 0 | 0 | 3 |
| KPI | 3 | 0 | 0 | 3 |
| KPIProgress | 5 | 0 | 0 | 5 |
| PreacherController | 5 | 0 | 5 | 10 |
| KPIController | 7 | 0 | 5 | 12 |
| DatabaseService | 11 | 2 | 1 | 14 |
| **TOTAL** | **34** | **2** | **11** | **47** |

---

## ⚠️ WHAT'S MISSING

### **Page 4: PreacherDetailPage** - NOT CREATED YET

You mentioned this page should have:
- ✅ Comprehensive profile view
- ✅ Tabs for:
  - Performance History (KPI over time)
  - Skill Profiles
  - Training Schedules
  - Payment Summaries

**Would you like me to create this 4th page now?**

---

## 🚀 CURRENT STATUS

✅ **Complete (3/4 Pages):**
1. PreacherDirectoryPage - Working
2. EditKPIPage - Working
3. PreacherKPIDashboardPage - Working

⚠️ **To Do (1/4 Pages):**
4. PreacherDetailPage - **NEEDS CREATION**

✅ **All Controllers**: 2/2 Complete
✅ **All Models**: 3/3 Complete
✅ **All Services**: 1/1 Complete
✅ **All Database Tables**: 3/3 Complete

---

## 📋 QUICK REFERENCE FOR SDD

**Total Components: 13**
- 4 Pages (3 exist, 1 to create)
- 2 Controllers (both complete)
- 3 Models (all complete)
- 1 Service (complete)
- 3 Database Tables (all complete)

**Total Lines of Code: ~2,500+**
- Models: ~400 lines
- Controllers: ~500 lines
- Service: ~600 lines
- Pages: ~1,000 lines

---

**Last Updated**: November 28, 2025  
**Module**: KPI Management (2.2.6)  
**Status**: 92% Complete (Missing PreacherDetailPage)
