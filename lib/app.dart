import 'package:material_ui/material_ui.dart';

import 'core/navigation/main_navigator.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'LSP Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (BuildContext context, Widget? child) {
        // ignore: deprecated_member_use
        return MaterialUiCompatibilityBridge(child: child!);
      },
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      home: const SplashScreen(),
    );
  }
}
