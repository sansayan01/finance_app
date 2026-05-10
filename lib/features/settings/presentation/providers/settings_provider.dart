import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/activity_log_repository_provider.dart';
import '../../data/models/activity_log_model.dart';

class SystemSettings {
  final double defaultLoanInterest;
  final double defaultSavingsYield;
  final double latePenaltyPercentage;
  final bool enableNotifications;
  final bool biometricAuth;
  final String currency;

  SystemSettings({
    this.defaultLoanInterest = 12.0,
    this.defaultSavingsYield = 8.5,
    this.latePenaltyPercentage = 2.0,
    this.enableNotifications = true,
    this.biometricAuth = false,
    this.currency = 'INR',
  });

  SystemSettings copyWith({
    double? defaultLoanInterest,
    double? defaultSavingsYield,
    double? latePenaltyPercentage,
    bool? enableNotifications,
    bool? biometricAuth,
    String? currency,
  }) {
    return SystemSettings(
      defaultLoanInterest: defaultLoanInterest ?? this.defaultLoanInterest,
      defaultSavingsYield: defaultSavingsYield ?? this.defaultSavingsYield,
      latePenaltyPercentage: latePenaltyPercentage ?? this.latePenaltyPercentage,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      currency: currency ?? this.currency,
    );
  }
}

class SystemSettingsNotifier extends StateNotifier<SystemSettings> {
  final Ref _ref;
  SystemSettingsNotifier(this._ref) : super(SystemSettings());

  void updateLoanInterest(double value) {
    _log('Loan Interest', '${state.defaultLoanInterest}%', '$value%');
    state = state.copyWith(defaultLoanInterest: value);
  }

  void updateSavingsYield(double value) {
    _log('Savings Yield', '${state.defaultSavingsYield}%', '$value%');
    state = state.copyWith(defaultSavingsYield: value);
  }

  void updatePenalty(double value) {
    _log('Late Penalty', '${state.latePenaltyPercentage}%', '$value%');
    state = state.copyWith(latePenaltyPercentage: value);
  }

  void toggleNotifications(bool value) => state = state.copyWith(enableNotifications: value);
  void toggleBiometric(bool value) => state = state.copyWith(biometricAuth: value);
  
  void _log(String param, String oldVal, String newVal) {
    _ref.read(activityLogRepositoryProvider).log(
      action: 'System Parameter Updated',
      details: 'Changed $param from $oldVal to $newVal',
      type: ActivityType.systemUpdate,
    );
  }
}

final settingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier(ref);
});
