import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/app_database_service.dart';
import 'data/app_models.dart';
import 'rfid/app_rfid_runtime.dart';
import 'rfid/rfid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RFID资产管理',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          surface: AppColors.surface,
        ),
        fontFamily: 'Inter',
      ),
      home: const LoginPage(),
    );
  }
}

class AppColors {
  static const background = Color(0xFFF7F9FC);
  static const surface = Color(0xFFF9F9FF);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF2F4F7);
  static const surfaceContainer = Color(0xFFECEEF1);
  static const surfaceHigh = Color(0xFFE6E8EB);
  static const surfaceHighest = Color(0xFFE0E3E6);
  static const surfaceDim = Color(0xFFD8DAE2);
  static const primary = Color(0xFF005DAA);
  static const primaryAlt = Color(0xFF1890FF);
  static const primaryContainer = Color(0xFF0075D5);
  static const primaryFixed = Color(0xFFD4E3FF);
  static const onPrimaryFixed = Color(0xFF0A3058);
  static const secondary = Color(0xFF40608B);
  static const tertiary = Color(0xFF934600);
  static const tertiaryFixed = Color(0xFFFFDBC7);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF404753);
  static const outline = Color(0xFF707785);
  static const outlineVariant = Color(0xFFC0C7D6);
  static const success = Color(0xFF1F8A47);
  static const successSoft = Color(0xFFDCF4E5);
}

