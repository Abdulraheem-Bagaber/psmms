# Software Design Document (SDD)
## Module 2.2.6: KPI Management

**MUIP Preacher Monitoring System**

---

## Table of Contents
1. [System Architecture](#1-system-architecture)
2. [Component Design](#2-component-design)
3. [Database Design](#3-database-design)
4. [Sequence Diagrams](#4-sequence-diagrams)
5. [Data Flow Diagrams](#5-data-flow-diagrams)
6. [Component Reference](#6-component-reference)

---

## 1. System Architecture

### 1.1 Architectural Pattern
**Pattern**: Model-View-Controller (MVC) with Provider State Management

### 1.2 Layer Structure

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │
│  (Pages - UI Components)                    │
│  - Senarai_Pendakwah_Page.dart             │
│  - Edit_KPI_Page.dart                       │
│  - My_KPI_Dashboard_Page.dart               │
└──────────────┬──────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────┐
│         CONTROLLER LAYER                    │
│  (State Management - Provider Pattern)      │
│  - PreacherController                       │
│  - KPIController                             │
└──────────────┬──────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────┐
│           SERVICE LAYER                     │
│  (Business Logic & Data Access)             │
│  - DatabaseService                          │
└──────────────┬──────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────┐
│           DOMAIN LAYER                      │
│  (Models - Data Structures)                 │
│  - Preacher                                 │
│  - KPI                                      │
│  - KPIProgress                              │
└─────────────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────────┐
│         DATA LAYER                          │
│  (SQLite Database)                          │
│  - preachers table                          │
│  - kpis table                               │
│  - kpi_progress table                       │
└─────────────────────────────────────────────┘
```

---

## 2. Component Design

### 2.1 Domain Layer (Models)

#### 2.1.1 Preacher Model
**File**: `lib/models/preacher.dart`  
**Component Name**: `Preacher`  
**Package**: `com.muip.psm.domain`

**Attributes:**
- `id: int?` - Unique identifier
- `name: String` - Preacher full name
- `email: String` - Contact email (unique)
- `phone: String` - Contact phone number
- `avatarUrl: String?` - Profile picture URL (optional)
- `status: String` - Account status ('active', 'inactive', 'suspended')

**Methods:**
- `toMap(): Map<String, dynamic>` - Convert to database format
- `fromMap(Map<String, dynamic>): Preacher` - Create from database
- `copyWith(...)`: Preacher` - Create modified copy

---

#### 2.1.2 KPI Model
**File**: `lib/models/kpi.dart`  
**Component Name**: `KPI`  
**Package**: `com.muip.psm.domain`

**Attributes:**
- `id: int?` - Unique identifier
- `preacherId: int` - Foreign key to Preacher
- `monthlySessionTarget: int` - Target for monthly sessions
- `totalAttendanceTarget: int` - Target for total attendance
- `newConvertsTarget: int` - Target for new converts
- `baptismsTarget: int` - Target for baptisms
- `communityProjectsTarget: int` - Target for community projects
- `charityEventsTarget: int` - Target for charity events
- `youthProgramAttendanceTarget: int` - Target for youth attendance
- `startDate: DateTime` - Performance period start
- `endDate: DateTime` - Performance period end
- `createdAt: DateTime` - Record creation timestamp
- `updatedAt: DateTime?` - Last modification timestamp

**Methods:**
- `toMap(): Map<String, dynamic>` - Convert to database format
- `fromMap(Map<String, dynamic>): KPI` - Create from database
- `copyWith(...): KPI` - Create modified copy

---

#### 2.1.3 KPIProgress Model
**File**: `lib/models/kpi_progress.dart`  
**Component Name**: `KPIProgress`  
**Package**: `com.muip.psm.domain`

**Attributes:**
- `id: int?` - Unique identifier
- `kpiId: int` - Foreign key to KPI
- `preacherId: int` - Foreign key to Preacher
- `sessionsCompleted: int` - Current sessions completed
- `totalAttendanceAchieved: int` - Current attendance achieved
- `newConvertsAchieved: int` - Current converts achieved
- `baptismsAchieved: int` - Current baptisms achieved
- `communityProjectsAchieved: int` - Current projects achieved
- `charityEventsAchieved: int` - Current events achieved
- `youthProgramAttendanceAchieved: int` - Current youth attendance
- `lastUpdated: DateTime` - Last progress update timestamp

**Methods:**
- `toMap(): Map<String, dynamic>` - Convert to database format
- `fromMap(Map<String, dynamic>): KPIProgress` - Create from database
- `copyWith(...): KPIProgress` - Create modified copy
- `calculateProgress(int achieved, int target): double` - Calculate percentage
- `getStatusColor(double percentage): String` - Get color based on progress

---

### 2.2 Service Layer

#### 2.2.1 DatabaseService
**File**: `lib/services/database_service.dart`  
**Component Name**: `DatabaseService`  
**Package**: `com.muip.psm.services`  
**Pattern**: Singleton

**Responsibilities:**
- Manage SQLite database connection
- Execute CRUD operations
- Handle database migrations
- Insert sample data for testing

**Public Methods:**

**Preacher Operations:**
- `getAllPreachers(): Future<List<Preacher>>` - Retrieve all preachers
- `getPreacherById(int id): Future<Preacher?>` - Get single preacher
- `searchPreachers(String query): Future<List<Preacher>>` - Search by name

**KPI Operations:**
- `createKPI(KPI kpi): Future<int>` - Create new KPI targets
- `updateKPI(KPI kpi): Future<int>` - Update existing targets
- `getKPIByPreacherId(int preacherId, DateTime start, DateTime end): Future<KPI?>` - Get KPI by period
- `getAllKPIsByPreacherId(int preacherId): Future<List<KPI>>` - Get all KPIs for preacher

**Progress Operations:**
- `createKPIProgress(KPIProgress progress): Future<int>` - Initialize progress
- `updateKPIProgress(KPIProgress progress): Future<int>` - Update progress
- `getProgressByKPIId(int kpiId): Future<KPIProgress?>` - Get progress by KPI
- `getProgressByPreacherId(int preacherId): Future<KPIProgress?>` - Get latest progress

---

### 2.3 Controller Layer (Provider)

#### 2.3.1 PreacherController
**File**: `lib/controllers/preacher_controller.dart`  
**Component Name**: `PreacherController`  
**Package**: `com.muip.psm.controllers`  
**Pattern**: Provider (ChangeNotifier)

**State Variables:**
- `_preachers: List<Preacher>` - All preachers
- `_filteredPreachers: List<Preacher>` - Filtered search results
- `_selectedPreacher: Preacher?` - Currently selected preacher
- `_isLoading: bool` - Loading state indicator
- `_error: String?` - Error message

**Public Methods:**
- `loadPreachers(): Future<void>` - Load all preachers from database
- `searchPreachers(String query): Future<void>` - Filter preachers by name
- `selectPreacher(Preacher preacher): void` - Set selected preacher
- `clearSelection(): void` - Clear selection
- `getPreacherById(int id): Future<Preacher?>` - Fetch single preacher

**Getters:**
- `preachers: List<Preacher>`
- `filteredPreachers: List<Preacher>`
- `selectedPreacher: Preacher?`
- `isLoading: bool`
- `error: String?`

---

#### 2.3.2 KPIController
**File**: `lib/controllers/kpi_controller.dart`  
**Component Name**: `KPIController`  
**Package**: `com.muip.psm.controllers`  
**Pattern**: Provider (ChangeNotifier)

**State Variables:**
- `_currentKPI: KPI?` - Current KPI being viewed/edited
- `_currentProgress: KPIProgress?` - Current progress data
- `_isLoading: bool` - Loading state indicator
- `_error: String?` - Error message
- `_successMessage: String?` - Success message

**Public Methods:**

**MUIP Official Operations:**
- `loadKPI(int preacherId, DateTime start, DateTime end): Future<void>` - Load KPI for editing
- `saveKPITargets({...}): Future<bool>` - Save new or update existing KPI
  - **Parameters**:
    - `preacherId: int`
    - `monthlySessionTarget: int`
    - `totalAttendanceTarget: int`
    - `newConvertsTarget: int`
    - `baptismsTarget: int`
    - `communityProjectsTarget: int`
    - `charityEventsTarget: int`
    - `youthProgramAttendanceTarget: int`
    - `startDate: DateTime`
    - `endDate: DateTime`
  - **Validation Rules**:
    - All targets must be positive integers
    - End date must be after start date
  - **Returns**: `true` if successful, `false` otherwise

**Preacher Operations:**
- `loadPreacherProgress(int preacherId): Future<void>` - Load progress for dashboard
- `calculateOverallProgress(): double` - Calculate average progress percentage

**Activity Management Integration:**
- `updateProgressFromActivity({...}): Future<void>` - Update progress from activities
  - Called by Module 2.2.6 (Activity Management)

**Utility Methods:**
- `clearMessages(): void` - Clear error/success messages
- `clearKPI(): void` - Reset state

**Getters:**
- `currentKPI: KPI?`
- `currentProgress: KPIProgress?`
- `isLoading: bool`
- `error: String?`
- `successMessage: String?`

---

### 2.4 Presentation Layer (Pages)

#### 2.4.1 Senarai Pendakwah Page (Preacher List)
**File**: `lib/pages/senarai_pendakwah_page.dart`  
**Component Name**: `Senarai_Pendakwah_Page.dart`  
**Package**: `com.muip.psm.pages`  
**Actor**: MUIP Official

**Use Case Steps**: Basic Flow Steps 1-3

**UI Components:**
1. **AppBar**
   - Title: "Senarai Pendakwah"
   - Back button

2. **Search Bar**
   - Hint: "Cari nama pendakwah..."
   - Icon: Search icon
   - Function: Real-time filtering

3. **Preacher List** (ListView)
   - Card design with shadow
   - Avatar circle with initials
   - Preacher name
   - Chevron right icon
   - OnTap: Navigate to Manage KPI Page

4. **Empty State**
   - Icon: People outline
   - Message: "Tiada pendakwah ditemui"
   - Subtitle: "Cuba gunakan kata kunci yang lain."

**State Management:**
- Connected to `PreacherController`
- Observes: `filteredPreachers`, `isLoading`, `error`

**Navigation:**
- **To**: `ManageKPIPage` (with selected preacher)

---

#### 2.4.2 Edit KPI Page (Manage KPI)
**File**: `lib/pages/manage_kpi_page.dart`  
**Component Name**: `Edit_KPI_Page.dart`  
**Package**: `com.muip.psm.pages`  
**Actor**: MUIP Official

**Use Case Steps**: 
- Basic Flow Steps 4-8
- Alternative Flow [A1]: Edit Existing KPI
- Exception Flow [E1]: Invalid Data

**UI Components:**
1. **AppBar**
   - Title: "Edit KPI"
   - Back button

2. **Form Header**
   - Text: "Targets for: {Preacher Name}"

3. **Input Fields** (7 fields):
   - Number of sermons
   - Number of attendees
   - Number of new converts
   - Number of baptisms
   - Number of community projects
   - Charity Events Organized
   - Youth Program Attendance

   **Field Validation:**
   - Required: "This field is required"
   - Must be number: "Must be a number"
   - Must be positive: "Must be positive"

4. **Performance Period**
   - Start Date picker
   - End Date picker
   - Format: DD/MM/YYYY

5. **Action Button**
   - Text: "Save Changes" (new KPI) or "Update Targets" (edit mode)
   - Color: Blue (#3B82F6)

**State Management:**
- Connected to `KPIController`
- Observes: `currentKPI`, `isLoading`, `error`, `successMessage`

**Form Behavior:**
- **New KPI**: Empty form
- **Edit Existing** (Alternative Flow [A1]): Pre-filled with existing values

**Dialogs:**
1. **Success Dialog** (Green background)
   - Icon: Check circle
   - Message: "KPI targets saved successfully" / "KPI targets updated successfully"

2. **Error Dialog** (Red icon)
   - Icon: Error outline
   - Displays validation errors

**Navigation:**
- **From**: `SenaraiPendakwahPage`
- **Back To**: `SenaraiPendakwahPage` (after success)

---

#### 2.4.3 My KPI Dashboard Page (Preacher View)
**File**: `lib/pages/my_kpi_dashboard_page.dart`  
**Component Name**: `My_KPI_Dashboard_Page.dart`  
**Package**: `com.muip.psm.pages`  
**Actor**: Preacher

**Use Case Steps**: 
- Basic Flow Steps 10-12
- Exception Flow [E2]: Preacher Has No KPIs Set

**UI Components:**
1. **AppBar**
   - Title: "My KPI Dashboard"
   - Back button
   - Notification icon (right)

2. **Welcome Header**
   - Text: "Welcome, Preacher"
   - Period chips: Monthly / Quarterly / Yearly

3. **Summary Card**
   - Title: "Overall Monthly Progress"
   - Percentage: Large text (e.g., "45%")
   - Progress bar with color coding
   - Message: "Keep up the great work!"

4. **KPI Metric Cards** (Multiple cards):
   - Icon with background color
   - Metric title
   - Progress: "current / target (percentage%)"
   - Progress bar
   - Status indicator:
     - ✓ "On Track" (Green) - ≥75%
     - ⚠ "At Risk" (Yellow) - 50-74%
     - ✗ "Behind" (Red) - <50%
     - ✓ "Completed" (Green) - 100%

5. **Metrics Displayed**:
   - Sermons Delivered
   - New Member Registrations
   - Charity Events Organized
   - Youth Program Attendance

6. **Bottom Navigation Bar** (5 tabs):
   - Dashboard
   - Activities
   - KPI (selected)
   - Reports
   - Profile

7. **Floating Action Button** (Blue)
   - Icon: Add (+)

**Exception Handling [E2]:**
If no KPI targets set, display:
- Icon: Info outline (orange)
- Message: "Your performance targets have not been set for this period. Please contact your Officer."
- Button: "Go Back"

**State Management:**
- Connected to `KPIController`
- Observes: `currentKPI`, `currentProgress`, `isLoading`, `error`

**Color Coding:**
- **Green** (#10B981): ≥75% progress
- **Yellow** (#F59E0B): 50-74% progress
- **Red** (#EF4444): <50% progress

**Calculations:**
- Overall progress: Average of all KPI metrics
- Individual progress: `(achieved / target) × 100`

**Navigation:**
- **From**: Main app home

---

## 3. Database Design

### 3.1 Database Type
**Technology**: SQLite (via `sqflite` package)  
**Database Name**: `muip_psm.db`  
**Version**: 1

### 3.2 Entity-Relationship Diagram

```
┌─────────────────┐
│   preachers     │
├─────────────────┤
│ id (PK)         │
│ name            │
│ email (UNIQUE)  │
│ phone           │
│ avatar_url      │
│ status          │
└────────┬────────┘
         │
         │ 1:N
         │
         ↓
┌─────────────────────────────┐
│          kpis               │
├─────────────────────────────┤
│ id (PK)                     │
│ preacher_id (FK)            │
│ monthly_session_target      │
│ total_attendance_target     │
│ new_converts_target         │
│ baptisms_target             │
│ community_projects_target   │
│ charity_events_target       │
│ youth_program_attendance... │
│ start_date                  │
│ end_date                    │
│ created_at                  │
│ updated_at                  │
└────────┬────────────────────┘
         │
         │ 1:1
         │
         ↓
┌─────────────────────────────┐
│      kpi_progress           │
├─────────────────────────────┤
│ id (PK)                     │
│ kpi_id (FK)                 │
│ preacher_id (FK)            │
│ sessions_completed          │
│ total_attendance_achieved   │
│ new_converts_achieved       │
│ baptisms_achieved           │
│ community_projects_achieved │
│ charity_events_achieved     │
│ youth_program_attendance... │
│ last_updated                │
└─────────────────────────────┘
```

### 3.3 Table Schemas

#### 3.3.1 preachers Table
**Purpose**: Store preacher information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| name | TEXT | NOT NULL | Full name |
| email | TEXT | NOT NULL, UNIQUE | Email address |
| phone | TEXT | NOT NULL | Phone number |
| avatar_url | TEXT | NULL | Profile picture URL |
| status | TEXT | DEFAULT 'active' | Account status |

**Indexes:**
- Primary Key: `id`
- Unique: `email`

---

#### 3.3.2 kpis Table
**Purpose**: Store KPI targets for preachers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| preacher_id | INTEGER | NOT NULL, FK | Reference to preacher |
| monthly_session_target | INTEGER | NOT NULL | Target sessions |
| total_attendance_target | INTEGER | NOT NULL | Target attendance |
| new_converts_target | INTEGER | NOT NULL | Target converts |
| baptisms_target | INTEGER | NOT NULL | Target baptisms |
| community_projects_target | INTEGER | NOT NULL | Target projects |
| charity_events_target | INTEGER | NOT NULL | Target events |
| youth_program_attendance_target | INTEGER | NOT NULL | Target youth attendance |
| start_date | TEXT | NOT NULL | Period start (ISO 8601) |
| end_date | TEXT | NOT NULL | Period end (ISO 8601) |
| created_at | TEXT | NOT NULL | Creation time (ISO 8601) |
| updated_at | TEXT | NULL | Last update (ISO 8601) |

**Foreign Keys:**
- `preacher_id` → `preachers(id)` ON DELETE CASCADE

**Business Rules:**
- All target values must be > 0
- `end_date` must be after `start_date`
- One KPI per preacher per period

---

#### 3.3.3 kpi_progress Table
**Purpose**: Track actual KPI achievement progress

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique identifier |
| kpi_id | INTEGER | NOT NULL, FK | Reference to KPI |
| preacher_id | INTEGER | NOT NULL, FK | Reference to preacher |
| sessions_completed | INTEGER | DEFAULT 0 | Current sessions |
| total_attendance_achieved | INTEGER | DEFAULT 0 | Current attendance |
| new_converts_achieved | INTEGER | DEFAULT 0 | Current converts |
| baptisms_achieved | INTEGER | DEFAULT 0 | Current baptisms |
| community_projects_achieved | INTEGER | DEFAULT 0 | Current projects |
| charity_events_achieved | INTEGER | DEFAULT 0 | Current events |
| youth_program_attendance_achieved | INTEGER | DEFAULT 0 | Current youth attendance |
| last_updated | TEXT | NOT NULL | Last update (ISO 8601) |

**Foreign Keys:**
- `kpi_id` → `kpis(id)` ON DELETE CASCADE
- `preacher_id` → `preachers(id)` ON DELETE CASCADE

**Update Trigger:**
- Progress is updated by Activity Management module (2.2.6)
- Updates `last_updated` timestamp on each change

---

### 3.4 Sample Data
The system includes 6 sample preachers for testing:
1. Ustaz Ahmad bin Ibrahim
2. Puan Siti Aisyah binti Omar
3. Dr. Muhammad Zulkifli bin Razak
4. Hajah Noraini binti Abdullah
5. Encik Khairul Anuar
6. Dr. Fatimah Az-Zahra

---

## 4. Sequence Diagrams

### 4.1 Save KPI Targets (Basic Flow)

```
MUIP Official    SenaraiPendakwahPage    ManageKPIPage    KPIController    DatabaseService    Database
     │                    │                     │                │                │              │
     │───(1) Open Page───>│                     │                │                │              │
     │                    │                     │                │                │              │
     │                    │──(2) loadPreachers()────────────────>│                │              │
     │                    │                     │                │                │              │
     │                    │                     │                │──(3) getAllPreachers()───────>│
     │                    │                     │                │                │              │
     │                    │                     │                │                │<──(4) List───│
     │                    │                     │                │                │              │
     │                    │<────(5) Display List────────────────┘                │              │
     │                    │                     │                │                │              │
     │──(6) Select Preacher>                    │                │                │              │
     │                    │                     │                │                │              │
     │                    │──(7) Navigate to ManageKPIPage──────>│                │              │
     │                    │                     │                │                │              │
     │                    │                     │<──(8) loadKPI()────────────────┤              │
     │                    │                     │                │                │              │
     │                    │                     │                │──(9) getKPIByPreacherId()───>│
     │                    │                     │                │                │              │
     │                    │                     │                │                │<──(10) null──│
     │                    │                     │                │                │  (no KPI)    │
     │                    │                     │                │                │              │
     │                    │                     │<──(11) Display Empty Form──────┘              │
     │                    │                     │                │                │              │
     │──(12) Enter Values────────────────────>│                │                │              │
     │                    │                     │                │                │              │
     │──(13) Click "Save"────────────────────>│                │                │              │
     │                    │                     │                │                │              │
     │                    │                     │──(14) Validate Form───>│       │              │
     │                    │                     │                │                │              │
     │                    │                     │                │──(15) saveKPITargets()──────>│
     │                    │                     │                │                │              │
     │                    │                     │                │                │──(16) INSERT─>│
     │                    │                     │                │                │              │
     │                    │                     │                │                │<──(17) id────│
     │                    │                     │                │                │              │
     │                    │                     │                │<────(18) success───────────────┘
     │                    │                     │                │                │              │
     │                    │                     │<────(19) Show Success Dialog───┘              │
     │                    │                     │                │                │              │
     │<──────────────(20) Navigate Back to Preacher List─────────────────────────┘              │
```

### 4.2 Edit Existing KPI (Alternative Flow [A1])

```
MUIP Official    ManageKPIPage    KPIController    DatabaseService    Database
     │                 │                │                │              │
     │──(1) Open Page──>│                │                │              │
     │                 │                │                │              │
     │                 │──(2) loadKPI()──────────────────>│              │
     │                 │                │                │              │
     │                 │                │──(3) getKPIByPreacherId()────>│
     │                 │                │                │              │
     │                 │                │                │<──(4) KPI────│
     │                 │                │                │   (found)    │
     │                 │                │                │              │
     │                 │<──(5) Pre-fill Form with Existing Values──────┘
     │                 │                │                │              │
     │──(6) Modify Value──>             │                │              │
     │                 │                │                │              │
     │──(7) Click "Update Targets"──>   │                │              │
     │                 │                │                │              │
     │                 │──(8) saveKPITargets() (edit mode)────────────>│
     │                 │                │                │              │
     │                 │                │──(9) updateKPI()─────────────>│
     │                 │                │                │              │
     │                 │                │                │──(10) UPDATE─>│
     │                 │                │                │              │
     │                 │                │                │<─(11) count──│
     │                 │                │                │              │
     │                 │                │<────(12) success──────────────┘
     │                 │                │                │              │
     │                 │<────(13) Show Success: "KPI targets updated"───┘
     │                 │                │                │              │
     │<──(14) Navigate Back──────────────────────────────┘              │
```

### 4.3 View Preacher Dashboard (Preacher Flow)

```
Preacher    MyKPIDashboardPage    KPIController    DatabaseService    Database
   │               │                    │                │              │
   │─(1) Open─────>│                    │                │              │
   │               │                    │                │              │
   │               │──(2) loadPreacherProgress()────────>│              │
   │               │                    │                │              │
   │               │                    │──(3) getAllKPIsByPreacherId()─>│
   │               │                    │                │              │
   │               │                    │                │<──(4) [KPIs]──│
   │               │                    │                │              │
   │               │                    │──(5) getProgressByKPIId()─────>│
   │               │                    │                │              │
   │               │                    │                │<─(6) Progress─│
   │               │                    │                │              │
   │               │                    │──(7) calculateOverallProgress()
   │               │                    │                │              │
   │               │<─────(8) Display Dashboard with Progress Bars──────┘
   │               │                    │                │              │
   │<──(9) View Progress (e.g., "5/10 Sessions, 63%")───────────────────┘
```

### 4.4 Exception Flow [E1]: Invalid Data

```
MUIP Official    ManageKPIPage    KPIController
     │                 │                │
     │──(1) Enter "-5" in field──>     │
     │                 │                │
     │──(2) Click Save────>            │
     │                 │                │
     │                 │──(3) Validate Form
     │                 │                │
     │                 │<──(4) Validation Error: "Must be positive"
     │                 │                │
     │<──(5) Show Error Message────────┘
     │                 │                │
     │──(6) Correct Data──>            │
     │                 │                │
     │──(7) Click Save Again───>        │
     │                 │                │
     │                 │──(8) saveKPITargets()──>
     │                 │                │
     │                 │<────(9) Success─────────┘
```

### 4.5 Exception Flow [E2]: No KPIs Set

```
Preacher    MyKPIDashboardPage    KPIController    DatabaseService    Database
   │               │                    │                │              │
   │─(1) Open─────>│                    │                │              │
   │               │                    │                │              │
   │               │──(2) loadPreacherProgress()────────>│              │
   │               │                    │                │              │
   │               │                    │──(3) getAllKPIsByPreacherId()─>│
   │               │                    │                │              │
   │               │                    │                │<──(4) []─────│
   │               │                    │                │   (empty)    │
   │               │                    │                │              │
   │               │                    │──(5) Set error message:
   │               │                    │    "Your performance targets
   │               │                    │     have not been set..."
   │               │                    │                │              │
   │               │<─────(6) Display Error Message with Icon───────────┘
   │               │     (Orange info icon + message)   │              │
   │               │     + "Go Back" button             │              │
   │               │                    │                │              │
   │<──(7) View Message────────────────────────────────────────────────┘
```

---

## 5. Data Flow Diagrams

### 5.1 Level 0 DFD (Context Diagram)

```
                    ┌─────────────────────┐
                    │   MUIP Official     │
                    └──────────┬──────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                │  1. View Preacher List      │
                │  2. Set KPI Targets         │
                │  3. Update KPI Targets      │
                │                             │
                ↓                             ↓
         ┌──────────────────────────────────────────┐
         │                                          │
         │       KPI Management System              │
         │                                          │
         └──────────────────────────────────────────┘
                ↑                             ↑
                │                             │
                │  4. View KPI Dashboard      │
                │  5. View Progress           │
                │                             │
                └──────────────┬──────────────┘
                               │
                    ┌──────────┴──────────┐
                    │      Preacher       │
                    └─────────────────────┘

         External System Interface:
         ┌─────────────────────────┐
         │ Activity Management     │
         │ (Module 2.2.6)          │
         └────────────┬────────────┘
                      │
                      │ 6. Update Progress
                      │
                      ↓
         ┌──────────────────────────────────┐
         │   KPI Management System          │
         └──────────────────────────────────┘
```

### 5.2 Level 1 DFD (Detailed Process)

```
                MUIP Official                              Preacher
                      │                                        │
                      │                                        │
         ┌────────────┴─────────────┐           ┌────────────┴────────────┐
         │                          │           │                         │
         ↓                          ↓           ↓                         ↓
   ┌─────────┐              ┌─────────────┐  ┌─────────────────┐  ┌──────────────┐
   │ Process │              │  Process    │  │    Process      │  │   Process    │
   │  1.0    │              │    2.0      │  │      3.0        │  │     4.0      │
   │ Display │              │   Manage    │  │    View         │  │   Display    │
   │Preacher │              │KPI Targets  │  │  Preacher       │  │   Progress   │
   │  List   │              │             │  │  Dashboard      │  │   Details    │
   └────┬────┘              └──────┬──────┘  └────────┬────────┘  └──────┬───────┘
        │                          │                  │                   │
        │                          │                  │                   │
        │         ┌────────────────┴──────────────────┴───────────────────┤
        │         │                                                        │
        ↓         ↓                                                        ↓
   ┌──────────────────────────────────────────────────────────────────────────┐
   │                                                                           │
   │                          Data Store D1: SQLite Database                  │
   │                                                                           │
   │  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐      │
   │  │  preachers   │    │     kpis     │    │    kpi_progress      │      │
   │  └──────────────┘    └──────────────┘    └──────────────────────┘      │
   │                                                                           │
   └────────────────────────────────────────┬─────────────────────────────────┘
                                            │
                                            ↑
                                            │
                                   ┌────────┴─────────┐
                                   │   Process 5.0    │
                                   │ Update Progress  │
                                   │  from Activity   │
                                   │   Management     │
                                   └──────────────────┘
                                            ↑
                                            │
                                ┌───────────┴───────────┐
                                │  Activity Management  │
                                │    (Module 2.2.6)     │
                                └───────────────────────┘
```

### 5.3 Process Details

**Process 1.0: Display Preacher List**
- Input: MUIP Official request, Optional search query
- Processing: Query database, Filter by search
- Output: List of preachers
- Data Store Access: Read from `preachers` table

**Process 2.0: Manage KPI Targets**
- Input: Preacher ID, Target values, Performance period
- Processing: 
  - Validate inputs (positive integers, valid dates)
  - Check if KPI exists
  - Create new or update existing
- Output: Success/Error message
- Data Store Access: 
  - Read/Write to `kpis` table
  - Write to `kpi_progress` table (initial record)

**Process 3.0: View Preacher Dashboard**
- Input: Preacher ID
- Processing: 
  - Load KPI targets
  - Load current progress
  - Calculate percentages
- Output: Dashboard with progress bars
- Data Store Access: 
  - Read from `kpis` table
  - Read from `kpi_progress` table
- Exception: Display "No KPIs set" message if empty

**Process 4.0: Display Progress Details**
- Input: KPI ID, Progress ID
- Processing: Calculate progress percentage for each metric
- Output: Individual KPI cards with status
- Calculation: `(achieved / target) × 100`

**Process 5.0: Update Progress from Activity**
- Input: Activity approval from Module 2.2.6
- Processing: 
  - Increment relevant progress counters
  - Update `last_updated` timestamp
- Output: Updated progress values
- Data Store Access: Update `kpi_progress` table
- Note: Automated, triggered by Activity Management module

---

## 6. Component Reference

### 6.1 Complete File Structure

```
lib/
├── main.dart                           # Application entry point
├── models/                             # Domain Layer
│   ├── preacher.dart                   # Preacher model
│   ├── kpi.dart                        # KPI model
│   └── kpi_progress.dart               # KPIProgress model
├── services/                           # Service Layer
│   └── database_service.dart           # DatabaseService (Singleton)
├── controllers/                        # Controller Layer (Provider)
│   ├── preacher_controller.dart        # PreacherController
│   └── kpi_controller.dart             # KPIController
└── pages/                              # Presentation Layer
    ├── senarai_pendakwah_page.dart     # Preacher list page
    ├── manage_kpi_page.dart            # Manage KPI page
    └── my_kpi_dashboard_page.dart      # Preacher dashboard
```

### 6.2 Component Names for SDD Documentation

**Use these exact names in your SDD document:**

#### Domain Models (Package: com.muip.psm.domain)
1. **Preacher** - `lib/models/preacher.dart`
2. **KPI** - `lib/models/kpi.dart`
3. **KPIProgress** - `lib/models/kpi_progress.dart`

#### Services (Package: com.muip.psm.services)
4. **DatabaseService** - `lib/services/database_service.dart`

#### Controllers (Package: com.muip.psm.controllers)
5. **PreacherController** - `lib/controllers/preacher_controller.dart`
6. **KPIController** - `lib/controllers/kpi_controller.dart`

#### Pages (Package: com.muip.psm.pages)
7. **Senarai_Pendakwah_Page.dart** - `lib/pages/senarai_pendakwah_page.dart`
8. **Edit_KPI_Page.dart** - `lib/pages/manage_kpi_page.dart`
9. **My_KPI_Dashboard_Page.dart** - `lib/pages/my_kpi_dashboard_page.dart`

#### Database Tables
10. **preachers** - Preacher information
11. **kpis** - KPI targets
12. **kpi_progress** - Progress tracking

---

### 6.3 External Dependencies

#### Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  sqflite: ^2.3.0               # SQLite database
  path_provider: ^2.1.1         # File system paths
  path: ^1.8.3                  # Path manipulation
  intl: ^0.18.1                 # Date formatting
  cupertino_icons: ^1.0.8       # iOS icons
```

---

### 6.4 Integration Points

#### 6.4.1 Activity Management Module (2.2.6)
**Interface Method**: `KPIController.updateProgressFromActivity()`

**Called When**: Activity is approved by Officer

**Parameters:**
- `preacherId: int` - ID of preacher
- `sessionsIncrement: int?` - Number of sessions to add
- `attendanceIncrement: int?` - Attendance count to add
- `convertsIncrement: int?` - New converts to add
- `baptismsIncrement: int?` - Baptisms to add
- `projectsIncrement: int?` - Community projects to add
- `eventsIncrement: int?` - Charity events to add
- `youthAttendanceIncrement: int?` - Youth attendance to add

**Example Call:**
```dart
await kpiController.updateProgressFromActivity(
  preacherId: 1,
  sessionsIncrement: 1,
  attendanceIncrement: 50,
);
```

---

## 7. Use Case Coverage

### 7.1 Basic Flow Implementation

| Step | Description | Component | Method/Function |
|------|-------------|-----------|-----------------|
| 1 | MUIP Official navigates to "Manage KPI" | main.dart → HomePage | Navigate button |
| 2 | System displays list of Preachers | Senarai_Pendakwah_Page.dart | PreacherController.loadPreachers() |
| 3 | Official selects a Preacher | Senarai_Pendakwah_Page.dart | onTap navigation |
| 4 | System shows KPI form | Edit_KPI_Page.dart | KPIController.loadKPI() |
| 5 | Official enters target values | Edit_KPI_Page.dart | TextFormField controllers |
| 6 | Official clicks "Save Targets" | Edit_KPI_Page.dart | _saveTargets() |
| 7 | System saves KPI in database | KPIController | saveKPITargets() → DatabaseService.createKPI() |
| 8 | System displays success message | Edit_KPI_Page.dart | _showSuccessDialog() |
| 9 | Use case ends for Official | - | Navigator.pop() |
| 10 | Preacher logs in and navigates to Dashboard | main.dart → HomePage | Navigate button |
| 11 | System displays progress | My_KPI_Dashboard_Page.dart | KPIController.loadPreacherProgress() |
| 12 | Use case ends for Preacher | - | - |

### 7.2 Alternative Flow [A1] Implementation

| Step | Description | Component | Method/Function |
|------|-------------|-----------|-----------------|
| A1-2 | System displays pre-filled form | Edit_KPI_Page.dart | setState() with existing KPI values |
| A1-3 | Official changes target value | Edit_KPI_Page.dart | TextEditingController |
| A1-4 | Official clicks "Update Targets" | Edit_KPI_Page.dart | _saveTargets() (edit mode) |
| A1-5 | System saves new targets | KPIController | saveKPITargets() → DatabaseService.updateKPI() |
| A1-6 | Success message displayed | Edit_KPI_Page.dart | _showSuccessDialog("updated") |

### 7.3 Exception Flow [E1] Implementation

| Step | Description | Component | Method/Function |
|------|-------------|-----------|-----------------|
| E1-2 | System validates data | Edit_KPI_Page.dart | Form.validate() + KPIController validation |
| E1-3 | System displays error | Edit_KPI_Page.dart | TextFormField validator messages |
| E1-4 | Use case continues | - | User corrects and resubmits |

### 7.4 Exception Flow [E2] Implementation

| Step | Description | Component | Method/Function |
|------|-------------|-----------|-----------------|
| E2-2 | System finds no targets | My_KPI_Dashboard_Page.dart | KPIController.loadPreacherProgress() returns empty |
| E2-3 | Display message | My_KPI_Dashboard_Page.dart | Error state with message card |
| E2-4 | Use case ends | - | "Go Back" button |

---

## 8. Design Patterns Used

### 8.1 Singleton Pattern
- **Component**: DatabaseService
- **Purpose**: Single database instance throughout app
- **Implementation**: Private constructor + factory method

### 8.2 Provider Pattern (State Management)
- **Components**: PreacherController, KPIController
- **Purpose**: Reactive UI updates
- **Implementation**: ChangeNotifier + Provider package

### 8.3 Repository Pattern
- **Component**: DatabaseService
- **Purpose**: Abstract data access
- **Implementation**: Service layer wraps SQLite operations

### 8.4 MVC Architecture
- **Model**: Domain models (Preacher, KPI, KPIProgress)
- **View**: Pages (Senarai_Pendakwah_Page, etc.)
- **Controller**: PreacherController, KPIController

---

## 9. Validation Rules

### 9.1 KPI Target Validation
1. **All target values must be positive integers**
   - Rule: `value > 0`
   - Error: "Must be positive"

2. **Required fields**
   - Rule: `value != null && value.isNotEmpty`
   - Error: "This field is required"

3. **Numeric validation**
   - Rule: `int.tryParse(value) != null`
   - Error: "Must be a number"

4. **Date validation**
   - Rule: `endDate.isAfter(startDate)`
   - Error: "End date must be after start date"

### 9.2 Role-Based Access Control
1. **MUIP Official can:**
   - View all preachers
   - Create/Update KPI targets
   - Access Senarai_Pendakwah_Page
   - Access Edit_KPI_Page

2. **Preacher can:**
   - View own KPI targets only
   - View own progress only
   - Access My_KPI_Dashboard_Page
   - **Cannot** modify targets

---

## 10. Testing Checklist

### 10.1 Unit Tests
- [ ] Preacher.toMap() / fromMap()
- [ ] KPI.toMap() / fromMap()
- [ ] KPIProgress.calculateProgress()
- [ ] DatabaseService CRUD operations
- [ ] KPIController validation logic
- [ ] PreacherController search functionality

### 10.2 Integration Tests
- [ ] Database initialization
- [ ] KPI creation with progress record
- [ ] KPI update flow
- [ ] Progress update from activity
- [ ] Search preacher by name

### 10.3 UI Tests
- [ ] Preacher list loads correctly
- [ ] Search filters work
- [ ] KPI form validation displays errors
- [ ] Success/Error dialogs appear
- [ ] Dashboard progress bars render
- [ ] No KPIs message displays correctly

---

## Appendix A: Color Scheme

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary Blue | #3B82F6 | Buttons, selected states |
| Green (Success) | #10B981 | Progress ≥75%, success messages |
| Yellow (Warning) | #F59E0B | Progress 50-74% |
| Red (Error) | #EF4444 | Progress <50%, errors |
| Teal (Accent) | #0F766E | Period selection chips |
| Background | #F5F5F5 | Page backgrounds |
| Card Background | #FFFFFF | Card containers |
| Text Dark | #000000 (#87 opacity) | Primary text |
| Text Light | #6B7280 | Secondary text |

---

## Appendix B: Icon Reference

| Icon | Material Icon Name | Usage |
|------|-------------------|-------|
| 🔍 | search | Search functionality |
| ➡️ | chevron_right | Navigate to details |
| ✓ | check_circle | Success, completed status |
| ⚠️ | warning | At-risk status |
| ❌ | error | Behind schedule |
| 📊 | bar_chart | KPI metrics |
| 📢 | campaign | Sermons metric |
| 👤+ | person_add | New members metric |
| ❤️ | volunteer_activism | Charity events |
| 👥 | groups | Youth attendance |
| 📋 | dashboard | Dashboard icon |
| 📅 | event | Activities icon |
| 📄 | description | Reports icon |
| 👤 | person | Profile icon |

---

**Document Version**: 1.0  
**Last Updated**: November 28, 2025  
**Module**: 2.2.6 - KPI Management  
**System**: MUIP Preacher Monitoring System
