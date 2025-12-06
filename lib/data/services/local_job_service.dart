import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';
import '../models/bidder.dart';

/// Mock service that stores jobs locally for development/testing
/// Use this until your smart contract is deployed
class LocalJobService {
  static const String _jobsKey = 'local_jobs';
  static const String _biddersKey = 'local_bidders';
  static const String _accountKey = 'mock_account';
  static const String _jobIdCounterKey = 'job_id_counter';
  static const String _bidderIdCounterKey = 'bidder_id_counter';

  // Mock wallet address for development
  String get mockWalletAddress => '0x742d35Cc6634C0532925a3b844Bc454e4438f44e';

  /// Initialize with some sample data (optional)
  Future<void> initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJobs = prefs.getString(_jobsKey);
    
    if (existingJobs == null) {
      // Add sample jobs for testing
      final sampleJobs = [
        Job(
          id: 1,
          owner: mockWalletAddress,
          freelancer: '0x0000000000000000000000000000000000000000',
          jobTitle: 'Build a Flutter Mobile App',
          description: 'Looking for an experienced Flutter developer to build a cross-platform mobile application with clean UI/UX.',
          tags: ['Flutter', 'Dart', 'Mobile', 'UI/UX'],
          prizeEth: '0.5',
          paidOut: false,
          timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
          listed: true,
          disputed: false,
          bidders: [],
        ),
        Job(
          id: 2,
          owner: '0x123abc456def789ghi012jkl345mno678pqr901s',
          freelancer: '0x0000000000000000000000000000000000000000',
          jobTitle: 'Smart Contract Development',
          description: 'Need a Solidity expert to develop and deploy secure smart contracts for DeFi project.',
          tags: ['Solidity', 'Web3', 'Smart Contracts'],
          prizeEth: '1.2',
          paidOut: false,
          timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch - 3600000),
          listed: true,
          disputed: false,
          bidders: [],
        ),
      ];
      