class AppSpacing {
  static const page = EdgeInsets.symmetric(horizontal: 16);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123456');
  bool _remember = true;
  bool _obscure = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -120,
            bottom: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.precision_manufacturing_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '资产智管系统',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '智能资产管理',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLow.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '账号密码登录',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  _FieldLabel(label: '用户名 / 账号'),
                                  const SizedBox(height: 6),
                                  _LoginField(
                                    controller: _accountController,
                                    hint: '请输入您的账号或手机号',
                                    icon: Icons.account_circle_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: _FieldLabel(label: '登录密码'),
                                      ),
                                      Text(
                                        '忘记密码？',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _LoginField(
                                    controller: _passwordController,
                                    hint: '请输入登录密码',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscure,
                                    suffix: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _remember,
                                        onChanged: (value) => setState(
                                          () => _remember = value ?? false,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const Text(
                                        '在此设备上记住密码',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const SinoAssetShell(),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '立即登录',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_off_outlined,
                                        color: AppColors.onSurfaceVariant,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '离线模式',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SinoAssetShell extends StatefulWidget {
  const SinoAssetShell({super.key});

  @override
  State<SinoAssetShell> createState() => _SinoAssetShellState();
}

class _SinoAssetShellState extends State<SinoAssetShell> {
  final AppDatabaseService _database = AppDatabaseService.instance;
  int _selectedIndex = 0;
  bool _isLoading = true;

  List<AssetItem> _assets = const <AssetItem>[];
  List<DepartmentItem> _departments = const <DepartmentItem>[];
  List<CategoryItem> _categories = const <CategoryItem>[];

  @override
  void initState() {
    super.initState();
    _refreshSnapshot();
  }

  int get _pendingCount =>
      _assets.where((asset) => asset.inventoryStatus == '待盘点').length;

  int get _maintenanceCount =>
      _assets.where((asset) => asset.assetStatus == '维护中').length;

  int get _newEntryCount => _assets.where((asset) => asset.isNew).length;

  Future<void> _refreshSnapshot() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    final snapshot = await _database.loadSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _assets = snapshot.assets;
      _departments = snapshot.departments;
      _categories = snapshot.categories;
      _isLoading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAddAssetDialog() async {
    final result = await showModalBottomSheet<_AssetEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddAssetSheet(
          departments: _departments.map((item) => item.name).toList(),
          categories: _categories.map((item) => item.name).toList(),
        );
      },
    );
    if (result?.asset != null) {
      await _database.upsertAsset(result!.asset!);
      await _refreshSnapshot();
      _showMessage('资产已保存到本地数据库');
    }
  }

  Future<void> _openDuplicateAssetDialog(AssetItem asset) async {
    final result = await showModalBottomSheet<_AssetEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddAssetSheet(
          asset: asset,
          saveAsNew: true,
          departments: _departments.map((item) => item.name).toList(),
          categories: _categories.map((item) => item.name).toList(),
        );
      },
    );
    if (result?.asset != null) {
      await _database.upsertAsset(result!.asset!);
      await _refreshSnapshot();
      _showMessage('已复制资产信息并新增');
    }
  }

  Future<void> _saveAsset(AssetItem asset, {String? successMessage}) async {
    await _database.upsertAsset(asset);
    await _refreshSnapshot();
    if (successMessage != null) {
      _showMessage(successMessage);
    }
  }

  Future<void> _deleteAssets(
    Iterable<String> ids, {
    String? successMessage,
  }) async {
    for (final id in ids) {
      await _database.deleteAsset(id);
    }
    await _refreshSnapshot();
    if (successMessage != null) {
      _showMessage(successMessage);
    }
  }

  Future<void> _openAssetEdit(AssetItem asset) async {
    final result = await showModalBottomSheet<_AssetEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddAssetSheet(
          asset: asset,
          departments: _departments.map((item) => item.name).toList(),
          categories: _categories.map((item) => item.name).toList(),
        );
      },
    );
    if (result == null) return;
    if (result.deleted) {
      await _deleteAssets(<String>[asset.id], successMessage: '资产已删除');
    } else if (result.asset != null) {
      await _saveAsset(result.asset!, successMessage: '资产修改已保存');
    }
  }

  Future<void> _openRfidConfig() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RfidConfigPage(
          onOpenBluetoothDialog: () => _showBluetoothDialog(context),
          onOpenScanning: _openScanningPage,
        ),
      ),
    );
  }

  Future<void> _openScanningPage() async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => const ScanningPage()));
  }

  Future<void> _openDepartmentPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DepartmentManagementPage(
          departments: _departments,
          onAddDepartment: (department) {
            _database.addDepartment(department).then((_) => _refreshSnapshot());
          },
        ),
      ),
    );
  }

  Future<void> _openCategoryPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CategoryManagementPage(
          categories: _categories,
          onAddCategory: (category) {
            _database.addCategory(category).then((_) => _refreshSnapshot());
          },
        ),
      ),
    );
  }

  Future<void> _importAssetsFromXlsx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['xlsx'],
    );
    final filePath = result?.files.single.path;
    if (filePath == null || filePath.isEmpty) {
      return;
    }
    final importResult = await _database.importAssetsFromXlsx(filePath);
    await _refreshSnapshot();
    _showMessage(
      '导入完成：${importResult.importedCount} 条，跳过 ${importResult.skippedCount} 条',
    );
  }

  Future<void> _exportAssetsToXlsx() async {
    final bytes = await _database.buildAssetsXlsxBytes();
    final suggestedName =
        'assets_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final targetPath = await FilePicker.platform.saveFile(
      dialogTitle: '选择导出位置',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const <String>['xlsx'],
      bytes: null,
    );
    if (targetPath == null || targetPath.isEmpty) {
      _showMessage('已取消导出');
      return;
    }
    final outputFile = File(targetPath);
    await outputFile.writeAsBytes(bytes, flush: true);
    _showMessage('已导出到 ${outputFile.path}');
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          totalAssets: _assets.length,
          pendingCount: _pendingCount,
          maintenanceCount: _maintenanceCount,
          newEntryCount: _newEntryCount,
          onOpenAssets: () => setState(() => _selectedIndex = 1),
          onOpenInventory: () => setState(() => _selectedIndex = 2),
          onOpenSystem: () => setState(() => _selectedIndex = 3),
          onOpenRfidConfig: _openRfidConfig,
          recentAssets: _assets.take(3).toList(),
        );
      case 1:
        return AssetsPage(
          assets: _assets,
          onAddAsset: _openAddAssetDialog,
          onEditAsset: _openAssetEdit,
          onDuplicateAsset: _openDuplicateAssetDialog,
          onImportAssets: _importAssetsFromXlsx,
          onExportAssets: _exportAssetsToXlsx,
          onBatchUpdateAssets: (assets, message) async {
            for (final asset in assets) {
              await _database.upsertAsset(asset);
            }
            await _refreshSnapshot();
            _showMessage(message);
          },
          onDeleteAssets: (ids, message) async {
            await _deleteAssets(ids, successMessage: message);
          },
        );
      case 2:
        return InventoryPage(
          assets: _assets,
          onOpenScanning: _openScanningPage,
          onUpdateAsset: (asset, message) async {
            await _saveAsset(asset, successMessage: message);
          },
        );
      case 3:
        return SystemPage(
          totalAssets: _assets.length,
          pendingCount: _pendingCount,
          alertCount: _maintenanceCount,
          onOpenDepartmentPage: _openDepartmentPage,
          onOpenCategoryPage: _openCategoryPage,
          onOpenRfidConfig: _openRfidConfig,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: _ShellBottomNav(
        selectedIndex: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.totalAssets,
    required this.pendingCount,
    required this.maintenanceCount,
    required this.newEntryCount,
    required this.onOpenAssets,
    required this.onOpenInventory,
    required this.onOpenSystem,
    required this.onOpenRfidConfig,
    required this.recentAssets,
  });

  final int totalAssets;
  final int pendingCount;
  final int maintenanceCount;
  final int newEntryCount;
  final VoidCallback onOpenAssets;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenSystem;
  final VoidCallback onOpenRfidConfig;
  final List<AssetItem> recentAssets;

  @override
  Widget build(BuildContext context) {
    final inventoriedRate = totalAssets == 0
        ? 0.0
        : ((totalAssets - pendingCount) / totalAssets).clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PrimaryPageHeader(title: '资产管理中心'),
            const SizedBox(height: 16),
            Padding(
              padding: AppSpacing.page,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '盘点统计',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '实时更新',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 12,
                                color: AppColors.surfaceHigh,
                              ),
                              CircularProgressIndicator(
                                value: inventoriedRate,
                                strokeWidth: 12,
                                color: AppColors.primary,
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(inventoriedRate * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Text(
                                      '盘点进度',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            children: [
                              _KeyStatRow(
                                dotColor: AppColors.primaryContainer,
                                label: '总资产',
                                value: totalAssets.toString(),
                              ),
                              _KeyStatRow(
                                dotColor: AppColors.primary,
                                label: '已盘点',
                                value: (totalAssets - pendingCount).toString(),
                                valueColor: AppColors.primary,
                              ),
                              _KeyStatRow(
                                dotColor: AppColors.surfaceHigh,
                                label: '未盘点',
                                value: pendingCount.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: '快速操作'),
            const SizedBox(height: 8),
            Padding(
              padding: AppSpacing.page,
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.82,
                children: [
                  _QuickActionTile(
                    icon: Icons.sensors_rounded,
                    label: 'RFID扫描',
                    color: AppColors.primary,
                    background: AppColors.primaryFixed.withValues(alpha: 0.35),
                    onTap: onOpenRfidConfig,
                  ),
                  _QuickActionTile(
                    icon: Icons.inventory_2_rounded,
                    label: '库盘点',
                    color: AppColors.secondary,
                    background: AppColors.primaryFixed.withValues(alpha: 0.2),
                    onTap: onOpenInventory,
                  ),
                  _QuickActionTile(
                    icon: Icons.add_business_rounded,
                    label: '资产入库',
                    color: AppColors.tertiary,
                    background: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                    onTap: onOpenAssets,
                  ),
                  _QuickActionTile(
                    icon: Icons.app_registration_rounded,
                    label: '快速登记',
                    color: AppColors.onSurfaceVariant,
                    background: AppColors.surfaceHigh,
                    onTap: onOpenSystem,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: AppSpacing.page,
              child: Row(
                children: [
                  const Text(
                    '动态流',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onOpenAssets,
                    child: const Text(
                      '全部动态',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.page,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _ActivityRow(
                      title: '资产录入',
                      subtitle:
                          '${recentAssets.isNotEmpty ? recentAssets.first.name : 'ThinkPad X1 Carbon'} 已录入系统',
                      time: '刚刚',
                      color: AppColors.primary,
                    ),
                    const Divider(height: 1),
                    _ActivityRow(
                      title: '盘点提醒',
                      subtitle: '今日仍有 $pendingCount 项待盘点',
                      time: '09:42',
                      color: AppColors.tertiary,
                    ),
                    const Divider(height: 1),
                    _ActivityRow(
                      title: '系统状态',
                      subtitle: 'RFID 读写器运行中，新增 $newEntryCount 条记录',
                      time: '08:16',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetsPage extends StatefulWidget {
  const AssetsPage({
    super.key,
    required this.assets,
    required this.onAddAsset,
    required this.onEditAsset,
    required this.onDuplicateAsset,
    required this.onImportAssets,
    required this.onExportAssets,
    required this.onBatchUpdateAssets,
    required this.onDeleteAssets,
  });

  final List<AssetItem> assets;
  final VoidCallback onAddAsset;
  final ValueChanged<AssetItem> onEditAsset;
  final ValueChanged<AssetItem> onDuplicateAsset;
  final Future<void> Function() onImportAssets;
  final Future<void> Function() onExportAssets;
  final Future<void> Function(List<AssetItem> assets, String message)
  onBatchUpdateAssets;
  final Future<void> Function(List<String> ids, String message) onDeleteAssets;

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  String _selectedDepartment = '全部';
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';
  final Set<String> _selectedIds = <String>{};

  List<String> get _departmentOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.department},
  ];

  List<String> get _categoryOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.category},
  ];

  List<String> get _statusOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.assetStatus},
  ];

  List<AssetItem> get _filteredAssets => widget.assets.where((asset) {
    final matchesDepartment =
        _selectedDepartment == '全部' || asset.department == _selectedDepartment;
    final matchesCategory =
        _selectedCategory == '全部' || asset.category == _selectedCategory;
    final matchesStatus =
        _selectedStatus == '全部' || asset.assetStatus == _selectedStatus;
    return matchesDepartment && matchesCategory && matchesStatus;
  }).toList();

  bool get _isAllSelected =>
      _filteredAssets.isNotEmpty &&
      _filteredAssets.every((asset) => _selectedIds.contains(asset.id));

  Future<void> _openBatchEditSheet() async {
    final selectedAssets = widget.assets
        .where((asset) => _selectedIds.contains(asset.id))
        .toList();
    if (selectedAssets.isEmpty) {
      return;
    }
    final result = await showModalBottomSheet<_BatchEditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BatchEditAssetsSheet(
        departments:
            widget.assets.map((item) => item.department).toSet().toList()
              ..sort(),
        categories: widget.assets.map((item) => item.category).toSet().toList()
          ..sort(),
      ),
    );
    if (result == null) {
      return;
    }
    final updated = selectedAssets
        .map(
          (asset) => asset.copyWith(
            department: result.department ?? asset.department,
            category: result.category ?? asset.category,
            assetStatus: result.assetStatus ?? asset.assetStatus,
            inventoryStatus: result.inventoryStatus ?? asset.inventoryStatus,
            custodian: result.custodian ?? asset.custodian,
            location: result.location ?? asset.location,
            unit: result.unit ?? asset.unit,
            expiryYears: result.expiryYears ?? asset.expiryYears,
            note: result.note ?? asset.note,
          ),
        )
        .toList();
    await widget.onBatchUpdateAssets(updated, '已批量更新 ${updated.length} 项资产');
    if (mounted) {
      setState(() => _selectedIds.clear());
    }
  }

  Future<void> _deleteSelectedAssets() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除资产'),
        content: Text('确认删除已选中的 ${_selectedIds.length} 项资产？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await widget.onDeleteAssets(
      _selectedIds.toList(),
      '已批量删除 ${_selectedIds.length} 项资产',
    );
    if (mounted) {
      setState(() => _selectedIds.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _PrimaryPageHeader(
            title: '资产管理',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SecondaryPill(
                  label: '导入',
                  icon: Icons.upload_file_rounded,
                  onTap: () => _showAssetExcelDialog(
                    context,
                    title: '导入 xlsx',
                    description: '选择本地 xlsx 表格，将资产、部门和分类一并导入 SQLite。',
                    confirmLabel: '选择文件',
                    onConfirm: widget.onImportAssets,
                  ),
                ),
                const SizedBox(width: 8),
                _SecondaryPill(
                  label: '导出',
                  icon: Icons.download_rounded,
                  onTap: () => _showAssetExcelDialog(
                    context,
                    title: '导出 xlsx',
                    description: '导出当前本地资产数据为 xlsx 文件。',
                    confirmLabel: '开始导出',
                    onConfirm: widget.onExportAssets,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
              children: [
                const _SearchField(
                  hint: '搜索资产名称、编码或RFID',
                  icon: Icons.search_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdownChip(
                        label: '部门',
                        value: _selectedDepartment,
                        options: _departmentOptions,
                        onSelected: (value) =>
                            setState(() => _selectedDepartment = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterDropdownChip(
                        label: '分类',
                        value: _selectedCategory,
                        options: _categoryOptions,
                        onSelected: (value) =>
                            setState(() => _selectedCategory = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterDropdownChip(
                        label: '状态',
                        value: _selectedStatus,
                        options: _statusOptions,
                        onSelected: (value) =>
                            setState(() => _selectedStatus = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isAllSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedIds.addAll(
                                  _filteredAssets.map((asset) => asset.id),
                                );
                              } else {
                                _selectedIds.removeAll(
                                  _filteredAssets.map((asset) => asset.id),
                                );
                              }
                            });
                          },
                        ),
                        Text(
                          '全选 (${_selectedIds.length}/${_filteredAssets.length})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _SmallActionButton(
                      label: '批量编辑',
                      icon: Icons.edit_note_rounded,
                      background: AppColors.primaryFixed,
                      foreground: AppColors.primary,
                      onTap: _selectedIds.isEmpty ? null : _openBatchEditSheet,
                    ),
                    const SizedBox(width: 8),
                    _SmallActionButton(
                      label: '批量删除',
                      icon: Icons.delete_sweep_rounded,
                      background: AppColors.errorContainer,
                      foreground: AppColors.error,
                      onTap: _selectedIds.isEmpty
                          ? null
                          : _deleteSelectedAssets,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final asset in _filteredAssets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey('asset-${asset.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '删除',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('删除资产'),
                                content: Text('确认删除“${asset.name}”？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('删除'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (_) async {
                        await widget.onDeleteAssets(<String>[
                          asset.id,
                        ], '资产已删除');
                      },
                      child: AssetCard(
                        asset: asset,
                        selected: _selectedIds.contains(asset.id),
                        onSelectionChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedIds.add(asset.id);
                            } else {
                              _selectedIds.remove(asset.id);
                            }
                          });
                        },
                        onTap: () {
                          if (_selectedIds.isNotEmpty) {
                            setState(() {
                              if (_selectedIds.contains(asset.id)) {
                                _selectedIds.remove(asset.id);
                              } else {
                                _selectedIds.add(asset.id);
                              }
                            });
                          } else {
                            widget.onEditAsset(asset);
                          }
                        },
                        onLongPress: () => widget.onDuplicateAsset(asset),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onAddAsset,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  '新增资产',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({
    super.key,
    required this.assets,
    required this.onOpenScanning,
    required this.onUpdateAsset,
  });

  final List<AssetItem> assets;
  final VoidCallback onOpenScanning;
  final Future<void> Function(AssetItem asset, String message) onUpdateAsset;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _selectedDepartment = '全部';
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';

  Future<void> _openInventoryPreview(AssetItem asset) async {
    final updated = await showModalBottomSheet<AssetItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssetPreviewSheet(asset: asset),
    );
    if (updated == null) {
      return;
    }
    await widget.onUpdateAsset(updated, '盘点状态已更新');
  }

  List<String> get _departmentOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.department},
  ];

  List<String> get _categoryOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.category},
  ];

  List<String> get _statusOptions => [
    '全部',
    ...{for (final asset in widget.assets) asset.inventoryStatus},
  ];

  List<AssetItem> get _filteredAssets => widget.assets.where((asset) {
    final matchesDepartment =
        _selectedDepartment == '全部' || asset.department == _selectedDepartment;
    final matchesCategory =
        _selectedCategory == '全部' || asset.category == _selectedCategory;
    final matchesStatus =
        _selectedStatus == '全部' || asset.inventoryStatus == _selectedStatus;
    return matchesDepartment && matchesCategory && matchesStatus;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final pendingAssets = _filteredAssets
        .where((asset) => asset.inventoryStatus == '待盘点')
        .toList();
    final inventoriedAssets = _filteredAssets
        .where((asset) => asset.inventoryStatus == '已盘点')
        .toList();

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              const _PrimaryPageHeader(title: '资产盘点'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TopStatCard(
                            value: widget.assets.length.toString(),
                            label: '资产总数',
                            valueColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TopStatCard(
                            value: inventoriedAssets.length.toString(),
                            label: '已盘',
                            valueColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TopStatCard(
                            value: pendingAssets.length.toString(),
                            label: '待盘',
                            valueColor: AppColors.tertiary,
                            showAccent: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _SearchField(
                      hint: '输入资产名称或编号查询',
                      icon: Icons.search_rounded,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdownChip(
                            label: '部门',
                            value: _selectedDepartment,
                            options: _departmentOptions,
                            onSelected: (value) =>
                                setState(() => _selectedDepartment = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterDropdownChip(
                            label: '分类',
                            value: _selectedCategory,
                            options: _categoryOptions,
                            onSelected: (value) =>
                                setState(() => _selectedCategory = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterDropdownChip(
                            label: '状态',
                            value: _selectedStatus,
                            options: _statusOptions,
                            onSelected: (value) =>
                                setState(() => _selectedStatus = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        _AccentBar(),
                        SizedBox(width: 8),
                        Text(
                          '待盘点清单',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '共 ${pendingAssets.length} 项',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final asset in pendingAssets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InventoryCard(
                          asset: asset,
                          onTap: () => _openInventoryPreview(asset),
                        ),
                      ),
                    if (inventoriedAssets.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          _AccentBar(color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            '已盘点记录',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '共 ${inventoriedAssets.length} 项',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final asset in inventoriedAssets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InventoryCard(
                            asset: asset,
                            onTap: () => _openInventoryPreview(asset),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: widget.onOpenScanning,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.sensors_rounded),
              label: const Text(
                'RFID 盘点',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemPage extends StatelessWidget {
  const SystemPage({
    super.key,
    required this.totalAssets,
    required this.pendingCount,
    required this.alertCount,
    required this.onOpenDepartmentPage,
    required this.onOpenCategoryPage,
    required this.onOpenRfidConfig,
  });

  final int totalAssets;
  final int pendingCount;
  final int alertCount;
  final VoidCallback onOpenDepartmentPage;
  final VoidCallback onOpenCategoryPage;
  final VoidCallback onOpenRfidConfig;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const _PrimaryPageHeader(title: '个人中心'),
            Padding(
              padding: AppSpacing.page,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xFFEFF4FF),
                            child: Text(
                              '管',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '系统管理员',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(
                                  Icons.corporate_fare_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '数字化仓储部',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'ID: RFID-PRO-01',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _ProfileStat(value: '$totalAssets', label: '在库资产'),
                        _ProfileStat(
                          value: '$pendingCount',
                          label: '待检设备',
                          bordered: true,
                        ),
                        _ProfileStat(value: '$alertCount', label: '系统告警'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SettingSection(
              title: '基础数据',
              children: [
                SettingTile(
                  icon: Icons.corporate_fare_rounded,
                  label: '部门管理',
                  onTap: onOpenDepartmentPage,
                ),
                SettingTile(
                  icon: Icons.category_rounded,
                  label: '分类管理',
                  onTap: onOpenCategoryPage,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingSection(
              title: '设备配置',
              children: [
                SettingTile(
                  icon: Icons.settings_input_antenna_rounded,
                  label: 'RFID 配置',
                  subtitle: '频率、功率与读写器管理',
                  trailingText: '3 待优化',
                  trailingColor: AppColors.error,
                  trailingBackground: AppColors.errorContainer,
                  onTap: onOpenRfidConfig,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingSection(
              title: '辅助功能',
              children: const [
                SettingTile(icon: Icons.description_outlined, label: '操作日志'),
                SettingTile(
                  icon: Icons.info_outline_rounded,
                  label: '关于系统',
                  trailingPlainText: 'v2.4.0',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.errorContainer.withValues(
                    alpha: 0.2,
                  ),
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.1),
                  ),
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '退出当前账号',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RfidConfigPage extends StatefulWidget {
  const RfidConfigPage({
    super.key,
    required this.onOpenBluetoothDialog,
    required this.onOpenScanning,
  });

  final Future<void> Function() onOpenBluetoothDialog;
  final Future<void> Function() onOpenScanning;

  @override
  State<RfidConfigPage> createState() => _RfidConfigPageState();
}

class _RfidConfigPageState extends State<RfidConfigPage> {
  final AppRfidRuntime _rfidRuntime = AppRfidRuntime.instance;
  double _pendingPower = 28;

  @override
  void initState() {
    super.initState();
    _pendingPower = _rfidRuntime.latestPower.value.toDouble();
    _rfidRuntime.latestPower.addListener(_syncPower);
    _rfidRuntime.ensureReady();
  }

  @override
  void dispose() {
    _rfidRuntime.latestPower.removeListener(_syncPower);
    super.dispose();
  }

  void _syncPower() {
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingPower = _rfidRuntime.latestPower.value.toDouble();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleDirectConnection(RfidStatus status) async {
    try {
      if (status.connected) {
        await _rfidRuntime.disconnect();
        _showMessage('优博讯直连已断开');
      } else {
        await _rfidRuntime.connectDirect();
        await _rfidRuntime.refreshReaderFirmware();
        await _rfidRuntime.queryPower();
        _showMessage('优博讯直连已连接');
      }
    } catch (error) {
      _showMessage('连接失败: $error');
    }
  }

  Future<void> _queryParameters() async {
    try {
      await _rfidRuntime.queryPower();
      await _rfidRuntime.refreshReaderFirmware();
      _showMessage('已刷新设备参数');
    } catch (error) {
      _showMessage('查询失败: $error');
    }
  }

  Future<void> _savePower() async {
    try {
      await _rfidRuntime.savePower(_pendingPower.round());
      _showMessage('功率已下发到设备');
    } catch (error) {
      _showMessage('保存失败: $error');
    }
  }

  Future<void> _singleRead() async {
    try {
      if (!_rfidRuntime.status.value.connected) {
        await _rfidRuntime.connectDirect();
      }
      await _rfidRuntime.startInventory();
      _showMessage('开始单次读取');
      Future<void>.delayed(const Duration(milliseconds: 900), () async {
        if (_rfidRuntime.isScanning.value) {
          await _rfidRuntime.stopInventory();
        }
      });
    } catch (error) {
      _showMessage('单次读取失败: $error');
    }
  }

  Future<void> _openScanning() async {
    try {
      if (!_rfidRuntime.status.value.connected) {
        await _rfidRuntime.connectDirect();
      }
      await widget.onOpenScanning();
    } catch (error) {
      _showMessage('进入扫描页失败: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RfidStatus>(
      valueListenable: _rfidRuntime.status,
      builder: (context, status, _) {
        return ValueListenableBuilder<List<ScannedTagView>>(
          valueListenable: _rfidRuntime.scannedTags,
          builder: (context, tags, child) {
            final commandText = _rfidRuntime.lastCommandText.value;
            final previewTags = tags.take(4).toList();
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    _SimpleTopBar(
                      title: 'RFID 配置',
                      leadingIcon: Icons.arrow_back_rounded,
                      onLeadingTap: () => Navigator.of(context).pop(),
                      trailingIcon: Icons.more_vert_rounded,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              const _SectionMicroTitle(title: '连接设置'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: status.connected
                                      ? AppColors.primaryFixed
                                      : AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '当前状态: ${status.connected
                                      ? '已连接'
                                      : status.initialized
                                      ? '待连接'
                                      : '初始化中'}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: status.connected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _ConnectionCard(
                                  title: '直连模式',
                                  status: status.connected ? '已连接' : '未连接',
                                  icon: Icons.usb_rounded,
                                  accent: status.connected
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                  buttonLabel: status.connected
                                      ? '断开连接'
                                      : '连接设备',
                                  buttonFilled: !status.connected,
                                  onTap: () => _toggleDirectConnection(status),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ConnectionCard(
                                  title: '蓝牙模式',
                                  status: '未连接',
                                  icon: Icons.bluetooth_rounded,
                                  accent: AppColors.outlineVariant,
                                  buttonLabel: '开始搜索',
                                  buttonFilled: true,
                                  onTap: widget.onOpenBluetoothDialog,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLowest,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionMicroTitle(
                                  title: '功率配置 (RF Power)',
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        '发射功率',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _pendingPower.round().toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'dBm',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10,
                                    ),
                                    trackHeight: 6,
                                  ),
                                  child: Slider(
                                    value: _pendingPower
                                        .clamp(0, 33)
                                        .toDouble(),
                                    min: 0,
                                    max: 33,
                                    divisions: 33,
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.surfaceContainer,
                                    onChanged: (value) {
                                      setState(() {
                                        _pendingPower = value;
                                      });
                                    },
                                  ),
                                ),
                                if (status.readerFirmware != null ||
                                    commandText != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '固件: ${status.readerFirmware ?? '--'}    ${commandText ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _queryParameters,
                                        icon: const Icon(
                                          Icons.sync_alt_rounded,
                                        ),
                                        label: const Text('查询参数'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppColors.onSurfaceVariant,
                                          backgroundColor: AppColors.surfaceLow,
                                          side: BorderSide(
                                            color: AppColors.outlineVariant
                                                .withValues(alpha: 0.3),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: _savePower,
                                        icon: const Icon(Icons.save_outlined),
                                        label: const Text('保存设置'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _SectionMicroTitle(title: '读写操作区'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _singleRead,
                                  icon: const Icon(Icons.sensors_off_rounded),
                                  label: const Text('单次读取'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.primaryFixed,
                                    foregroundColor: AppColors.onPrimaryFixed,
                                    side: BorderSide.none,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _openScanning,
                                  icon: const Icon(Icons.radar_rounded),
                                  label: const Text('批量读取'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighest.withValues(
                                      alpha: 0.55,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 8,
                                        child: Text(
                                          'EPC 编码 (16进制)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '强度',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '计数',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                for (final item in previewTags)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLowest,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors.surfaceContainer
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.epc,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Reader ${item.readerId}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.rssi,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: item.rssi == '-72'
                                                  ? AppColors.tertiary
                                                  : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.count.toString(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (previewTags.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: Text(
                                      '还没有读取到标签，连接后可在这里查看最近标签预览。',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '累计标签: ',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        tags.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '扫描速率: ${_rfidRuntime.inventoryRate.value} 标签/秒',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DepartmentManagementPage extends StatelessWidget {
  const DepartmentManagementPage({
    super.key,
    required this.departments,
    required this.onAddDepartment,
  });

  final List<DepartmentItem> departments;
  final ValueChanged<DepartmentItem> onAddDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SimpleTopBar(
              title: '部门管理',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).pop(),
              trailingIcon: Icons.add_rounded,
              onTrailingTap: () async {
                final item = await showModalBottomSheet<DepartmentItem>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddDepartmentSheet(),
                );
                if (item != null) {
                  onAddDepartment(item);
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  for (final item in departments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ManagementCard(
                        title: item.name,
                        subtitle: '负责人 ${item.manager}',
                        detail: '${item.assetCount} 项资产',
                        icon: Icons.corporate_fare_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({
    super.key,
    required this.categories,
    required this.onAddCategory,
  });

  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem> onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SimpleTopBar(
              title: '分类管理',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).pop(),
              trailingIcon: Icons.add_rounded,
              onTrailingTap: () async {
                final item = await showModalBottomSheet<CategoryItem>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddCategorySheet(
                    existingParents: categories
                        .map((item) => item.parent)
                        .toSet()
                        .toList(),
                  ),
                );
                if (item != null) {
                  onAddCategory(item);
                }
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  for (final item in categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ManagementCard(
                        title: item.name,
                        subtitle: '上级分类 ${item.parent}',
                        detail: '${item.assetCount} 项资产',
                        icon: Icons.category_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetEditPage extends StatefulWidget {
  const AssetEditPage({
    super.key,
    required this.asset,
    required this.departments,
    required this.categories,
  });

  final AssetItem asset;
  final List<String> departments;
  final List<String> categories;

  @override
  State<AssetEditPage> createState() => _AssetEditPageState();
}

class _AssetEditPageState extends State<AssetEditPage> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _rfid;
  late final TextEditingController _custodian;
  late final TextEditingController _location;
  late final TextEditingController _unit;
  late final TextEditingController _quantity;
  late final TextEditingController _expiryYears;
  late final TextEditingController _note;
  late String _department;
  late String _category;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.asset.name);
    _code = TextEditingController(text: widget.asset.code);
    _rfid = TextEditingController(text: widget.asset.rfid);
    _custodian = TextEditingController(text: widget.asset.custodian);
    _location = TextEditingController(text: widget.asset.location);
    _unit = TextEditingController(text: widget.asset.unit);
    _quantity = TextEditingController(text: widget.asset.quantity.toString());
    _expiryYears = TextEditingController(
      text: widget.asset.expiryYears.toString(),
    );
    _note = TextEditingController(text: widget.asset.note);
    _department = widget.asset.department;
    _category = widget.asset.category;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _rfid.dispose();
    _custodian.dispose();
    _location.dispose();
    _unit.dispose();
    _quantity.dispose();
    _expiryYears.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.onSurfaceVariant,
                ),
                const Expanded(
                  child: Text(
                    '编辑资产',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryAlt,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(const _AssetEditResult(deleted: true));
                  },
                  icon: const Icon(Icons.delete_rounded),
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _FormSection(
              title: '资产照片',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.dns_rounded,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('添加图片'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _FormSection(
              title: 'RFID 状态',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _PillButton(label: '感应', icon: Icons.sensors_rounded),
                  SizedBox(width: 8),
                  _PillButton(label: '扫码', icon: Icons.qr_code_scanner_rounded),
                ],
              ),
              child: Column(
                children: [
                  _FormInput(label: '资产名称', controller: _name),
                  const SizedBox(height: 14),
                  _AdaptiveFormRow(
                    children: [
                      _FormInput(label: '编码', controller: _code),
                      _FormInput(
                        label: 'RFID 标签 ID',
                        controller: _rfid,
                        suffixIcon: Icons.copy_all_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _AdaptiveFormRow(
                    children: [
                      _FormDropdown<String>(
                        label: '部门',
                        value: _department,
                        items: widget.departments,
                        onChanged: (value) =>
                            setState(() => _department = value ?? _department),
                      ),
                      _FormDropdown<String>(
                        label: '类型',
                        value: _category,
                        items: widget.categories,
                        onChanged: (value) =>
                            setState(() => _category = value ?? _category),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _AdaptiveFormRow(
                    children: [
                      _FormInput(
                        label: '保管人',
                        controller: _custodian,
                        suffixIcon: Icons.person_search_rounded,
                      ),
                      _FormInput(label: '存放地点', controller: _location),
                    ],
                  ),
                ],
              ),
            ),
            _FormSection(
              title: '生命周期',
              accent: AppColors.tertiary,
              child: Column(
                children: [
                  _AdaptiveFormRow(
                    children: [
                      _FormInput(
                        label: '领用日期',
                        controller: TextEditingController(
                          text: _formatDate(widget.asset.receivedDate),
                        ),
                      ),
                      _FormInput(label: '到期年限 (年)', controller: _expiryYears),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '已使用年限',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.asset.usedYears} 年',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Expanded(
                                    child: Text(
                                      '健康度',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '85%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: 0.85,
                                  color: AppColors.tertiary,
                                  backgroundColor: AppColors.surfaceContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _FormSection(
              title: '其他信息',
              child: Column(
                children: [
                  _AdaptiveFormRow(
                    children: [
                      _FormInput(label: '单位', controller: _unit),
                      _FormInput(label: '数量', controller: _quantity),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormInput(label: '其他信息', controller: _note, maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final updated = widget.asset.copyWith(
                      name: _name.text,
                      code: _code.text,
                      rfid: _rfid.text,
                      department: _department,
                      category: _category,
                      custodian: _custodian.text,
                      location: _location.text,
                      unit: _unit.text,
                      quantity:
                          int.tryParse(_quantity.text) ?? widget.asset.quantity,
                      expiryYears:
                          int.tryParse(_expiryYears.text) ??
                          widget.asset.expiryYears,
                      note: _note.text,
                    );
                    Navigator.of(context).pop(_AssetEditResult(asset: updated));
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    '保存修改',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(const _AssetEditResult(deleted: true));
                  },
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text(
                    '删除资产',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.18),
                    ),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanningPage extends StatefulWidget {
  const ScanningPage({super.key});

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  final AppRfidRuntime _rfidRuntime = AppRfidRuntime.instance;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startScanning() async {
    try {
      await _rfidRuntime.ensureReady();
      if (!_rfidRuntime.status.value.connected) {
        await _rfidRuntime.connectDirect();
      }
      await _rfidRuntime.startInventory();
    } catch (error) {
      _showMessage('启动扫描失败: $error');
    }
  }

  Future<void> _stopAndClose() async {
    try {
      if (_rfidRuntime.isScanning.value) {
        await _rfidRuntime.stopInventory();
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ScannedTagView>>(
      valueListenable: _rfidRuntime.scannedTags,
      builder: (context, tags, _) {
        final totalReads = tags.fold<int>(0, (sum, item) => sum + item.count);
        final topSignal = tags.isEmpty ? '--' : tags.first.rssi;
        final anomalyCount = tags.where((item) {
          final value = int.tryParse(item.rssi) ?? 0;
          return value <= -70;
        }).length;
        final activeBars = tags.isEmpty
            ? 0
            : ((tags.length / 18) * 18).clamp(1, 18).round();
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF05294D),
                      Color(0xFF0A4F88),
                      Color(0xFFF7F9FC),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _stopAndClose,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: Colors.white,
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _rfidRuntime.isScanning,
                            builder: (context, isScanning, child) {
                              return Expanded(
                                child: Text(
                                  isScanning ? 'RFID 扫描中' : 'RFID 扫描已停止',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: _startScanning,
                            icon: const Icon(Icons.refresh_rounded),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '已识别标签',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tags.length.toString(),
                            style: const TextStyle(
                              fontSize: 62,
                              height: 0.95,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(
                              18,
                              (index) => Expanded(
                                child: Container(
                                  height: 10,
                                  margin: EdgeInsets.only(
                                    right: index == 17 ? 0 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index < activeBars
                                        ? AppColors.primary
                                        : AppColors.primaryFixed,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _GlassStat(
                                  label: '速率',
                                  value:
                                      '${_rfidRuntime.inventoryRate.value}/s',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _GlassStat(
                                  label: '信号',
                                  value: '$topSignal dBm',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _GlassStat(
                                  label: '异常',
                                  value: anomalyCount.toString(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tags.isEmpty
                                      ? '等待标签进入扫描范围'
                                      : '最近标签 ${tags.first.epc}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              const _StatusDot(color: AppColors.success),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '累计读数 $totalReads 次',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _stopAndClose,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text(
                              '结束扫描',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({
    super.key,
    this.asset,
    this.saveAsNew = false,
    required this.departments,
    required this.categories,
  });

  final AssetItem? asset;
  final bool saveAsNew;
  final List<String> departments;
  final List<String> categories;

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _rfid;
  late final TextEditingController _years;
  late final TextEditingController _expiryYears;
  late final TextEditingController _unit;
  late final TextEditingController _quantity;
  late final TextEditingController _custodian;
  late final TextEditingController _location;
  late final TextEditingController _note;
  late final DateTime _receivedDate;
  String _department = '技术研发部';
  String _category = '固定资产';
  late final String _initialName;
  late final String _initialCode;
  late final String _initialRfid;
  late final String _initialYears;
  late final String _initialExpiryYears;
  late final String _initialUnit;
  late final String _initialQuantity;
  late final String _initialCustodian;
  late final String _initialLocation;
  late final String _initialNote;
  late final String _initialDepartment;
  late final String _initialCategory;
  bool _allowClose = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.asset;
    _name = TextEditingController(text: asset?.name ?? '');
    _code = TextEditingController(text: asset?.code ?? 'AUTOGEN-2024');
    _rfid = TextEditingController(
      text: asset?.rfid ?? 'E280 1160 2000 71E4 513A',
    );
    _years = TextEditingController(
      text: asset == null ? '' : asset.usedYears.toString(),
    );
    _expiryYears = TextEditingController(
      text: asset?.expiryYears.toString() ?? '',
    );
    _unit = TextEditingController(text: asset?.unit ?? '台');
    _quantity = TextEditingController(text: asset?.quantity.toString() ?? '1');
    _custodian = TextEditingController(text: asset?.custodian ?? '');
    _location = TextEditingController(text: asset?.location ?? '');
    _note = TextEditingController(text: asset?.note ?? '');
    _receivedDate = asset?.receivedDate ?? DateTime.now();
    if (widget.departments.isNotEmpty) {
      _department = _resolveDropdownValue(
        items: widget.departments,
        candidate: asset?.department,
        aliases: const {'研发中心': '技术研发部'},
      );
    }
    if (widget.categories.isNotEmpty) {
      _category = _resolveDropdownValue(
        items: widget.categories,
        candidate: asset?.category,
      );
    }
    _initialName = _name.text;
    _initialCode = _code.text;
    _initialRfid = _rfid.text;
    _initialYears = _years.text;
    _initialExpiryYears = _expiryYears.text;
    _initialUnit = _unit.text;
    _initialQuantity = _quantity.text;
    _initialCustodian = _custodian.text;
    _initialLocation = _location.text;
    _initialNote = _note.text;
    _initialDepartment = _department;
    _initialCategory = _category;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _rfid.dispose();
    _years.dispose();
    _expiryYears.dispose();
    _unit.dispose();
    _quantity.dispose();
    _custodian.dispose();
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _name.text != _initialName ||
      _code.text != _initialCode ||
      _rfid.text != _initialRfid ||
      _years.text != _initialYears ||
      _expiryYears.text != _initialExpiryYears ||
      _unit.text != _initialUnit ||
      _quantity.text != _initialQuantity ||
      _custodian.text != _initialCustodian ||
      _location.text != _initialLocation ||
      _note.text != _initialNote ||
      _department != _initialDepartment ||
      _category != _initialCategory;

  AssetItem _buildResultAsset() {
    if (widget.asset != null && !widget.saveAsNew) {
      return widget.asset!.copyWith(
        name: _name.text.isEmpty ? '未命名资产' : _name.text,
        code: _code.text,
        rfid: _rfid.text,
        department: _department,
        category: _category,
        custodian: _custodian.text.isEmpty ? '未指派' : _custodian.text,
        location: _location.text.isEmpty ? '待补充' : _location.text,
        quantity: int.tryParse(_quantity.text) ?? 1,
        unit: _unit.text.isEmpty ? '台' : _unit.text,
        receivedDate: _receivedDate,
        expiryYears: int.tryParse(_expiryYears.text) ?? 3,
        usedYears: double.tryParse(_years.text) ?? 0,
        note: _note.text,
      );
    }
    return AssetItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.isEmpty ? '新资产' : _name.text,
      code: _code.text,
      rfid: _rfid.text,
      department: _department,
      category: _category,
      custodian: _custodian.text.isEmpty ? '未指派' : _custodian.text,
      location: _location.text.isEmpty ? '待补充' : _location.text,
      quantity: int.tryParse(_quantity.text) ?? 1,
      unit: _unit.text.isEmpty ? '台' : _unit.text,
      receivedDate: _receivedDate,
      expiryYears: int.tryParse(_expiryYears.text) ?? 3,
      usedYears: double.tryParse(_years.text) ?? 0,
      note: _note.text,
      assetStatus: '新录入',
      inventoryStatus: '待盘点',
      isNew: true,
    );
  }

  Future<void> _saveAndClose() async {
    _allowClose = true;
    Navigator.of(context).pop(_AssetEditResult(asset: _buildResultAsset()));
  }

  Future<void> _requestClose() async {
    if (!_hasChanges) {
      _allowClose = true;
      Navigator.of(context).pop();
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('信息尚未保存'),
        content: const Text('当前信息已修改。请选择继续编辑、不保存关闭，或先保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('继续编辑'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('discard'),
            child: const Text('不保存'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (action == 'discard') {
      _allowClose = true;
      Navigator.of(context).pop();
    } else if (action == 'save') {
      await _saveAndClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.asset != null && !widget.saveAsNew;

    return PopScope(
      canPop: _allowClose || !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _requestClose();
      },
      child: _BottomSheetScaffold(
        title: isEditing ? '编辑资产' : (widget.saveAsNew ? '复制新增资产' : '新增资产'),
        onCloseRequested: _requestClose,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.onSurfaceVariant,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '照片上传',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _FormInput(
                        label: '资产名称',
                        controller: _name,
                        hint: '输入资产名称',
                      ),
                      const SizedBox(height: 12),
                      _FormInput(label: '资产编码', controller: _code),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sensors_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'RFID 标签',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _TinyAction(
                        label: '感应',
                        icon: Icons.wifi_tethering_rounded,
                      ),
                      const SizedBox(width: 8),
                      _TinyAction(
                        label: '扫码',
                        icon: Icons.qr_code_scanner_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _rfid,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FormDropdown<String>(
                    label: '所属部门',
                    value: _department,
                    items: widget.departments,
                    onChanged: (value) =>
                        setState(() => _department = value ?? _department),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormDropdown<String>(
                    label: '资产类型',
                    value: _category,
                    items: widget.categories,
                    onChanged: (value) =>
                        setState(() => _category = value ?? _category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormInput(
              label: '领用日期',
              controller: TextEditingController(
                text: _formatDate(_receivedDate),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FormInput(
                    label: '使用年限 (年)',
                    controller: _years,
                    hint: '0',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormInput(
                    label: '到期年限 (年)',
                    controller: _expiryYears,
                    hint: '0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FormInput(
                    label: '单位',
                    controller: _unit,
                    hint: '台/个',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormInput(label: '数量', controller: _quantity),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FormInput(
                    label: '保管人',
                    controller: _custodian,
                    hint: '姓名/工号',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormInput(
                    label: '存放地点',
                    controller: _location,
                    hint: '输入具体地点',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormInput(
              label: '其他信息',
              controller: _note,
              hint: '备注信息...',
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveAndClose,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditing ? '保存修改' : (widget.saveAsNew ? '复制并新增' : '确定录入'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _allowClose = true;
                    Navigator.of(
                      context,
                    ).pop(const _AssetEditResult(deleted: true));
                  },
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text(
                    '删除资产',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.18),
                    ),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              isEditing
                  ? '修改后将同步更新当前资产信息'
                  : (widget.saveAsNew
                        ? '将当前资产信息复制为一条新的本地资产记录'
                        : '完成录入后将自动同步至 RFID 管理系统'),
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDepartmentSheet extends StatefulWidget {
  const AddDepartmentSheet({super.key});

  @override
  State<AddDepartmentSheet> createState() => _AddDepartmentSheetState();
}

class _AddDepartmentSheetState extends State<AddDepartmentSheet> {
  final _name = TextEditingController();
  final _manager = TextEditingController();
  String _parent = '总部';

  @override
  void dispose() {
    _name.dispose();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '新增部门',
      child: Column(
        children: [
          _FormInput(label: '部门名称', controller: _name, hint: '输入部门名称'),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '上级部门',
            value: _parent,
            items: const ['总部', '运营中心', '技术中心'],
            onChanged: (value) => setState(() => _parent = value ?? _parent),
          ),
          const SizedBox(height: 14),
          _FormInput(label: '负责人', controller: _manager, hint: '输入负责人姓名'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  DepartmentItem(
                    name: _name.text.isEmpty ? '新部门' : _name.text,
                    manager: _manager.text.isEmpty ? '待分配' : _manager.text,
                    assetCount: 0,
                    parent: _parent,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                '确定新增',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key, required this.existingParents});

  final List<String> existingParents;

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _name = TextEditingController();
  String _parent = '固定资产';

  @override
  void initState() {
    super.initState();
    if (widget.existingParents.isNotEmpty) {
      _parent = widget.existingParents.first;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '新增分类',
      child: Column(
        children: [
          _FormInput(label: '分类名称', controller: _name, hint: '输入分类名称'),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '上级分类',
            value: _parent,
            items: widget.existingParents.isEmpty
                ? const ['固定资产']
                : widget.existingParents,
            onChanged: (value) => setState(() => _parent = value ?? _parent),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  CategoryItem(
                    name: _name.text.isEmpty ? '新分类' : _name.text,
                    parent: _parent,
                    assetCount: 0,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                '确定新增',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showBluetoothDialog(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _BottomSheetScaffold(
        title: '蓝牙连接',
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.bluetooth_searching_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '正在搜索附近 RFID 读写器...',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _BluetoothDeviceTile(
              name: 'Reader R2000',
              mac: 'A4:C1:38:20:0B:21',
              signal: '-54 dBm',
              connected: false,
            ),
            const SizedBox(height: 10),
            const _BluetoothDeviceTile(
              name: 'Warehouse Gun V3',
              mac: 'B2:99:11:AC:09:13',
              signal: '-61 dBm',
              connected: true,
            ),
            const SizedBox(height: 10),
            const _BluetoothDeviceTile(
              name: 'PDA Handheld',
              mac: 'C3:08:71:EE:33:72',
              signal: '-73 dBm',
              connected: false,
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showAssetExcelDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String confirmLabel,
  required Future<void> Function() onConfirm,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _BottomSheetScaffold(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.table_chart_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await onConfirm();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.task_alt_rounded),
                label: Text(
                  confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BottomSheetScaffold extends StatelessWidget {
  const _BottomSheetScaffold({
    required this.title,
    required this.child,
    this.onCloseRequested,
  });

  final String title;
  final Widget child;
  final VoidCallback? onCloseRequested;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.65,
        maxChildSize: 0.97,
        builder: (context, controller) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            onCloseRequested ??
                            () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: controller,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, safeBottom + 24),
                    children: [child],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssetEditResult {
  const _AssetEditResult({this.asset, this.deleted = false});

  final AssetItem? asset;
  final bool deleted;
}

class _BatchEditResult {
  const _BatchEditResult({
    this.department,
    this.category,
    this.assetStatus,
    this.inventoryStatus,
    this.custodian,
    this.location,
    this.unit,
    this.expiryYears,
    this.note,
  });

  final String? department;
  final String? category;
  final String? assetStatus;
  final String? inventoryStatus;
  final String? custodian;
  final String? location;
  final String? unit;
  final int? expiryYears;
  final String? note;
}

class BatchEditAssetsSheet extends StatefulWidget {
  const BatchEditAssetsSheet({
    super.key,
    required this.departments,
    required this.categories,
  });

  final List<String> departments;
  final List<String> categories;

  @override
  State<BatchEditAssetsSheet> createState() => _BatchEditAssetsSheetState();
}

class _BatchEditAssetsSheetState extends State<BatchEditAssetsSheet> {
  static const String _keepValue = '__KEEP__';

  String _department = _keepValue;
  String _category = _keepValue;
  String _assetStatus = _keepValue;
  String _inventoryStatus = _keepValue;
  late final TextEditingController _custodian;
  late final TextEditingController _location;
  late final TextEditingController _unit;
  late final TextEditingController _expiryYears;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _custodian = TextEditingController();
    _location = TextEditingController();
    _unit = TextEditingController();
    _expiryYears = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _custodian.dispose();
    _location.dispose();
    _unit.dispose();
    _expiryYears.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetScaffold(
      title: '批量编辑资产',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '未选择的字段将保持原值不变。',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '所属部门',
            value: _department,
            items: <String>[_keepValue, ...widget.departments],
            onChanged: (value) =>
                setState(() => _department = value ?? _keepValue),
            itemLabelBuilder: (value) => value == _keepValue ? '保持不变' : value,
          ),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '资产类型',
            value: _category,
            items: <String>[_keepValue, ...widget.categories],
            onChanged: (value) =>
                setState(() => _category = value ?? _keepValue),
            itemLabelBuilder: (value) => value == _keepValue ? '保持不变' : value,
          ),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '资产状态',
            value: _assetStatus,
            items: const <String>[_keepValue, '在库', '新录入', '维修中', '已停用'],
            onChanged: (value) =>
                setState(() => _assetStatus = value ?? _keepValue),
            itemLabelBuilder: (value) => value == _keepValue ? '保持不变' : value,
          ),
          const SizedBox(height: 14),
          _FormDropdown<String>(
            label: '盘点状态',
            value: _inventoryStatus,
            items: const <String>[_keepValue, '待盘点', '已盘点'],
            onChanged: (value) =>
                setState(() => _inventoryStatus = value ?? _keepValue),
            itemLabelBuilder: (value) => value == _keepValue ? '保持不变' : value,
          ),
          const SizedBox(height: 14),
          _FormInput(label: '保管人', controller: _custodian, hint: '留空表示保持不变'),
          const SizedBox(height: 14),
          _FormInput(label: '存放地点', controller: _location, hint: '留空表示保持不变'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FormInput(
                  label: '单位',
                  controller: _unit,
                  hint: '留空表示保持不变',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormInput(
                  label: '到期年限',
                  controller: _expiryYears,
                  hint: '留空表示保持不变',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FormInput(
            label: '备注',
            controller: _note,
            hint: '留空表示保持不变',
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _BatchEditResult(
                    department: _department == _keepValue ? null : _department,
                    category: _category == _keepValue ? null : _category,
                    assetStatus: _assetStatus == _keepValue
                        ? null
                        : _assetStatus,
                    inventoryStatus: _inventoryStatus == _keepValue
                        ? null
                        : _inventoryStatus,
                    custodian: _custodian.text.trim().isEmpty
                        ? null
                        : _custodian.text.trim(),
                    location: _location.text.trim().isEmpty
                        ? null
                        : _location.text.trim(),
                    unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
                    expiryYears: _expiryYears.text.trim().isEmpty
                        ? null
                        : int.tryParse(_expiryYears.text.trim()),
                    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '应用批量修改',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetPreviewSheet extends StatelessWidget {
  const AssetPreviewSheet({super.key, required this.asset});

  final AssetItem asset;

  @override
  Widget build(BuildContext context) {
    final pending = asset.inventoryStatus == '待盘点';

    return _BottomSheetScaffold(
      title: '资产预览',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        asset.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    _StatusChip(
                      label: asset.inventoryStatus,
                      color: pending ? AppColors.tertiary : AppColors.success,
                      background: _softBackground(
                        pending ? AppColors.tertiary : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _TinyInfoTag(label: 'RFID: ${asset.rfid}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SecondaryPill(label: '编码: ${asset.code}'),
                    _SecondaryPill(label: '部门: ${asset.department}'),
                    _SecondaryPill(label: '分类: ${asset.category}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PreviewInfoCard(
                  label: '保管人',
                  value: asset.custodian,
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PreviewInfoCard(
                  label: '数量 / 单位',
                  value: '${asset.quantity} ${asset.unit}',
                  icon: Icons.layers_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewInfoCard(
            label: '存放地点',
            value: asset.location,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PreviewInfoCard(
                  label: '领用日期',
                  value: _formatDate(asset.receivedDate),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PreviewInfoCard(
                  label: '使用 / 到期年限',
                  value: '${asset.usedYears} / ${asset.expiryYears} 年',
                  icon: Icons.av_timer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewInfoCard(
            label: '其他信息',
            value: asset.note.isEmpty ? '暂无备注' : asset.note,
            icon: Icons.notes_rounded,
            multiLine: true,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: pending
                  ? () {
                      Navigator.of(context).pop(
                        asset.copyWith(
                          inventoryStatus: '已盘点',
                          assetStatus: asset.assetStatus == '新录入'
                              ? '在库'
                              : asset.assetStatus,
                          isNew: false,
                        ),
                      );
                    }
                  : null,
              icon: Icon(
                pending ? Icons.fact_check_rounded : Icons.check_circle_rounded,
              ),
              label: Text(
                pending ? '标记为已盘点' : '该资产已完成盘点',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: pending
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewInfoCard extends StatelessWidget {
  const _PreviewInfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.multiLine = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: multiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.page,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SectionMicroTitle extends StatelessWidget {
  const _SectionMicroTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyStatRow extends StatelessWidget {
  const _KeyStatRow({
    required this.dotColor,
    required this.label,
    required this.value,
    this.valueColor = AppColors.onSurface,
  });

  final Color dotColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class AssetCard extends StatelessWidget {
  const AssetCard({
    super.key,
    required this.asset,
    required this.selected,
    required this.onSelectionChanged,
    required this.onTap,
    this.onLongPress,
  });

  final AssetItem asset;
  final bool selected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final accent = _assetAccent(asset.assetStatus);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.28)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 102,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (asset.assetStatus != '在库')
                        _StatusChip(
                          label: asset.assetStatus,
                          color: accent,
                          background: _softBackground(accent),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _TinyInfoTag(label: 'RFID: ${asset.rfid}'),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _TinyBadge(label: '编码: ${asset.code}'),
                      _TinyBadge(label: '数量: ${asset.quantity} ${asset.unit}'),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaBlock(
                          label: '部门 / 保管人',
                          value: '${asset.department} / ${asset.custodian}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetaBlock(label: '类型', value: asset.category),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _SecondaryPill(
                        label: '领用: ${_formatDate(asset.receivedDate)}',
                      ),
                      _SecondaryPill(
                        label: '到期: ${asset.expiryYears} 年',
                        danger: asset.expiryYears <= 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          asset.category == '核心算力'
                              ? Icons.dns_rounded
                              : Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            asset.location,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Checkbox(
                value: selected,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => onSelectionChanged(value ?? false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryCard extends StatelessWidget {
  const InventoryCard({super.key, required this.asset, this.onTap});

  final AssetItem asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pending = asset.inventoryStatus == '待盘点';
    final accent = pending ? AppColors.tertiary : AppColors.success;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                _StatusChip(
                  label: asset.inventoryStatus,
                  color: accent,
                  background: _softBackground(accent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '资产编码',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              asset.code,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'RFID 标签',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              asset.rfid,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    asset.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  pending
                      ? Icons.check_circle_outline_rounded
                      : Icons.check_circle_rounded,
                  color: accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementCard extends StatelessWidget {
  const ManagementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingText,
    this.trailingPlainText,
    this.trailingColor,
    this.trailingBackground,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingText;
  final String? trailingPlainText;
  final Color? trailingColor;
  final Color? trailingBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: subtitle == null
                    ? AppColors.primaryFixed
                    : AppColors.tertiaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: subtitle == null
                    ? AppColors.primary
                    : AppColors.tertiary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trailingBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailingText!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: trailingColor,
                  ),
                ),
              ),
            if (trailingPlainText != null)
              Text(
                trailingPlainText!,
                style: const TextStyle(fontSize: 10, color: AppColors.outline),
              ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        color: AppColors.surfaceContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceLow,
        prefixIcon: Icon(
          icon,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.icon});

  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceLowest,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdownChip extends StatelessWidget {
  const _FilterDropdownChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onSelected,
      color: AppColors.surfaceLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => options
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: item == value ? FontWeight.w800 : FontWeight.w600,
                  color: item == value
                      ? AppColors.primary
                      : AppColors.onSurface,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: $value',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: value == '全部' ? FontWeight.w700 : FontWeight.w800,
                  color: value == '全部'
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? background : background.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: enabled ? foreground : foreground.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: enabled
                    ? foreground
                    : foreground.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  const _TopStatCard({
    required this.value,
    required this.label,
    required this.valueColor,
    this.showAccent = false,
  });

  final String value;
  final String label;
  final Color valueColor;
  final bool showAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(14),
        border: showAccent
            ? const Border(
                left: BorderSide(color: AppColors.tertiary, width: 4),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  const _ShellBottomNav({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, '首页'),
      (Icons.inventory_2_rounded, '资产'),
      (Icons.qr_code_scanner_rounded, '盘点'),
      (Icons.settings_rounded, '系统'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? AppColors.primaryFixed
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        color: selectedIndex == i
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selectedIndex == i
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: selectedIndex == i
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryPageHeader extends StatelessWidget {
  const _PrimaryPageHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.14),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          ...?trailing == null ? null : <Widget>[trailing!],
        ],
      ),
    );
  }
}

class _SimpleTopBar extends StatelessWidget {
  const _SimpleTopBar({
    required this.title,
    required this.leadingIcon,
    required this.onLeadingTap,
    required this.trailingIcon,
    this.onTrailingTap,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeadingTap;
  final IconData trailingIcon;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeadingTap,
            icon: Icon(leadingIcon),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onTrailingTap ?? () {},
            icon: Icon(trailingIcon),
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.title,
    required this.status,
    required this.icon,
    required this.accent,
    required this.buttonLabel,
    required this.buttonFilled,
    required this.onTap,
  });

  final String title;
  final String status;
  final IconData icon;
  final Color accent;
  final String buttonLabel;
  final bool buttonFilled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: buttonFilled
                      ? AppColors.surfaceLow
                      : AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: buttonFilled ? AppColors.outline : AppColors.primary,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: buttonFilled
                          ? AppColors.outline
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: buttonFilled
                ? FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      backgroundColor: AppColors.surfaceLow,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.child,
    this.trailing,
    this.accent = AppColors.primary,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              ...?(trailing != null ? <Widget>[trailing!] : null),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.label,
    required this.controller,
    this.hint,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormDropdown<T> extends StatelessWidget {
  const _FormDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabelBuilder?.call(item) ?? item.toString()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AdaptiveFormRow extends StatelessWidget {
  const _AdaptiveFormRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const breakpoint = 390.0;
        const spacing = 12.0;
        final stacked = constraints.maxWidth < breakpoint;
        if (stacked) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}

String _resolveDropdownValue({
  required List<String> items,
  required String? candidate,
  Map<String, String> aliases = const {},
}) {
  if (items.isEmpty) return candidate ?? '';
  if (candidate == null || candidate.isEmpty) return items.first;
  final normalized = aliases[candidate] ?? candidate;
  if (items.contains(normalized)) return normalized;
  return items.first;
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyAction extends StatelessWidget {
  const _TinyAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BluetoothDeviceTile extends StatelessWidget {
  const _BluetoothDeviceTile({
    required this.name,
    required this.mac,
    required this.signal,
    required this.connected,
  });

  final String name;
  final String mac;
  final String signal;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: connected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: connected ? AppColors.primaryFixed : AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.bluetooth_rounded,
              color: connected ? AppColors.primary : AppColors.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mac,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  signal,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          connected
              ? FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '已连接',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )
              : OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '连接',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
        ],
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    this.bordered = false,
  });

  final String value;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: bordered
              ? Border.symmetric(
                  vertical: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AccentBar extends StatelessWidget {
  const _AccentBar({this.color = AppColors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _TinyInfoTag extends StatelessWidget {
  const _TinyInfoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.onPrimaryFixed,
        ),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SecondaryPill extends StatelessWidget {
  const _SecondaryPill({
    required this.label,
    this.icon,
    this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: danger
              ? AppColors.errorContainer.withValues(alpha: 0.2)
              : AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12,
                color: danger ? AppColors.error : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: danger ? AppColors.error : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _assetAccent(String status) {
  switch (status) {
    case '维护中':
      return AppColors.tertiary;
    case '新录入':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

Color _softBackground(Color color) => color.withValues(alpha: 0.12);

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
