// Service Layer: DatabaseService
// Component Name for SDD: DatabaseService
// Package: com.muip.psm.services

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/User.dart';
import '../models/KPITarget.dart';
import '../models/KPIProgress.dart';

/// Singleton Database Service for managing SQLite operations
/// Handles all CRUD operations for KPI Management module
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  // Get database instance (Singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database and create tables
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'muip_psm.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Table: preachers
    await db.execute('''
      CREATE TABLE preachers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        avatar_url TEXT,
        status TEXT DEFAULT 'active'
      )
    ''');
    
    // Table: kpis
    await db.execute('''
      CREATE TABLE kpis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preacher_id INTEGER NOT NULL,
        monthly_session_target INTEGER NOT NULL,
        total_attendance_target INTEGER NOT NULL,
        new_converts_target INTEGER NOT NULL,
        baptisms_target INTEGER NOT NULL,
        community_projects_target INTEGER NOT NULL,
        charity_events_target INTEGER NOT NULL,
        youth_program_attendance_target INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (preacher_id) REFERENCES preachers (id) ON DELETE CASCADE
      )
    ''');
    
    // Table: kpi_progress
    await db.execute('''
      CREATE TABLE kpi_progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kpi_id INTEGER NOT NULL,
        preacher_id INTEGER NOT NULL,
        sessions_completed INTEGER DEFAULT 0,
        total_attendance_achieved INTEGER DEFAULT 0,
        new_converts_achieved INTEGER DEFAULT 0,
        baptisms_achieved INTEGER DEFAULT 0,
        community_projects_achieved INTEGER DEFAULT 0,
        charity_events_achieved INTEGER DEFAULT 0,
        youth_program_attendance_achieved INTEGER DEFAULT 0,
        last_updated TEXT NOT NULL,
        FOREIGN KEY (kpi_id) REFERENCES kpis (id) ON DELETE CASCADE,
        FOREIGN KEY (preacher_id) REFERENCES preachers (id) ON DELETE CASCADE
      )
    ''');
    
    // Insert sample data for testing
    await _insertSampleData(db);
  }
  
  // Insert sample preachers for testing
  Future<void> _insertSampleData(Database db) async {
    final samplePreachers = [
      {'name': 'Ustaz Ahmad bin Ibrahim', 'email': 'ahmad@muip.gov.my', 'phone': '013-2345678', 'status': 'active'},
      {'name': 'Puan Siti Aisyah binti Omar', 'email': 'siti@muip.gov.my', 'phone': '012-3456789', 'status': 'active'},
      {'name': 'Dr. Muhammad Zulkifli bin Razak', 'email': 'zulkifli@muip.gov.my', 'phone': '019-4567890', 'status': 'active'},
      {'name': 'Hajah Noraini binti Abdullah', 'email': 'noraini@muip.gov.my', 'phone': '017-5678901', 'status': 'active'},
      {'name': 'Encik Khairul Anuar', 'email': 'khairul@muip.gov.my', 'phone': '016-6789012', 'status': 'active'},
      {'name': 'Dr. Fatimah Az-Zahra', 'email': 'fatimah@muip.gov.my', 'phone': '011-7890123', 'status': 'active'},
    ];
    
    for (var preacher in samplePreachers) {
      await db.insert('preachers', preacher);
    }
  }
  
  // ==================== PREACHER CRUD OPERATIONS ====================
  
  // Get all preachers
  Future<List<Preacher>> getAllPreachers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('preachers');
    return List.generate(maps.length, (i) => Preacher.fromMap(maps[i]));
  }
  
  // Get preacher by ID
  Future<Preacher?> getPreacherById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'preachers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Preacher.fromMap(maps.first);
    }
    return null;
  }
  
  // Search preachers by name
  Future<List<Preacher>> searchPreachers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'preachers',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) => Preacher.fromMap(maps[i]));
  }
  
  // ==================== KPI CRUD OPERATIONS ====================
  
  // Create new KPI targets
  Future<int> createKPI(KPI kpi) async {
    final db = await database;
    return await db.insert('kpis', kpi.toMap());
  }
  
  // Update existing KPI targets
  Future<int> updateKPI(KPI kpi) async {
    final db = await database;
    return await db.update(
      'kpis',
      kpi.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [kpi.id],
    );
  }
  
  // Get KPI by preacher ID and period
  Future<KPI?> getKPIByPreacherId(int preacherId, DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kpis',
      where: 'preacher_id = ? AND start_date = ? AND end_date = ?',
      whereArgs: [preacherId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    if (maps.isNotEmpty) {
      return KPI.fromMap(maps.first);
    }
    return null;
  }
  
  // Get all KPIs for a preacher
  Future<List<KPI>> getAllKPIsByPreacherId(int preacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kpis',
      where: 'preacher_id = ?',
      whereArgs: [preacherId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => KPI.fromMap(maps[i]));
  }
  
  // ==================== KPI PROGRESS CRUD OPERATIONS ====================
  
  // Create initial progress record
  Future<int> createKPIProgress(KPIProgress progress) async {
    final db = await database;
    return await db.insert('kpi_progress', progress.toMap());
  }
  
  // Update progress (called from Activity Management module)
  Future<int> updateKPIProgress(KPIProgress progress) async {
    final db = await database;
    return await db.update(
      'kpi_progress',
      progress.copyWith(lastUpdated: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }
  
  // Get progress by KPI ID
  Future<KPIProgress?> getProgressByKPIId(int kpiId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kpi_progress',
      where: 'kpi_id = ?',
      whereArgs: [kpiId],
    );
    if (maps.isNotEmpty) {
      return KPIProgress.fromMap(maps.first);
    }
    return null;
  }
  
  // Get progress by preacher ID
  Future<KPIProgress?> getProgressByPreacherId(int preacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kpi_progress',
      where: 'preacher_id = ?',
      whereArgs: [preacherId],
      orderBy: 'last_updated DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return KPIProgress.fromMap(maps.first);
    }
    return null;
  }
  
  // Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
