import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      _addressController.text = "";
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () {
            ref.read(newUserProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New User Profile',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Configure system access and administrative roles',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
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
                  Expanded(flex: 2, child: _buildFormDetails(state, theme, isDark, primary)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 1, child: _buildSummary(state, theme, isDark, primary)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildSummary(state, theme, isDark, primary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFormDetails(state, theme, isDark, primary),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFormDetails(NewUserState state, ThemeData theme, bool isDark, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('ACCOUNT DETAILS', Icons.person_outline, theme, primary),
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
                  theme: theme, isDark: isDark,
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
                  theme: theme, isDark: isDark,
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
                  theme: theme, isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('SYSTEM ROLE *', theme),
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
                      theme: theme, isDark: isDark,
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
            theme: theme, isDark: isDark,
          ),
          
          if (state.role != SystemRole.retailMember) ...[
            const SizedBox(height: AppSpacing.xxl),
            _buildSectionHeader('FIELD OPERATIONS', Icons.corporate_fare_outlined, theme, primary),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'EMPLOYEE ID',
                    hint: 'Internal reference #',
                    controller: _employeeIdController,
                    onChanged: (val) => ref.read(newUserProvider.notifier).updateEmployeeId(val),
                    theme: theme, isDark: isDark,
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
                    theme: theme, isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader('IDENTITY DETAILS', Icons.badge_outlined, theme, primary),
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
                  theme: theme, isDark: isDark,
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
                  theme: theme, isDark: isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionHeader('SECURITY CREDENTIALS', Icons.key_outlined, theme, primary),
          const SizedBox(height: AppSpacing.lg),
          
          SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('INITIAL PASSWORD *', theme),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (val) => ref.read(newUserProvider.notifier).updatePassword(val),
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'The user will be prompted to change their password upon their first successful login.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
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
                child: Text('Discard', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Profile...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Create Profile', style: TextStyle(fontWeight: FontWeight.w600)),
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
      if (_panFocusNode.hasFocus) {
        _panFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 50), () {
          _panFocusNode.requestFocus();
        });
      }
    }
  }

  Widget _buildSummary(NewUserState state, ThemeData theme, bool isDark, Color primary) {
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
                  Icon(Icons.shield_outlined, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Permission Matrix', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildLabel('SELECTED ROLE', theme),
              const SizedBox(height: 4),
              Text(
                roleDisplay,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                roleDescription,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, height: 1.5),
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
              Text(
                'AUDIT LOG',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              Text(
                'All user creation events are logged in the system timeline with the performing administrator\'s timestamp.',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme, Color primary) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, theme),
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
            prefixIcon: icon != null ? Icon(icon, color: theme.textTheme.bodySmall?.color, size: 20) : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: theme.textTheme.bodySmall),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.textTheme.bodySmall?.color),
          dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          items: items.map((String item) {
            SystemRole role = SystemRole.values.firstWhere((e) => e.name == item);
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: theme.textTheme.bodySmall?.color, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _getRoleDisplayName(role),
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
        if (RegExp(r'[A-Z]').hasMatch(char)) formatted += char;
      } else if (i < 9) {
        if (RegExp(r'[0-9]').hasMatch(char)) formatted += char;
      } else if (i < 10) {
        if (RegExp(r'[A-Z]').hasMatch(char)) formatted += char;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
