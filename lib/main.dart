import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/blockchain_service.dart';
import 'router.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: supply your RPC + WS + contract address
  final chain = BlockchainService(
    rpcUrl: 'https://sepolia.infura.io/v3/7aac6a3490e545e7851d4250e0dee01b',
    // wsUrl: 'wss://mainnet.infura.io/ws/v3/YOUR_KEY',
    contractAddressHex: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
    devPrivateKey: '7aac6a3490e545e7851d4250e0dee01b',
  );

  runApp(MyApp(chain: chain));
}

class MyApp extends StatelessWidget {
  final BlockchainService chain;
  const MyApp({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(chain)..boot(),
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
