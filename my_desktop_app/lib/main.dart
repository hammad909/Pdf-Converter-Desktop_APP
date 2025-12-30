import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/core/theme/app_colors.dart';
import 'package:window_manager/window_manager.dart';

import 'package:my_desktop_app/core/theme/app_theme.dart';
import 'package:my_desktop_app/core/theme/theme_mode_provider.dart';
import 'package:my_desktop_app/features/view/home/home_page.dart';
import 'package:my_desktop_app/server/server_manager.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const initialSize = Size(1200, 700);
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    minimumSize: initialSize,
    center: true,
    title: 'PDF Converter',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runZonedGuarded(() {
    runApp(
      ProviderScope(
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) async {

    await ServerManager.stopServer();
  });
}


final serverUriProvider = Provider<Uri>((ref) {
  throw UnimplementedError();
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
  Uri? serverUri;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServer();

    windowManager.addListener(this); 
  }

  @override
  void onWindowClose() async {
    await ServerManager.stopServer(); 
    await windowManager.destroy();   
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
  Future<void> _initializeServer() async {
    setState(() {
      isLoading = true;
    });

    try {
      final uri = await ServerManager.startAndGetServerUri();

      while (!(await _pingServer(uri))) {
        await Future.delayed(const Duration(seconds: 1));
      }

      setState(() {
        serverUri = uri;
        isLoading = false;
      });
    } catch (_) {

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _initializeServer();
    }
  }

  Future<bool> _pingServer(Uri uri) async {
    try {
      final response = await HttpClient().getUrl(uri).then((req) => req.close());
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
Widget build(BuildContext context) {
  final themeMode = ref.watch(themeModeProvider);


  final isDark = themeMode == ThemeMode.dark;


  final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  final primaryColor = AppColors.primary;
  final textColor = isDark ? AppColors.textDark : AppColors.textLight;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'PDF Converter',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: serverUri != null
            ? ProviderScope(
                overrides: [
                  serverUriProvider.overrideWithValue(serverUri!),
                ],
                child: const HomePage(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: primaryColor, size: 120),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Starting app...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

}
