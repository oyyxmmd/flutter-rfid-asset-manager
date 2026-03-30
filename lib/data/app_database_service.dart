import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_models.dart';

class AppDatabaseService {
  AppDatabaseService._();

  static final AppDatabaseService instance = AppDatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      final directory = await getApplicationSupportDirectory();
      final path = p.join(directory.path, 'rfid_asset_manager.db');
      _database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await _createSchema(db);
            await _seedInitialData(db);
          },
        ),
      );
      return _database!;
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'rfid_asset_manager.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedInitialData(db);
      },
    );
    return _database!;
  }

  Future<AppSnapshot> loadSnapshot() async {
    final db = await database;
    final assetRows = await db.rawQuery('''
      SELECT
        a.id,
        a.name,
        a.code,
        a.rfid,
        d.name AS department_name,
        c.name AS category_name,
        a.custodian,
        a.location,
        a.quantity,
        a.unit,
        a.received_date,
        a.expiry_years,
        a.used_years,
        a.note,
        a.asset_status,
        a.inventory_status,
        a.is_new
      FROM assets a
      INNER JOIN departments d ON d.id = a.department_id
      INNER JOIN categories c ON c.id = a.category_id
      ORDER BY datetime(a.updated_at) DESC, a.id DESC
    ''');
    final departmentRows = await db.rawQuery('''
      SELECT
        d.id,
        d.name,
        d.manager,
        d.parent,
        COUNT(a.id) AS asset_count
      FROM departments d
      LEFT JOIN assets a ON a.department_id = d.id
      GROUP BY d.id, d.name, d.manager, d.parent
      ORDER BY d.id DESC
    ''');
    final categoryRows = await db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.parent,
        COUNT(a.id) AS asset_count
      FROM categories c
      LEFT JOIN assets a ON a.category_id = c.id
      GROUP BY c.id, c.name, c.parent
      ORDER BY c.id DESC
    ''');
    return AppSnapshot(
      assets: assetRows.map(_assetFromRow).toList(),
      departments: departmentRows.map(_departmentFromRow).toList(),
      categories: categoryRows.map(_categoryFromRow).toList(),
    );
  }

  Future<void> upsertAsset(AssetItem asset) async {
    final db = await database;
    final departmentId = await _ensureDepartment(
      db,
      name: asset.department,
      manager: asset.custodian.isEmpty ? '待分配' : asset.custodian,
    );
    final categoryId = await _ensureCategory(
      db,
      name: asset.category,
      parent: '固定资产',
    );
    final now = DateTime.now().toIso8601String();
    await db.insert('assets', <String, Object?>{
      'id': asset.id,
      'name': asset.name,
      'code': asset.code,
      'rfid': asset.rfid,
      'department_id': departmentId,
      'category_id': categoryId,
      'custodian': asset.custodian,
      'location': asset.location,
      'quantity': asset.quantity,
      'unit': asset.unit,
      'received_date': asset.receivedDate.toIso8601String(),
      'expiry_years': asset.expiryYears,
      'used_years': asset.usedYears,
      'note': asset.note,
      'asset_status': asset.assetStatus,
      'inventory_status': asset.inventoryStatus,
      'is_new': asset.isNew ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAsset(String id) async {
    final db = await database;
    await db.delete('assets', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<void> addDepartment(DepartmentItem item) async {
    final db = await database;
    await _ensureDepartment(
      db,
      name: item.name,
      manager: item.manager,
      parent: item.parent,
    );
  }

  Future<void> addCategory(CategoryItem item) async {
    final db = await database;
    await _ensureCategory(db, name: item.name, parent: item.parent);
  }

  Future<AssetImportResult> importAssetsFromXlsx(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      return const AssetImportResult(importedCount: 0, skippedCount: 0);
    }
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return const AssetImportResult(importedCount: 0, skippedCount: 0);
    }
    final headers = rows.first
        .map((cell) => _cellToString(cell?.value))
        .toList();
    var imported = 0;
    var skipped = 0;
    for (final row in rows.skip(1)) {
      final values = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        if (i >= row.length) {
          continue;
        }
        final header = headers[i].trim();
        if (header.isEmpty) {
          continue;
        }
        values[header] = _cellToString(row[i]?.value);
      }
      final name = values['资产名称']?.trim() ?? '';
      final code = values['资产编码']?.trim() ?? '';
      if (name.isEmpty || code.isEmpty) {
        skipped += 1;
        continue;
      }
      final asset = AssetItem(
        id: (values['ID']?.trim().isNotEmpty ?? false)
            ? values['ID']!.trim()
            : code,
        name: name,
        code: code,
        rfid: values['RFID']?.trim() ?? '',
        department: _orDefault(values['所属部门'], '未分配部门'),
        category: _orDefault(values['资产类型'], '固定资产'),
        custodian: _orDefault(values['保管人'], '未指派'),
        location: _orDefault(values['存放地点'], '待补充'),
        quantity: int.tryParse(values['数量']?.trim() ?? '') ?? 1,
        unit: _orDefault(values['单位'], '台'),
        receivedDate: _parseDate(values['领用日期']) ?? DateTime.now(),
        expiryYears: int.tryParse(values['到期年限']?.trim() ?? '') ?? 3,
        usedYears: double.tryParse(values['使用年限']?.trim() ?? '') ?? 0,
        note: values['其他信息']?.trim() ?? '',
        assetStatus: _orDefault(values['资产状态'], '在库'),
        inventoryStatus: _orDefault(values['盘点状态'], '待盘点'),
        isNew: (values['是否新录入']?.trim() ?? '') == '是',
      );
      await upsertAsset(asset);
      imported += 1;
    }
    return AssetImportResult(importedCount: imported, skippedCount: skipped);
  }

  Future<List<int>> buildAssetsXlsxBytes() async {
    final snapshot = await loadSnapshot();
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet = excel[sheetName];
    sheet.appendRow(<CellValue>[
      TextCellValue('ID'),
      TextCellValue('资产名称'),
      TextCellValue('资产编码'),
      TextCellValue('RFID'),
      TextCellValue('所属部门'),
      TextCellValue('资产类型'),
      TextCellValue('保管人'),
      TextCellValue('存放地点'),
      TextCellValue('数量'),
      TextCellValue('单位'),
      TextCellValue('领用日期'),
      TextCellValue('到期年限'),
      TextCellValue('使用年限'),
      TextCellValue('其他信息'),
      TextCellValue('资产状态'),
      TextCellValue('盘点状态'),
      TextCellValue('是否新录入'),
    ]);
    for (final asset in snapshot.assets) {
      sheet.appendRow(<CellValue>[
        TextCellValue(asset.id),
        TextCellValue(asset.name),
        TextCellValue(asset.code),
        TextCellValue(asset.rfid),
        TextCellValue(asset.department),
        TextCellValue(asset.category),
        TextCellValue(asset.custodian),
        TextCellValue(asset.location),
        IntCellValue(asset.quantity),
        TextCellValue(asset.unit),
        TextCellValue(_formatDate(asset.receivedDate)),
        IntCellValue(asset.expiryYears),
        DoubleCellValue(asset.usedYears),
        TextCellValue(asset.note),
        TextCellValue(asset.assetStatus),
        TextCellValue(asset.inventoryStatus),
        TextCellValue(asset.isNew ? '是' : '否'),
      ]);
    }
    return excel.encode()!;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        manager TEXT NOT NULL,
        parent TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        parent TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE assets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        rfid TEXT NOT NULL,
        department_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        custodian TEXT NOT NULL,
        location TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        received_date TEXT NOT NULL,
        expiry_years INTEGER NOT NULL,
        used_years REAL NOT NULL,
        note TEXT NOT NULL,
        asset_status TEXT NOT NULL,
        inventory_status TEXT NOT NULL,
        is_new INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(department_id) REFERENCES departments(id),
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final departments = <DepartmentItem>[
      const DepartmentItem(name: '技术研发部', manager: '张建国', assetCount: 0),
      const DepartmentItem(name: '数字化仓储部', manager: '陈云松', assetCount: 0),
      const DepartmentItem(name: '技术运维部', manager: '李明华', assetCount: 0),
      const DepartmentItem(name: '安全监察组', manager: '王晓燕', assetCount: 0),
    ];
    final categories = <CategoryItem>[
      const CategoryItem(name: '网络设备', parent: '固定资产', assetCount: 0),
      const CategoryItem(name: '核心算力', parent: '固定资产', assetCount: 0),
      const CategoryItem(name: '测量仪表', parent: '固定资产', assetCount: 0),
      const CategoryItem(name: '存储设备', parent: '固定资产', assetCount: 0),
    ];
    for (final item in departments) {
      await _ensureDepartment(
        db,
        name: item.name,
        manager: item.manager,
        parent: item.parent,
      );
    }
    for (final item in categories) {
      await _ensureCategory(db, name: item.name, parent: item.parent);
    }
    final assets = <AssetItem>[
      AssetItem(
        id: '1',
        name: '智能工业网关控制器',
        code: 'AZ-2023-091',
        rfid: '00429X881',
        department: '技术研发部',
        category: '网络设备',
        custodian: '张建国',
        location: '科技园B座402室 - 04架C层',
        quantity: 1,
        unit: '台',
        receivedDate: DateTime(2023, 10, 12),
        expiryYears: 5,
        usedYears: 1.4,
        note: '工业网关核心控制节点。',
        assetStatus: '在库',
        inventoryStatus: '待盘点',
      ),
      AssetItem(
        id: '2',
        name: '服务器集群节点 - Node 04',
        code: 'SV-2023-442',
        rfid: '00430X992',
        department: '技术运维部',
        category: '核心算力',
        custodian: '李明华',
        location: 'DC机房 - A03机柜 - 12U',
        quantity: 1,
        unit: '套',
        receivedDate: DateTime(2023, 5, 20),
        expiryYears: 2,
        usedYears: 1.9,
        note: 'GPU 训练节点，当前维护中。',
        assetStatus: '维护中',
        inventoryStatus: '已盘点',
      ),
      AssetItem(
        id: '3',
        name: '手持式红外热成像仪',
        code: 'ME-2023-819',
        rfid: '00551Y772',
        department: '安全监察组',
        category: '测量仪表',
        custodian: '王晓燕',
        location: '上海中心仓库 - A区01排',
        quantity: 2,
        unit: '台',
        receivedDate: DateTime(2024, 2, 8),
        expiryYears: 4,
        usedYears: 0.8,
        note: '巡检专用设备。',
        assetStatus: '在库',
        inventoryStatus: '待盘点',
      ),
      AssetItem(
        id: '4',
        name: '备份存储单元 S-02',
        code: 'SH-IT-2023-11204',
        rfid: 'E28011606000020B617204C2',
        department: '数字化仓储部',
        category: '存储设备',
        custodian: '陈云松',
        location: '上海中心仓库 - B区03排',
        quantity: 1,
        unit: '台',
        receivedDate: DateTime(2024, 5, 20),
        expiryYears: 5,
        usedYears: 0.4,
        note: '新录入备份存储单元。',
        assetStatus: '新录入',
        inventoryStatus: '待盘点',
        isNew: true,
      ),
    ];
    for (final asset in assets) {
      final departmentId = await _ensureDepartment(
        db,
        name: asset.department,
        manager: asset.custodian,
      );
      final categoryId = await _ensureCategory(
        db,
        name: asset.category,
        parent: '固定资产',
      );
      final now = DateTime.now().toIso8601String();
      await db.insert('assets', <String, Object?>{
        'id': asset.id,
        'name': asset.name,
        'code': asset.code,
        'rfid': asset.rfid,
        'department_id': departmentId,
        'category_id': categoryId,
        'custodian': asset.custodian,
        'location': asset.location,
        'quantity': asset.quantity,
        'unit': asset.unit,
        'received_date': asset.receivedDate.toIso8601String(),
        'expiry_years': asset.expiryYears,
        'used_years': asset.usedYears,
        'note': asset.note,
        'asset_status': asset.assetStatus,
        'inventory_status': asset.inventoryStatus,
        'is_new': asset.isNew ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<int> _ensureDepartment(
    Database db, {
    required String name,
    required String manager,
    String parent = '总部',
  }) async {
    final existing = await db.query(
      'departments',
      columns: <String>['id'],
      where: 'name = ?',
      whereArgs: <Object?>[name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return (existing.first['id'] as num).toInt();
    }
    final now = DateTime.now().toIso8601String();
    return db.insert('departments', <String, Object?>{
      'name': name,
      'manager': manager,
      'parent': parent,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<int> _ensureCategory(
    Database db, {
    required String name,
    required String parent,
  }) async {
    final existing = await db.query(
      'categories',
      columns: <String>['id'],
      where: 'name = ?',
      whereArgs: <Object?>[name],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return (existing.first['id'] as num).toInt();
    }
    final now = DateTime.now().toIso8601String();
    return db.insert('categories', <String, Object?>{
      'name': name,
      'parent': parent,
      'created_at': now,
      'updated_at': now,
    });
  }

  AssetItem _assetFromRow(Map<String, Object?> row) {
    return AssetItem(
      id: row['id'] as String,
      name: row['name'] as String,
      code: row['code'] as String,
      rfid: row['rfid'] as String,
      department: row['department_name'] as String,
      category: row['category_name'] as String,
      custodian: row['custodian'] as String,
      location: row['location'] as String,
      quantity: (row['quantity'] as num).toInt(),
      unit: row['unit'] as String,
      receivedDate: DateTime.parse(row['received_date'] as String),
      expiryYears: (row['expiry_years'] as num).toInt(),
      usedYears: (row['used_years'] as num).toDouble(),
      note: row['note'] as String,
      assetStatus: row['asset_status'] as String,
      inventoryStatus: row['inventory_status'] as String,
      isNew: (row['is_new'] as num).toInt() == 1,
    );
  }

  DepartmentItem _departmentFromRow(Map<String, Object?> row) {
    return DepartmentItem(
      id: (row['id'] as num).toInt(),
      name: row['name'] as String,
      manager: row['manager'] as String,
      assetCount: (row['asset_count'] as num?)?.toInt() ?? 0,
      parent: row['parent'] as String? ?? '总部',
    );
  }

  CategoryItem _categoryFromRow(Map<String, Object?> row) {
    return CategoryItem(
      id: (row['id'] as num).toInt(),
      name: row['name'] as String,
      parent: row['parent'] as String,
      assetCount: (row['asset_count'] as num?)?.toInt() ?? 0,
    );
  }

  String _cellToString(CellValue? cellValue) {
    return cellValue?.toString() ?? '';
  }

  String _orDefault(String? value, String fallback) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  DateTime? _parseDate(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
