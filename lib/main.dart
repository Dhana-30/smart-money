import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for mobile portrait experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SmartMoneyApp());
}

class SmartMoneyApp extends StatefulWidget {
  const SmartMoneyApp({super.key});

  @override
  State<SmartMoneyApp> createState() => _SmartMoneyAppState();
}

class _SmartMoneyAppState extends State<SmartMoneyApp> {
  final FinanceProvider _financeProvider = FinanceProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _financeProvider,
      builder: (context, _) {
        final isDark = _financeProvider.isDarkMode;

        return MaterialApp(
          title: 'SmartMoney',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF10B981),
              brightness: Brightness.light,
              primary: const Color(0xFF10B981),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF10B981),
              brightness: Brightness.dark,
              primary: const Color(0xFF10B981),
              surface: const Color(0xFF131B2E),
              background: const Color(0xFF090D16),
            ),
            scaffoldBackgroundColor: const Color(0xFF090D16),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: Color(0xFF131B2E),
            ),
            cardTheme: CardTheme(
              elevation: 0,
              color: const Color(0xFF131B2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: HomeScreen(provider: _financeProvider),
        );
      },
    );
  }
}
