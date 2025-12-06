// lib/data/models/user_type.dart
enum UserType {
  freelancer,
  client,
}

extension UserTypeExt on UserType {
  String get label =>
      this == UserType.client ? 'Client' : 'Freelancer';

  String get description {
    switch (this) {
      case UserType.client:
        return 'Post jobs, manage bids, select freelancers and track progress.';
      case UserType.freelancer:
        return 'Browse jobs, place bids and manage your gigs.';
    }
  }
}
