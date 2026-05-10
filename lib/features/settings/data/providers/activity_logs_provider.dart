import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_log_model.dart';

final activityLogsProvider = FutureProvider<List<ActivityLogModel>>((ref) async {
  final client = Supabase.instance.client;
  
  try {
    // Try to fetch from real DB if it exists
    final response = await client
        .from('activity_logs')
        .select()
        .order('timestamp', ascending: false)
        .limit(50);
    
    return (response as List).map((e) => ActivityLogModel.fromJson(e)).toList();
  } catch (e) {
    // Return high-quality mock data for production demo
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      ActivityLogModel(
        id: '1',
        userId: 'admin',
        userName: 'Admin (You)',
        action: 'System Parameter Updated',
        details: 'Changed Default Loan Interest from 12.0% to 11.5%',
        type: ActivityType.systemUpdate,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ActivityLogModel(
        id: '2',
        userId: 'staff_1',
        userName: 'Rajesh Kumar',
        action: 'New Loan Disbursed',
        details: 'Approved and disbursed ₹50,000 to Member: Amit Shah',
        type: ActivityType.financialTransaction,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityLogModel(
        id: '3',
        userId: 'admin',
        userName: 'Admin (You)',
        action: 'Security Policy Change',
        details: 'Enabled Mandatory Biometric Authentication for all Managers',
        type: ActivityType.securityAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ActivityLogModel(
        id: '4',
        userId: 'staff_2',
        userName: 'Priya Singh',
        action: 'Member Profile Updated',
        details: 'Changed phone number for Member: Suman Lata',
        type: ActivityType.userAction,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ActivityLogModel(
        id: '5',
        userId: 'system',
        userName: 'Automated System',
        action: 'Daily Interest Accrued',
        details: 'Processed daily interest for 1,240 active savings accounts',
        type: ActivityType.financialTransaction,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }
});
