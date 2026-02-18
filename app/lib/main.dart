import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'data/datasources/local/dao/s3_account_dao.dart';
import 'presentation/pages/account_list_page.dart';
import 'presentation/pages/camera_page.dart';
import 'presentation/pages/item_list_page.dart';
import 'services/auto_sync_manager.dart';
import 'services/logging_service.dart';

void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志服务
  final loggingService = LoggingService();
  await loggingService.init();

  // 获取并记录应用版本信息
  final packageInfo = await PackageInfo.fromPlatform();
  await loggingService.info('应用启动', context: {
    'appName': packageInfo.appName,
    'packageName': packageInfo.packageName,
    'version': packageInfo.version,
    'buildNumber': packageInfo.buildNumber,
    'buildSignature': packageInfo.buildSignature,
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AutoSyncManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用恢复到前台时触发同步
    if (state == AppLifecycleState.resumed) {
      _triggerSyncOnResume();
    }
  }

  /// 应用恢复时触发同步
  Future<void> _triggerSyncOnResume() async {
    try {
      // 获取激活账户
      final accountDao = S3AccountDao();
      final activeAccount = await accountDao.getActiveAccount();

      if (activeAccount != null) {
        final accountId = activeAccount['id'] as String;
        final syncManager = AutoSyncManager.instance;

        // 启动定期同步
        syncManager.startPeriodicSync(accountId);

        // 触发一次同步
        await syncManager.requestSync(accountId);
      }
    } catch (e) {
      // 忽略同步错误，不影响应用正常使用
      debugPrint('触发同步失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '记忆上传',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

/// 主页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆上传'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '云存储设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountListPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              '欢迎使用记忆上传',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '记录您的物品、照片和时间事件',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ItemListPage()),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('查看物品列表'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraPage()),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('拍照'),
      ),
    );
  }
}
