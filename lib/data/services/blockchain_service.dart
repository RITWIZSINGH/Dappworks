import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;

// keep if you use your helpers
import '../models/job.dart';
import '../models/bidder.dart';

class BlockchainService {
  final String rpcUrl;
  // final String wsUrl;
  final String contractAddressHex; // 0x...
  final Client httpClient;
  late final web3.Web3Client _client;
  web3.DeployedContract? _contract;

  /// (Optional) Dev-only signer. DO NOT ship real keys in production.
  final String? devPrivateKey;

  BlockchainService({
    required this.rpcUrl,
    // required this.wsUrl,
    required this.contractAddressHex,
    this.devPrivateKey,
    Client? httpClient,
  }) : httpClient = httpClient ?? Client() {
    _client = web3.Web3Client(rpcUrl, this.httpClient);
  }

  // Replace with WalletConnect or other credential provider
  Future<web3.Credentials> _credentials() async {
    if (devPrivateKey != null && devPrivateKey!.trim().isNotEmpty) {
      return web3.EthPrivateKey.fromHex(devPrivateKey!.trim());
    }
    // TODO: supply credentials via WalletConnect / secure signer
    throw UnimplementedError('Provide credentials via WalletConnect');
  }

  Future<web3.EthereumAddress> _ownAddress() async {
    final creds = await _credentials();
    return creds.address;
  }

  Future<void> _ensureContractLoaded() async {
    if (_contract != null) return;
    final abiStr = await rootBundle.loadString('assets/abi/DappWorks.json');
    final abiJson = json.decode(abiStr) as Map<String, dynamic>;
    final abi = web3.ContractAbi.fromJson(json.encode(abiJson['abi']), 'DappWorks');
    final address = web3.EthereumAddress.fromHex(contractAddressHex);
    _contract = web3.DeployedContract(abi, address);
  }

  // ------------- helpers to call contract -------------
  Future<List<dynamic>> _read(String fn, [List<dynamic> args = const []]) async {
    await _ensureContractLoaded();
    final f = _contract!.function(fn);
    return _client.call(contract: _contract!, function: f, params: args);
  }

  Future<String> _write(
    String fn, {
    List<dynamic> args = const [],
    web3.EtherAmount? value,
  }) async {
    await _ensureContractLoaded();
    final f = _contract!.function(fn);
    final txHash = await _client.sendTransaction(
      await _credentials(),
      web3.Transaction.callContract(
        contract: _contract!,
        function: f,
        parameters: args,
        value: value,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return txHash;
  }

  // ------------- DappWorks methods -------------

  Future<String?> getConnectedAccountOrNull() async {
    try {
      final addr = await _ownAddress();
      return addr.hex;
    } catch (_) {
      return null;
    }
  }

  Future<String?> connectWallet() async {
    // TODO: implement WalletConnect (return address.hex)
    throw UnimplementedError('Implement connectWallet with WalletConnect');
  }

  Future<void> addJobListing({
    required String title,
    required String description,
    required String tags,
    required String prizeEth,
  }) async {
    final wei = _ethToWei(prizeEth);
    final value = web3.EtherAmount.inWei(wei);
    await _write('addJobListing', args: [title, description, tags], value: value);
  }

  Future<void> updateJob({
    required int id,
    required String title,
    required String description,
    required String tags,
  }) async {
    await _write('updateJob', args: [BigInt.from(id), title, description, tags]);
  }

  Future<void> deleteJob(int id) async {
    await _write('deleteJob', args: [BigInt.from(id)]);
  }

  Future<void> bidForJob(int id) async {
    await _write('bidForJob', args: [BigInt.from(id)]);
  }

  Future<void> acceptBid({
    required int id,
    required int jId,
    required String bidder,
  }) async {
    await _write('acceptBid', args: [
      BigInt.from(id),
      BigInt.from(jId),
      web3.EthereumAddress.fromHex(bidder),
    ]);
  }

  Future<void> payout(int id) async {
    await _write('payout', args: [BigInt.from(id)]);
  }

  Future<List<Job>> getJobs() async {
    final res = await _read('getJobs');
    return _jobsFromResponse(res.first as List);
  }

  Future<List<Job>> getMyJobs() async {
    final res = await _read('getMyJobs');
    return _jobsFromResponse(res.first as List);
  }

  Future<List<Job>> getAssignedJobs() async {
    final res = await _read('getAssignedJobs');
    return _jobsFromResponse(res.first as List);
  }

  Future<List<Job>> getJobsForBidder() async {
    final res = await _read('getJobsForBidder');
    return _jobsFromResponse(res.first as List);
  }

  Future<Job?> getJob(int id) async {
    final res = await _read('getJob', [BigInt.from(id)]);
    final list = _jobsFromResponse([res.first]);
    return list.isEmpty ? null : list.first;
  }

  Future<List<Bidder>> getBidders(int id) async {
    final res = await _read('getBidders', [BigInt.from(id)]);
    final list = (res.first as List)
        .map((e) => Bidder(
              id: (e[0] as BigInt).toInt(),
              jId: (e[1] as BigInt).toInt(),
              account: (e[2] as web3.EthereumAddress).hex.toLowerCase(),
            ))
        .toList();
    return list;
  }

  // ---------- mapping helpers ----------

  List<Job> _jobsFromResponse(List<dynamic> raw) {
    return raw.map((e) {
      final id          = (e[0] as BigInt).toInt();
      final owner       = (e[1] as web3.EthereumAddress).hex.toLowerCase();
      final freelancer  = (e[2] as web3.EthereumAddress).hex.toLowerCase();
      final jobTitle    = e[3] as String;
      final description = e[4] as String;
      final tags        = (e[5] as String).split(',').where((t) => t.trim().isNotEmpty).toList();
      final prizeWei    = (e[6] as BigInt);
      final paidOut     = e[7] as bool;
      final ts          = e[8] as BigInt;
      final listed      = e[9] as bool;
      final disputed    = e[10] as bool;
      final bidders     = (e[11] as List)
          .map((a) => (a as web3.EthereumAddress).hex.toLowerCase())
          .toList();

      final prizeEthStr = web3.EtherAmount.inWei(prizeWei)
          .getValueInUnit(web3.EtherUnit.ether)
          .toString();

      return Job(
        id: id,
        owner: owner,
        freelancer: freelancer,
        jobTitle: jobTitle,
        description: description,
        tags: tags,
        prizeEth: prizeEthStr,
        paidOut: paidOut,
        timestamp: ts,
        listed: listed,
        disputed: disputed,
        bidders: bidders,
      );
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Safe string ETH -> WEI (avoids floating-point errors)
  BigInt _pow10(int n) => BigInt.from(10).pow(n);
  BigInt _ethToWei(String eth) {
    final s = eth.trim();
    if (s.isEmpty) return BigInt.zero;
    final parts = s.split('.');
    final whole = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
    final frac  = parts.length > 1 ? parts[1] : '0';
    final fracPadded = (frac + '0' * 18).substring(0, 18);
    return whole * _pow10(18) + BigInt.parse(fracPadded);
  }
}
