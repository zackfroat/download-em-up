import 'user_role.dart';

/// User profile model representing the authenticated employee
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String employeeId; // e.g. D1CDIM2625C or ADM9042A
  final UserRole role;
  final String? department;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.employeeId,
    required this.role,
    this.department,
    this.avatarUrl,
  });

  /// Displays initials for avatar fallback (e.g. "ZZ" for "Za Atizi Zainuddin")
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'IT';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Formatted identifier string for UI (e.g. "Staff ID: D1CDIM2625C")
  String get formattedId {
    final prefix = role.isAdmin ? 'Admin ID' : 'Staff ID';
    return '$prefix: $employeeId';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? fallbackEmail}) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? fallbackEmail ?? '',
      fullName: map['full_name']?.toString() ?? 'Team Member',
      employeeId: map['employee_id']?.toString() ??
          (map['staff_id']?.toString() ??
              (map['admin_id']?.toString() ?? 'ID-PENDING')),
      role: UserRole.fromString(map['role']?.toString()),
      department: map['department']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'employee_id': employeeId,
      'role': role.name,
      'department': department,
      'avatar_url': avatarUrl,
    };
  }
}
