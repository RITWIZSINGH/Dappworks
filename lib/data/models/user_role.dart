enum UserRole {
  client,
  freelancer,
}

extension UserRoleExt on UserRole {
  String get label => this == UserRole.client ? 'Client' : 'Freelancer';

  static UserRole fromString(String value) {
    if (value.toLowerCase() == 'freelancer') return UserRole.freelancer;
    return UserRole.client;
  }

  String get asString => this == UserRole.client ? 'client' : 'freelancer';
}
