import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import '../core/database/database_helper.dart';

class BackupService {
  static Future<File> createBackup() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    
    // Get database path
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'field_sales.db'));
    
    // Create backup directory
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    // Create backup file with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File('${backupDir.path}/backup_$timestamp.db');
    
    // Copy database
    await dbFile.copy(backupFile.path);
    
    return backupFile;
  }

  static Future<void> restoreBackup(File backupFile) async {
    final dbPath = await getDatabasesPath();
    final targetPath = join(dbPath, 'field_sales.db');
    
    // Close existing database connection
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    await db.close();
    
    // Replace database file
    await backupFile.copy(targetPath);
    
    // Reopen database
    await dbHelper.database;
  }

  static Future<List<File>> listBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    
    if (!await backupDir.exists()) {
      return [];
    }
    
    final files = await backupDir.list().toList();
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();
  }

  static Future<void> deleteBackup(File backupFile) async {
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  static Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles([XFile(backupFile.path)], text: 'Database Backup');
  }

  static Future<Map<String, dynamic>> getBackupInfo(File backupFile) async {
    final stat = await backupFile.stat();
    final filename = basename(backupFile.path);
    final timestamp = int.tryParse(
      filename.replaceAll('backup_', '').replaceAll('.db', '')
    );
    
    return {
      'path': backupFile.path,
      'size': stat.size,
      'created': timestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : stat.modified,
    };
  }
}
