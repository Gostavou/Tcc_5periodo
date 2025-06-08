import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:projeto_financeiro/providers/auth_provider.dart';
import 'package:projeto_financeiro/providers/user_provider.dart';
import 'package:projeto_financeiro/providers/expense_provider.dart';
import 'package:projeto_financeiro/providers/currency_provider.dart';
import 'package:projeto_financeiro/providers/goal_provider.dart';
import 'package:projeto_financeiro/providers/theme_provider.dart';
import 'package:projeto_financeiro/screens/login_screen.dart';
import 'package:projeto_financeiro/screens/register_screen.dart';
import 'package:projeto_financeiro/screens/dashboard_screen.dart';
import 'package:projeto_financeiro/screens/add_expense_screen.dart';
import 'package:projeto_financeiro/screens/add_profit_screen.dart';
import 'package:projeto_financeiro/screens/history_screen.dart';
import 'package:projeto_financeiro/screens/settings_screen.dart';
import 'package:projeto_financeiro/screens/currency_screen.dart';
import 'package:projeto_financeiro/screens/goals_screen.dart';
import 'package:projeto_financeiro/screens/add_goal_screen.dart';
import 'package:projeto_financeiro/screens/goal_detail_screen.dart';
import 'package:projeto_financeiro/screens/complete_profile_screen.dart';
import 'package:projeto_financeiro/services/database_service.dart';
import 'package:projeto_financeiro/models/goal_model.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa os dados de localização para datas
    await initializeDateFormatting('pt_BR', null);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          Provider(create: (_) => DatabaseService()),
          ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
            create: (context) => UserProvider(
              databaseService:
                  Provider.of<DatabaseService>(context, listen: false),
            ),
            update: (context, databaseService, userProvider) {
              userProvider?.updateDatabaseService(databaseService);
              return userProvider ??
                  UserProvider(databaseService: databaseService);
            },
          ),
          ChangeNotifierProxyProvider<DatabaseService, ExpenseProvider>(
            create: (context) => ExpenseProvider(
              databaseService:
                  Provider.of<DatabaseService>(context, listen: false),
            ),
            update: (context, databaseService, expenseProvider) {
              expenseProvider?.updateDatabaseService(databaseService);
              return expenseProvider ??
                  ExpenseProvider(databaseService: databaseService);
            },
          ),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Erro ao inicializar o Firebase: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Controle Financeiro',
          theme: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 76, 155, 245),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: const Color.fromARGB(255, 185, 208, 224),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 76, 155, 245),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue[800],
            colorScheme: ColorScheme.fromSwatch(
              brightness: Brightness.dark,
            ).copyWith(
              secondary: Colors.blue[700],
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue[900],
              elevation: 0,
              centerTitle: true,
            ),
          ),
          themeMode: themeProvider.themeMode,
          // Verifica se usuário está logado para definir home
          home: authProvider.currentUser == null
              ? const LoginScreen()
              : const DashboardScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/complete_profile': (context) => const CompleteProfileScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/add_expense': (context) => const AddExpenseScreen(),
            '/add_profit': (context) => const AddProfitScreen(),
            '/history': (context) => const HistoryScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/currency': (context) => const CurrencyScreen(),
            '/goals': (context) => const GoalsScreen(),
            '/add_goal': (context) => const AddGoalScreen(),
            '/goal_detail': (context) {
              final goal = ModalRoute.of(context)!.settings.arguments as Goal;
              return GoalDetailScreen(goal: goal);
            },
          },
        );
      },
    );
  }
}
