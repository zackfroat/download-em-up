/// Supported account roles for InsideTeam
enum UserRole {
  staff,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.staff:
        return 'Staff';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isStaff => this == UserRole.staff;

  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.staff;
    final normalized = roleStr.trim().toLowerCase();
    if (normalized == 'admin') return UserRole.admin;
    return UserRole.staff;
  }
}
