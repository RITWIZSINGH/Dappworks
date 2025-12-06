// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/blockchain_service.dart';
import 'state/app_state.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final chain = BlockchainService(
    rpcUrl: 'http://127.0.0.1:8545', // local node for dev
    contractAddressHex: '<LOCAL_DEPLOYED_ADDRESS>',
    devPrivateKey: '<LOCAL_DEV_PRIVATE_KEY>',
  );

  runApp(MyApp(chain: chain));
}

class MyApp extends StatelessWidget {
  final BlockchainService chain;
  const MyApp({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Start in local mode; change to false when ready
      create: (_) => AppState(blockchainService: chain, useLocalService: true),
      child: MaterialApp(
        title: 'Dappworks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}