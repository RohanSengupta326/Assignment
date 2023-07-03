import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/employee.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, 'employees.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        jobRole TEXT,
        startDate TEXT
        exitDate TEXT
      )
    ''');
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    log('Database Employees: $maps');
    return List.generate(maps.length, (index) {
      return Employee(
        name: maps[index]['name'] as String,
        jobRole: maps[index]['jobRole'] as String,
        startDate: DateTime.parse(maps[index]['startDate']),
        exitDate: DateTime.parse(maps[index]['exitDate']),
      );
    });
  }

  Future<void> deleteEmployee(Employee employee) async {
    final db = await database;
    await db.delete(
      'employees',
      where: 'startDate = ?',
      whereArgs: [employee.startDate.toIso8601String()],
    );
  }

  Future<void> insertEmployee(Employee employee) async {
    final db = await database;
    await db.insert(
      'employees',
      {
        'name': employee.name,
        'jobRole': employee.jobRole,
        'startDate': employee.startDate.toIso8601String(),
        'exitDate': employee.exitDate.toIso8601String(),
      },
    );
  }
}
