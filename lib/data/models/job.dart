import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final int id;
  final String owner;
  final String freelancer; // 0x0.. if none
  final String jobTitle;
  final String description;
  final List<String> tags;
  final String prizeEth;   // keep as string for display parity with web
  final bool paidOut;
  final BigInt timestamp;
  final bool listed;
  final bool disputed;
  final List<String> bidders;

  const Job({
    required this.id,
    required this.owner,
    required this.freelancer,
    required this.jobTitle,
    required this.description,
    required this.tags,
    required this.prizeEth,
    required this.paidOut,
    required this.timestamp,
    required this.listed,
    required this.disputed,
    required this.bidders,
  });

  Job copyWith({
    int? id,
    String? owner,
    String? freelancer,
    String? jobTitle,
    String? description,
    List<String>? tags,
    String? prizeEth,
    bool? paidOut,
    BigInt? timestamp,
    bool? listed,
    bool? disputed,
    List<String>? bidders,
  }) => Job(
    id: id ?? this.id,
    owner: owner ?? this.owner,
    freelancer: freelancer ?? this.freelancer,
    jobTitle: jobTitle ?? this.jobTitle,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    prizeEth: prizeEth ?? this.prizeEth,
    paidOut: paidOut ?? this.paidOut,
    timestamp: timestamp ?? this.timestamp,
    listed: listed ?? this.listed,
    disputed: disputed ?? this.disputed,
    bidders: bidders ?? this.bidders,
  );

  @override
  List<Object?> get props => [id, owner, freelancer, jobTitle, description, tags, prizeEth, paidOut, timestamp, listed, disputed, bidders];
}
