// lib/state/app_state.dart
import 'package:flutter/foundation.dart';
import '../data/services/blockchain_service.dart'; // or '../data/services/blockchain_service.dart'
import '../data/services/local_job_service.dart';
import '../data/models/job.dart';    // or '../data/models/job.dart'
import '../data/models/bidder.dart'; // or '../data/models/bidder.dart'

class AppState extends ChangeNotifier {
  final BlockchainService? _blockchainService;
  final LocalJobService _localService;

  bool _useLocalService;

  // Session / data
  String? connectedAccount;
  List<Job> jobs = [];
  List<Job> myProjects = [];
  List<Job> myGigs = [];
  List<Job> myBidJobs = [];
  List<Bidder> bidders = [];
  Job? currentJob;

  // Loading / errors
  bool isLoading = false;
  String? errorMessage;

  AppState({
    BlockchainService? blockchainService,
    bool useLocalService = true,
  })  : _blockchainService = blockchainService,
        _localService = LocalJobService(),
        _useLocalService = useLocalService {
    _init();
  }

  bool get isUsingLocalService => _useLocalService;

  Future<void> _init() async {
    // In local mode, seed sample data once for dev convenience
    if (_useLocalService) {
      await _localService.initializeSampleData();
    }
    await boot();
  }

  /// Switch service mode at runtime (e.g., from a settings screen)
  Future<void> toggleServiceMode({required bool useLocal}) async {
    _useLocalService = useLocal;
    errorMessage = null;
    // Optional: clear & seed when switching to local
    if (_useLocalService) {
      await _localService.initializeSampleData();
    }
    notifyListeners();
    await boot();
  }

  Future<void> boot() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (_useLocalService) {
        connectedAccount = await _localService.getConnectedAccountOrNull();
      } else {
        if (_blockchainService == null) {
          throw Exception('Blockchain service not initialized');
        }
        connectedAccount = await _blockchainService!.getConnectedAccountOrNull();
      }

      await refreshAll();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to boot: $e';
      debugPrint('❌ Boot error: $e');
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    try {
      debugPrint('🔄 Refreshing all data...');
      if (_useLocalService) {
        jobs       = await _localService.getJobs();
        myProjects = await _localService.getMyJobs();
        myGigs     = await _localService.getAssignedJobs();
        myBidJobs  = await _localService.getJobsForBidder();
      } else {
        final chain = _ensureChain();
        jobs       = await chain.getJobs();
        myProjects = await chain.getMyJobs();
        myGigs     = await chain.getAssignedJobs();
        myBidJobs  = await chain.getJobsForBidder();
      }

      debugPrint('✅ Data refreshed - Jobs: ${jobs.length}, My Projects: ${myProjects.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
      errorMessage = 'Failed to refresh data: $e';
      notifyListeners();
    }
  }

  Future<void> refreshJobs() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      jobs = _useLocalService
          ? await _localService.getJobs()
          : await _ensureChain().getJobs();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load jobs: $e';
      debugPrint('❌ Error loading jobs: $e');
      notifyListeners();
    }
  }

  Future<void> connectWallet() async {
    try {
      if (_useLocalService) {
        connectedAccount = await _localService.connectWallet();
      } else {
        connectedAccount = await _ensureChain().connectWallet();
      }
      notifyListeners();
      await refreshAll();
    } catch (e) {
      debugPrint('❌ Connect wallet error: $e');
      errorMessage = 'Failed to connect wallet: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addJob({
    required String title,
    required String description,
    required List<String> tags,
    required String prizeEth,
  }) async {
    try {
      debugPrint('➕ Adding job: $title');
      final tagsString = tags.join(',');

      if (_useLocalService) {
        await _localService.addJobListing(
          title: title,
          description: description,
          tags: tagsString,
          prizeEth: prizeEth,
        );
      } else {
        await _ensureChain().addJobListing(
          title: title,
          description: description,
          tags: tagsString,
          prizeEth: prizeEth,
        );
      }

      debugPrint('✅ Job added successfully, refreshing...');
      await refreshAll();
    } catch (e) {
      debugPrint('❌ Add job error: $e');
      errorMessage = 'Failed to add job: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateJob({
    required int id,
    required String title,
    required String description,
    required List<String> tags,
  }) async {
    try {
      final tagsString = tags.join(',');

      if (_useLocalService) {
        await _localService.updateJob(
          id: id,
          title: title,
          description: description,
          tags: tagsString,
        );
      } else {
        await _ensureChain().updateJob(
          id: id,
          title: title,
          description: description,
          tags: tagsString,
        );
      }

      await refreshAll();
    } catch (e) {
      debugPrint('❌ Error updating job: $e');
      errorMessage = 'Failed to update job: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteJob(int id) async {
    try {
      if (_useLocalService) {
        await _localService.deleteJob(id);
      } else {
        await _ensureChain().deleteJob(id);
      }
      await refreshAll();
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      errorMessage = 'Failed to delete job: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> bidForJob(int id) async {
    try {
      if (_useLocalService) {
        await _localService.bidForJob(id);
      } else {
        await _ensureChain().bidForJob(id);
      }
      await refreshAll();
    } catch (e) {
      debugPrint('❌ Bid error: $e');
      errorMessage = 'Failed to place bid: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> payout(int id) async {
    try {
      if (_useLocalService) {
        await _localService.payout(id);
      } else {
        await _ensureChain().payout(id);
      }
      await refreshAll();
    } catch (e) {
      debugPrint('❌ Payout error: $e');
      errorMessage = 'Failed to process payout: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadBidders(int jobId) async {
    try {
      if (_useLocalService) {
        bidders = await _localService.getBidders(jobId);
        currentJob = await _localService.getJob(jobId);
      } else {
        bidders = await _ensureChain().getBidders(jobId);
        currentJob = await _ensureChain().getJob(jobId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Load bidders error: $e');
      errorMessage = 'Failed to load bidders: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptBid({
    required int id,
    required int jId,
    required String account,
  }) async {
    try {
      if (_useLocalService) {
        await _localService.acceptBid(id: id, jId: jId, bidder: account);
      } else {
        await _ensureChain().acceptBid(id: id, jId: jId, bidder: account);
      }
      await loadBidders(jId);
    } catch (e) {
      debugPrint('❌ Accept bid error: $e');
      errorMessage = 'Failed to accept bid: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Job?> getJob(int id) async {
    try {
      if (_useLocalService) {
        return await _localService.getJob(id);
      } else {
        return await _ensureChain().getJob(id);
      }
    } catch (e) {
      debugPrint('❌ Error getting job: $e');
      return null;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  BlockchainService _ensureChain() {
    final c = _blockchainService;
    if (c == null) {
      throw Exception('Blockchain service not initialized');
    }
    return c;
  }

  /// Dev helper: reset local storage and reseed
  Future<void> clearLocalData() async {
    if (_useLocalService) {
      await _localService.clearAllData();
      await _localService.initializeSampleData();
      await refreshAll();
    }
  }
}