      await _saveJobs(sampleJobs);
      await prefs.setInt(_jobIdCounterKey, 3);
    }
  }

  /// Get mock connected account
  Future<String?> getConnectedAccountOrNull() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountKey) ?? mockWalletAddress;
  }

  /// Mock wallet connection
  Future<String?> connectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey, mockWalletAddress);
    return mockWalletAddress;
  }

  /// Add a new job listing
  Future<void> addJobListing({
    required String title,
    required String description,
    required String tags,
    required String prizeEth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jobs = await _loadJobs();
    final jobId = prefs.getInt(_jobIdCounterKey) ?? 1;
    
    final newJob = Job(
      id: jobId,
      owner: mockWalletAddress,
      freelancer: '0x0000000000000000000000000000000000000000',
      jobTitle: title,
      description: description,
      tags: tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      prizeEth: prizeEth,
      paidOut: false,
      timestamp: BigInt.from(DateTime.now().millisecondsSinceEpoch),
      listed: true,
      disputed: false,
      bidders: [],
    );
    
    jobs.add(newJob);
    await _saveJobs(jobs);
    await prefs.setInt(_jobIdCounterKey, jobId + 1);
    
    // ignore: avoid_print
    print('✅ [LOCAL] Job created: $title (ID: $jobId)');
  }

  /// Update an existing job
  Future<void> updateJob({
    required int id,
    required String title,
    required String description,
    required String tags,
  }) async {
    final jobs = await _loadJobs();
    final index = jobs.indexWhere((j) => j.id == id);
    
    if (index == -1) {
      throw Exception('Job not found');
    }
    
    if (jobs[index].owner.toLowerCase() != mockWalletAddress.toLowerCase()) {
      throw Exception('Not authorized to update this job');
    }
    
    jobs[index] = jobs[index].copyWith(
      jobTitle: title,
      description: description,
      tags: tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
    );
    
    await _saveJobs(jobs);
    // ignore: avoid_print
    print('✅ [LOCAL] Job updated: $title');
  }

  /// Delete a job
  Future<void> deleteJob(int id) async {
    final jobs = await _loadJobs();
    final job = jobs.firstWhere((j) => j.id == id, orElse: () => throw Exception('Job not found'));
    
    if (job.owner.toLowerCase() != mockWalletAddress.toLowerCase()) {
      throw Exception('Not authorized to delete this job');
    }
    
    jobs.removeWhere((j) => j.id == id);
    await _saveJobs(jobs);
    // ignore: avoid_print
    print('✅ [LOCAL] Job deleted (ID: $id)');
  }

  /// Bid for a job
  Future<void> bidForJob(int id) async {
    final jobs = await _loadJobs();
    final index = jobs.indexWhere((j) => j.id == id);
    
    if (index == -1) {
      throw Exception('Job not found');
    }
    
    if (jobs[index].bidders.contains(mockWalletAddress.toLowerCase())) {
      throw Exception('Already bid on this job');
    }
    
    final updatedBidders = List<String>.from(jobs[index].bidders)
      ..add(mockWalletAddress.toLowerCase());
    
    jobs[index] = jobs[index].copyWith(bidders: updatedBidders);
    await _saveJobs(jobs);
    
    // Add bidder entry
    final bidders = await _loadBidders();
    final prefs = await SharedPreferences.getInstance();
    final bidderId = prefs.getInt(_bidderIdCounterKey) ?? 1;
    
    bidders.add(Bidder(
      id: bidderId,
      jId: id,
      account: mockWalletAddress.toLowerCase(),
    ));
    
    await _saveBidders(bidders);
    await prefs.setInt(_bidderIdCounterKey, bidderId + 1);
    // ignore: avoid_print
    print('✅ [LOCAL] Bid placed for job ID: $id');
  }

  /// Accept a bid
  Future<void> acceptBid({
    required int id,
    required int jId,
    required String bidder,
  }) async {
    final jobs = await _loadJobs();
    final index = jobs.indexWhere((j) => j.id == jId);
    
    if (index == -1) {
      throw Exception('Job not found');
    }
    
    if (jobs[index].owner.toLowerCase() != mockWalletAddress.toLowerCase()) {
      throw Exception('Not authorized to accept bids for this job');
    }
    
    jobs[index] = jobs[index].copyWith(
      freelancer: bidder.toLowerCase(),
      listed: false,
    );
    
    await _saveJobs(jobs);
    // ignore: avoid_print
    print('✅ [LOCAL] Bid accepted for job ID: $jId');
  }

  /// Mark job as paid out
  Future<void> payout(int id) async {
    final jobs = await _loadJobs();
    final index = jobs.indexWhere((j) => j.id == id);
    
    if (index == -1) {
      throw Exception('Job not found');
    }
    
    if (jobs[index].owner.toLowerCase() != mockWalletAddress.toLowerCase()) {
      throw Exception('Not authorized to payout this job');
    }
    
    jobs[index] = jobs[index].copyWith(paidOut: true);
    await _saveJobs(jobs);
    // ignore: avoid_print
    print('✅ [LOCAL] Job paid out (ID: $id)');
  }

  /// Get all listed jobs
  Future<List<Job>> getJobs() async {
    final jobs = await _loadJobs();
    return jobs.where((j) => j.listed).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get jobs created by current user
  Future<List<Job>> getMyJobs() async {
    final jobs = await _loadJobs();
    return jobs
        .where((j) => j.owner.toLowerCase() == mockWalletAddress.toLowerCase())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get jobs assigned to current user
  Future<List<Job>> getAssignedJobs() async {
    final jobs = await _loadJobs();
    return jobs
        .where((j) => 
            j.freelancer.toLowerCase() == mockWalletAddress.toLowerCase() &&
            j.freelancer != '0x0000000000000000000000000000000000000000')
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get jobs that current user can bid on
  Future<List<Job>> getJobsForBidder() async {
    final jobs = await _loadJobs();
    return jobs
        .where((j) =>
            j.listed &&
            j.owner.toLowerCase() != mockWalletAddress.toLowerCase())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get a specific job
  Future<Job?> getJob(int id) async {
    final jobs = await _loadJobs();
    try {
      return jobs.firstWhere((j) => j.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get bidders for a job
  Future<List<Bidder>> getBidders(int id) async {
    final bidders = await _loadBidders();
    return bidders.where((b) => b.jId == id).toList();
  }

  /// Clear all local data (useful for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jobsKey);
    await prefs.remove(_biddersKey);
    await prefs.remove(_jobIdCounterKey);
    await prefs.remove(_bidderIdCounterKey);
    // ignore: avoid_print
    print('✅ [LOCAL] All data cleared');
  }

  // Private helper methods
  Future<List<Job>> _loadJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_jobsKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _jobFromJson(json)).toList();
  }

  Future<void> _saveJobs(List<Job> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(jobs.map((j) => _jobToJson(j)).toList());
    await prefs.setString(_jobsKey, jsonString);
  }

  Future<List<Bidder>> _loadBidders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_biddersKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => _bidderFromJson(json)).toList();
  }

  Future<void> _saveBidders(List<Bidder> bidders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(bidders.map((b) => _bidderToJson(b)).toList());
    await prefs.setString(_biddersKey, jsonString);
  }

  // JSON serialization helpers
  Map<String, dynamic> _jobToJson(Job job) => {
    'id': job.id,
    'owner': job.owner,
    'freelancer': job.freelancer,
    'jobTitle': job.jobTitle,
    'description': job.description,
    'tags': job.tags,
    'prizeEth': job.prizeEth,
    'paidOut': job.paidOut,
    'timestamp': job.timestamp.toString(),
    'listed': job.listed,
    'disputed': job.disputed,
    'bidders': job.bidders,
  };

  Job _jobFromJson(Map<String, dynamic> json) => Job(
    id: json['id'],
    owner: json['owner'],
    freelancer: json['freelancer'],
    jobTitle: json['jobTitle'],
    description: json['description'],
    tags: List<String>.from(json['tags']),
    prizeEth: json['prizeEth'],
    paidOut: json['paidOut'],
    timestamp: BigInt.parse(json['timestamp']),
    listed: json['listed'],
    disputed: json['disputed'],
    bidders: List<String>.from(json['bidders']),
  );

  Map<String, dynamic> _bidderToJson(Bidder bidder) => {
    'id': bidder.id,
    'jId': bidder.jId,
    'account': bidder.account,
  };

  Bidder _bidderFromJson(Map<String, dynamic> json) => Bidder(
    id: json['id'],
    jId: json['jId'],
    account: json['account'],
  );
}