import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../models/job.dart';
import '../models/bidder.dart';

class BlockchainService {
  final String rpcUrl;
  final String contractAddressHex;
  final Client httpClient;
  late final web3.Web3Client _client;
  web3.DeployedContract? _contract;
  final String? devPrivateKey;

  BlockchainService({
    required this.rpcUrl,
    required this.contractAddressHex,
    this.devPrivateKey,
    Client? httpClient,
  }) : httpClient = httpClient ?? Client() {
    _client = web3.Web3Client(rpcUrl, this.httpClient);
  }

  Future<web3.Credentials> _credentials() async {
    if (devPrivateKey != null && devPrivateKey!.trim().isNotEmpty) {
      return web3.EthPrivateKey.fromHex(devPrivateKey!.trim());
    }
    throw UnimplementedError('Provide credentials via WalletConnect');
  }

  Future<web3.EthereumAddress> _ownAddress() async {
    final creds = await _credentials();
    return creds.address;
  }

  Future<void> _ensureContractLoaded() async {
    if (_contract != null) return;

    try {
      final abiStr = await rootBundle.loadString('assets/abi/DappWorks.json');

      if (abiStr.trim().isEmpty) {
        throw Exception(
          'ABI file is empty. Please add your smart contract ABI to assets/abi/DappWorks.json'
        );
      }

      final abiJson = json.decode(abiStr);

      final dynamic abiData;
      if (abiJson is Map<String, dynamic>) {
        if (abiJson.containsKey('abi')) {
          abiData = abiJson['abi'];
        } else {
          throw Exception('ABI file must contain an "abi" key or be a direct array');
        }
      } else if (abiJson is List) {
        abiData = abiJson;
      } else {
        throw Exception('Invalid ABI format');
      }

      final abi = web3.ContractAbi.fromJson(
        json.encode(abiData),
        'DappWorks',
      );

      final address = web3.EthereumAddress.fromHex(contractAddressHex);
      _contract = web3.DeployedContract(abi, address);

      print('✅ Contract loaded successfully at $contractAddressHex');
    } catch (e) {
      print('❌ Error loading contract: $e');
      
      if (e.toString().contains('Unable to load asset')) {
        throw Exception(
          'ABI file not found. Make sure assets/abi/DappWorks.json exists '
          'and is listed in pubspec.yaml under assets'
        );
      }
      
      rethrow;
    }
  }

  Future<List<dynamic>> _read(String fn, [List<dynamic> args = const []]) async {
    try {
      await _ensureContractLoaded();
      final f = _contract!.function(fn);
      final result = await _client.call(contract: _contract!, function: f, params: args);
      print('✅ Call to $fn successful');
      return result;
    } catch (e) {
      // Handle RangeError specifically - usually means empty array or wrong ABI
      if (e is RangeError) {
        print('⚠️ RangeError in $fn - likely no data or ABI mismatch. Returning empty result.');
        return [[]]; // Return empty array wrapped in list
      }
      print('❌ Error calling $fn: $e');
      rethrow;
    }
  }

  Future<String> _write(
    String fn, {
    List<dynamic> args = const [],
    web3.EtherAmount? value,
  }) async {
    try {
      await _ensureContractLoaded();
      final f = _contract!.function(fn);
      
      print('📤 Sending transaction to $fn');
      if (value != null) {
        print('💰 Value: ${value.getValueInUnit(web3.EtherUnit.ether)} ETH');
      }
      
      final txHash = await _client.sendTransaction(
        await _credentials(),
        web3.Transaction.callContract(
          contract: _contract!,
          function: f,
          parameters: args,
          value: value,
        ),
      );
      
      print('✅ Transaction sent: $txHash');
      return txHash;
    } catch (e) {
      print('❌ Error in transaction $fn: $e');
      rethrow;
    }
  }

  Future<String?> getConnectedAccountOrNull() async {
    try {
      final addr = await _ownAddress();
      return addr.hex;
    } catch (_) {
      return null;
    }
  }

  Future<String?> connectWallet() async {
    throw UnimplementedError('Implement connectWallet with WalletConnect');
  }

