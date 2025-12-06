import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'router.dart';
import 'ui/screens/auth/role_select_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // We are using ONLY local service for this demo
  final appState = AppState(
    blockchainService: null,
    useLocalService: true,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, app, __) {
        return MaterialApp(
          title: 'FreelanceForge',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
          ),
          onGenerateRoute: onGenerateRoute,
          // AppState handles boot; once ready we start at RoleSelectScreen.
          home: app.isLoading
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : const RoleSelectScreen(),
        );
      },
    );
  }
}
