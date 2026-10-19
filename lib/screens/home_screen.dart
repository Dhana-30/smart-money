import 'package:flutter/material.dart';
import '../providers/finance_provider.dart';
import '../services/alarm_service.dart';
import '../services/sms_listener_service.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/payment_detection_dialog.dart';
import 'dashboard_tab.dart';
import 'daily_tab.dart';
import 'monthly_tab.dart';
import 'analytics_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  final FinanceProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _navHistory = [0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSmsListener();
    });
  }

  void _initSmsListener() {
    SmsListenerService().startListening(
      onTransactionDetected: (parsed) {
        if (widget.provider.isSmsDetectionEnabled && mounted) {
          PaymentDetectionDialog.show(context, widget.provider, parsed);
        }
      },
    );
  }

  void _navigateToTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _navHistory.add(index);
      _currentIndex = index;
    });
  }

  void _handleBack() {
    if (_navHistory.length > 1) {
      setState(() {
        _navHistory.removeLast();
        _currentIndex = _navHistory.last;
      });
    } else if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _navHistory.clear();
        _navHistory.add(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    final tabs = [
      DashboardTab(
        provider: provider,
        onNavigateToDaily: () => _navigateToTab(1),
      ),
      DailyTab(provider: provider),
      MonthlyTab(
        provider: provider,
        onSelectDay: () => _navigateToTab(1),
      ),
      AnalyticsTab(provider: provider),
      SettingsTab(provider: provider),
    ];

    final titles = [
      'SmartMoney',
      'Daily Log',
      'Monthly Calendar',
      'Analytics',
      'Settings & Habits',
    ];

    final bool isNotOnHome = _currentIndex != 0 || _navHistory.length > 1;

    return PopScope(
      canPop: !isNotOnHome,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isNotOnHome
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: _handleBack,
                )
              : null,
          title: Row(
            children: [
              if (!isNotOnHome)
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '₹',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              Text(
                titles[_currentIndex],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            if (isNotOnHome)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _navHistory.clear();
                    _navHistory.add(0);
                  });
                },
                icon: const Icon(Icons.home, size: 16),
                label: const Text('Home', style: TextStyle(fontSize: 12)),
              ),
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined),
              tooltip: 'Test Alarm',
              onPressed: () {
                AlarmService().playChimeSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Alarm chime ringing!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => provider.toggleDarkMode(),
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tabs[_currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () => AddTransactionModal.show(context, provider),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add, size: 28),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Daily',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Monthly',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Charts',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