  Future<void> addJobListing({
    required String title,
    required String description,
    required String tags,
    required String prizeEth,
  }) async {
    try {
      print('🔨 Creating job: $title');
      print('💰 Prize: $prizeEth ETH');
      print('🏷️ Tags: $tags');
      
      final wei = _ethToWei(prizeEth);
      final value = web3.EtherAmount.inWei(wei);
      
      await _write('addJobListing', args: [title, description, tags], value: value);
      print('✅ Job listing added successfully');
    } catch (e) {
      print('❌ Failed to add job listing: $e');
      rethrow;
    }
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
    try {
      print('📥 Fetching jobs...');
      final res = await _read('getJobs');
      
      if (res.isEmpty) {
        print('⚠️ Empty response from getJobs');
        return [];
      }
      
      return _jobsFromResponse(res.first as List);
    } catch (e) {
      print('❌ Error in getJobs: $e');
      return [];
    }
  }

  Future<List<Job>> getMyJobs() async {
    try {
      final res = await _read('getMyJobs');
      return _jobsFromResponse(res.first as List);
    } catch (e) {
      print('❌ Error in getMyJobs: $e');
      return [];
    }
  }

  Future<List<Job>> getAssignedJobs() async {
    try {
      final res = await _read('getAssignedJobs');
      return _jobsFromResponse(res.first as List);
    } catch (e) {
      print('❌ Error in getAssignedJobs: $e');
      return [];
    }
  }

  Future<List<Job>> getJobsForBidder() async {
    try {
      final res = await _read('getJobsForBidder');
      return _jobsFromResponse(res.first as List);
    } catch (e) {
      print('❌ Error in getJobsForBidder: $e');
      return [];
    }
  }

  Future<Job?> getJob(int id) async {
    try {
      final res = await _read('getJob', [BigInt.from(id)]);
      final list = _jobsFromResponse([res.first]);
      return list.isEmpty ? null : list.first;
    } catch (e) {
      print('❌ Error in getJob: $e');
      return null;
    }
  }

  Future<List<Bidder>> getBidders(int id) async {
    try {
      final res = await _read('getBidders', [BigInt.from(id)]);
      final list = (res.first as List)
          .map((e) => Bidder(
                id: (e[0] as BigInt).toInt(),
                jId: (e[1] as BigInt).toInt(),
                account: (e[2] as web3.EthereumAddress).hex.toLowerCase(),
              ))
          .toList();
      return list;
    } catch (e) {
      print('❌ Error in getBidders: $e');
      return [];
    }
  }

  List<Job> _jobsFromResponse(List<dynamic> raw) {
    try {
      print('🔄 Processing ${raw.length} jobs');
      
      if (raw.isEmpty) {
        print('ℹ️ No jobs to process');
        return [];
      }
      
      return raw.map((e) {
        try {
          final id = (e[0] as BigInt).toInt();
          final owner = (e[1] as web3.EthereumAddress).hex.toLowerCase();
          final freelancer = (e[2] as web3.EthereumAddress).hex.toLowerCase();
          final jobTitle = e[3] as String;
          final description = e[4] as String;
          
          // Contract stores tags as comma-separated string
          final tagsString = e[5] as String;
          final tags = tagsString
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();
          
          final prizeWei = e[6] as BigInt;
          final paidOut = e[7] as bool;
          final ts = e[8] as BigInt;
          final listed = e[9] as bool;
          final disputed = e[10] as bool;
          final bidders = (e[11] as List)
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
        } catch (e) {
          print('❌ Error processing individual job: $e');
          rethrow;
        }
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('❌ Error in _jobsFromResponse: $e');
      return [];
    }
  }

  BigInt _pow10(int n) => BigInt.from(10).pow(n);
  
  BigInt _ethToWei(String eth) {
    final s = eth.trim();
    if (s.isEmpty) return BigInt.zero;
    final parts = s.split('.');
    final whole = BigInt.parse(parts[0].isEmpty ? '0' : parts[0]);
    final frac = parts.length > 1 ? parts[1] : '0';
    final fracPadded = (frac + '0' * 18).substring(0, 18);
    return whole * _pow10(18) + BigInt.parse(fracPadded);
  }
}