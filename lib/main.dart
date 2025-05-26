import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/auth_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart'; // Novo provider
import 'package:projeto_financeiro/screens/login_screen.dart';
import 'package:projeto_financeiro/screens/register_screen.dart';
import 'package:projeto_financeiro/screens/dashboard_screen.dart';
import 'package:projeto_financeiro/screens/add_expense_screen.dart';
import 'package:projeto_financeiro/screens/add_profit_screen.dart';
import 'package:projeto_financeiro/screens/history_screen.dart';
import 'package:projeto_financeiro/screens/settings_screen.dart';
import 'package:projeto_financeiro/screens/currency_screen.dart';
import 'package:projeto_financeiro/screens/goals_screen.dart'; // Nova tela
import 'package:projeto_financeiro/screens/add_goal_screen.dart'; // Nova tela
import 'package:projeto_financeiro/screens/goal_detail_screen.dart'; // Nova tela
import 'package:projeto_financeiro/providers/theme_provider.dart'; // Novo provider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Novo provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 185, 208, 224),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 74, 133, 201),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[900],
          elevation: 0,
          centerTitle: true,
        ),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add_expense': (context) => const AddExpenseScreen(),
        '/add_profit': (context) => const AddProfitScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/currency': (context) => const CurrencyScreen(),
        '/goals': (context) => const GoalsScreen(), // Nova rota
        '/add_goal': (context) => const AddGoalScreen(), // Nova rota
        '/goal_detail': (context) {
          final goal = ModalRoute.of(context)!.settings.arguments as Goal;
          return GoalDetailScreen(goal: goal);
        },
      },
    );
  }
}
