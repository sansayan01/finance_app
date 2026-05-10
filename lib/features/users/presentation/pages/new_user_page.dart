import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/new_user_provider.dart';

class NewUserPage extends ConsumerStatefulWidget {
  const NewUserPage({super.key});

  @override
  ConsumerState<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends ConsumerState<NewUserPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  // PAN Keyboard switching state
  TextInputType _panKeyboardType = TextInputType.text;
  final FocusNode _panFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(newUserProvider);
      _fullNameController.text = state.fullName;
      _emailController.text = state.email;
      _mobileController.text = state.mobileNumber;
      _employeeIdController.text = state.employeeId;
      _zoneController.text = state.assignedZone;
      _addressController.text = ""; // Initial empty
      _aadharController.text = state.aadharNumber;
      _panController.text = state.panNumber;
      _passwordController.text = state.password;
    });
    
    _panFocusNode.addListener(() {
      if (_panFocusNode.hasFocus) {
        _updatePanKeyboard(_panController.text);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _employeeIdController.dispose();
    _zoneController.dispose();
    _addressController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _passwordController.dispose();
    _panFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(newUserProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New User Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Configure system access and administrative roles',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFormDetails(state)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 1, child: _buildSummary(state)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildSummary(state),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFormDetails(state),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFormDetails(NewUserState state) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ACCOUNT DETAILS', Icons.person_outline),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'FULL NAME *',
                  hint: 'Enter legal name',
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (val) => ref.read(newUserProvider.notifier).updateFullName(val),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildInputField(
                  label: 'EMAIL ADDRESS *',
                  hint: 'staff@microflow.pro',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  onChanged: (val) => ref.read(newUserProvider.notifier).updateEmail(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'MOBILE NUMBER',
                  hint: 'Contact number',
                  icon: Icons.phone_android_outlined,
                  controller: _mobileController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) => ref.read(newUserProvider.notifier).updateMobileNumber(val),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SYSTEM ROLE *'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: state.role.name,
                      hint: 'Select role',
                      icon: Icons.shield_outlined,
                      items: SystemRole.values.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(newUserProvider.notifier).updateRole(
                            SystemRole.values.firstWhere((e) => e.name == val),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
            label: 'RESIDENTIAL ADDRESS',
            hint: 'Enter complete home address',
            icon: Icons.home_outlined,
            controller: _addressController,
            textCapitalization: TextCapitalization.words,
            onChanged: (val) {}, 
          ),
          
          if (state.role != SystemRole.retailMember) ...[
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionHeader('FIELD OPERATIONS', Icons.corporate_fare_outlined),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'EMPLOYEE ID',
                    hint: 'Internal reference #',
                    controller: _employeeIdController,
                    onChanged: (val) => ref.read(newUserProvider.notifier).updateEmployeeId(val),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildInputField(
                    label: 'ASSIGNED ZONE / AREA',
                    hint: 'e.g. North Sector',
                    icon: Icons.location_on_outlined,
                    controller: _zoneController,
                    onChanged: (val) => ref.read(newUserProvider.notifier).updateAssignedZone(val),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader('IDENTITY DETAILS', Icons.badge_outlined),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'AADHAR CARD NUMBER *',
                  hint: '12-digit UID number',
                  icon: Icons.fingerprint_outlined,
                  controller: _aadharController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) => ref.read(newUserProvider.notifier).updateAadharNumber(val),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildInputField(
                  label: 'PAN CARD NUMBER *',
                  hint: 'ABCDE 1234 F',
                  icon: Icons.credit_card_outlined,
                  controller: _panController,
                  focusNode: _panFocusNode,
                  keyboardType: _panKeyboardType,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    _PanFormatter(),
                  ],
                  onChanged: (val) {
                    ref.read(newUserProvider.notifier).updatePanNumber(val);
                    _updatePanKeyboard(val);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader('SECURITY CREDENTIALS', Icons.key_outlined),
          const SizedBox(height: AppSpacing.lg),
          
          SizedBox(
            width: 400, // Make it roughly half-width on large screens as per screenshot
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('INITIAL PASSWORD *'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (val) => ref.read(newUserProvider.notifier).updatePassword(val),
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters',
                    hintStyle: const TextStyle(color: AppColors.textMutedLight, fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The user will be prompted to change their password upon their first successful login.',
                  style: TextStyle(color: AppColors.textMutedLight, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(newUserProvider.notifier).reset();
                  context.pop();
                },
                child: const Text('Discard', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Profile...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Create Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  void _updatePanKeyboard(String val) {
    TextInputType newType;
    if (val.length >= 5 && val.length < 9) {
      newType = TextInputType.number;
    } else {
      newType = TextInputType.text;
    }

    if (newType != _panKeyboardType) {
      setState(() {
        _panKeyboardType = newType;
      });
      // Force keyboard refresh by refocussing
      if (_panFocusNode.hasFocus) {
        _panFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 50), () {
          _panFocusNode.requestFocus();
        });
      }
    }
  }

  Widget _buildSummary(NewUserState state) {
    String roleDisplay = _getRoleDisplayName(state.role);
    String roleDescription = _getRoleDescription(state.role);

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Permission Matrix',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildLabel('SELECTED ROLE'),
              const SizedBox(height: 4),
              Text(
                roleDisplay,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                roleDescription,
                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
        
        const SizedBox(height: AppSpacing.lg),
        
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'AUDIT LOG',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'All user creation events are logged in the system timeline with the performing administrator\'s timestamp.',
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: AppColors.textMutedLight,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    IconData? icon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMutedLight, fontWeight: FontWeight.normal),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.textMuted, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    IconData? icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          items: items.map((String item) {
            SystemRole role = SystemRole.values.firstWhere((e) => e.name == item);
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _getRoleDisplayName(role),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  String _getRoleDisplayName(SystemRole role) {
    switch (role) {
      case SystemRole.administrator:
        return 'System Administrator';
      case SystemRole.fieldStaff:
        return 'Field Staff (Operations)';
      case SystemRole.operations:
        return 'Operations Manager';
      case SystemRole.retailMember:
        return 'Retail Member';
    }
  }

  String _getRoleDescription(SystemRole role) {
    switch (role) {
      case SystemRole.administrator:
        return 'Administrators have full system access, can manage all users, system configurations, and view all global reporting.';
      case SystemRole.fieldStaff:
        return 'Field Staff can manage loans, collect payments, and register new members in their assigned zones.';
      case SystemRole.operations:
        return 'Operations Managers oversee field staff, approve loan applications, and manage regional reporting.';
      case SystemRole.retailMember:
        return 'Retail Members can only view their personal savings, loans, and transaction history.';
    }
  }
}

class _PanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();
    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (i < 5) {
        // First 5 letters
        if (RegExp(r'[A-Z]').hasMatch(char)) formatted += char;
      } else if (i < 9) {
        // Next 4 digits
        if (RegExp(r'[0-9]').hasMatch(char)) formatted += char;
      } else if (i < 10) {
        // Last letter
        if (RegExp(r'[A-Z]').hasMatch(char)) formatted += char;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
