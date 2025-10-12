import 'package:flutter/foundation.dart';
import '../data/models/job.dart';
import '../data/models/bidder.dart';
import '../data/services/blockchain_service.dart';

class AppState extends ChangeNotifier {
  final BlockchainService _chain;
  AppState(this._chain);

  String? connectedAccount;
  List<Job> jobs = [];
  List<Job> myProjects = [];
  List<Job> myGigs = [];
  List<Job> myBidJobs = [];
  List<Bidder> bidders = [];
  Job? currentJob;

  Future<void> boot() async {
    connectedAccount = await _chain.getConnectedAccountOrNull();
    await refreshAll();
  }

  Future<void> refreshAll() async {
    jobs       = await _chain.getJobs();
    myProjects = await _chain.getMyJobs();
    myGigs     = await _chain.getAssignedJobs();
    myBidJobs  = await _chain.getJobsForBidder();
    notifyListeners();
  }

  Future<void> connectWallet() async {
    connectedAccount = await _chain.connectWallet(); // implement walletconnect/metamask deep link
    notifyListeners();
    await refreshAll();
  }

  Future<void> addJob({
    required String title,
    required String description,
    required List<String> tags,
    required String prizeEth,
  }) async {
    await _chain.addJobListing(title: title, description: description, tags: tags.join(','), prizeEth: prizeEth);
    await refreshAll();
  }

  Future<void> bidForJob(int id) async {
    await _chain.bidForJob(id);
    await refreshAll();
  }

  Future<void> deleteJob(int id) async {
    await _chain.deleteJob(id);
    await refreshAll();
  }

  Future<void> payout(int id) async {
    await _chain.payout(id);
    await refreshAll();
  }

  Future<void> loadBidders(int jobId) async {
    bidders = await _chain.getBidders(jobId);
    currentJob = await _chain.getJob(jobId);
    notifyListeners();
  }

  Future<void> acceptBid({required int id, required int jId, required String account}) async {
    await _chain.acceptBid(id: id, jId: jId, bidder: account);
    await loadBidders(jId);
  }
}
