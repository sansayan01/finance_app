import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SystemRole { administrator, fieldStaff, operations, retailMember }

class NewUserState {
  final String fullName;
  final String email;
  final String mobileNumber;
  final SystemRole role;
  final String employeeId;
  final String assignedZone;
  final String password;
  
  NewUserState({
    this.fullName = '',
    this.email = '',
    this.mobileNumber = '',
    this.role = SystemRole.fieldStaff,
    this.employeeId = '',
    this.assignedZone = '',
    this.password = '',
  });

  NewUserState copyWith({
    String? fullName,
    String? email,
    String? mobileNumber,
    SystemRole? role,
    String? employeeId,
    String? assignedZone,
    String? password,
  }) {
    return NewUserState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      assignedZone: assignedZone ?? this.assignedZone,
      password: password ?? this.password,
    );
  }
}

class NewUserNotifier extends StateNotifier<NewUserState> {
  NewUserNotifier() : super(NewUserState());

  void updateFullName(String value) => state = state.copyWith(fullName: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updateMobileNumber(String value) => state = state.copyWith(mobileNumber: value);
  void updateRole(SystemRole role) => state = state.copyWith(role: role);
  void updateEmployeeId(String value) => state = state.copyWith(employeeId: value);
  void updateAssignedZone(String value) => state = state.copyWith(assignedZone: value);
  void updatePassword(String value) => state = state.copyWith(password: value);

  void reset() => state = NewUserState();
}

final newUserProvider = StateNotifierProvider<NewUserNotifier, NewUserState>((ref) {
  return NewUserNotifier();
});
