import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:ascend/core/theme/theme_provider.dart';
import 'package:ascend/feature/error_screen/global_error_screen.dart';
import 'package:ascend/core/services/app_preferences.dart';
import 'package:ascend/core/services/analytics_service.dart';
import 'package:ascend/feature/onboarding/onboarding_screen.dart';
import 'package:ascend/main_app_screen.dart';
import 'package:ascend/core/services/background_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  final bool onboardingCompleted =
      AppPreferences.getPreferenceBool(AppPreferences.keyOnboardingCompleted) ??
      false;

  await BackgroundService.initialize();

  // Analytics ping & crash reporting upload in background
  AnalyticsService.initializeAndPing();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Catch Flutter UI errors and substitute the broken widget tree with our error screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return GlobalErrorScreen(errorDetails: details);
  };

  runApp(
    Phoenix(
      child: ProviderScope(
        child: MyApp(onboardingCompleted: onboardingCompleted),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool onboardingCompleted;
  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeMode = themeState.themeMode;
    final preset = themeState.preset;
    final pureDark = themeState.pureDark;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (preset.useDynamic && lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic;
          darkScheme = darkDynamic;
        } else {
          lightScheme = ColorScheme.fromSeed(seedColor: preset.seedColor);

          darkScheme = ColorScheme.fromSeed(
            seedColor: preset.seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: buildTheme(lightScheme, Brightness.light, false),
          darkTheme: buildTheme(darkScheme, Brightness.dark, pureDark),
          themeMode: themeMode,
          home: onboardingCompleted
              ? const MainAppScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
