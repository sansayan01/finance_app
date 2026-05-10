# MicroFlow Pro - Technical Specification

## 1. Project Overview

**Project Name:** MicroFlow Pro
**Type:** Cross-platform Financial Management Mobile Application (Flutter)
**Core Functionality:** Premium micro-finance management ecosystem for MFIs and savings groups with surgical precision in lending/savings operations

## 2. Technology Stack & Choices

### Framework & Language
- **Flutter SDK:** 3.11+
- **Dart:** 3.1+
- **Target Platforms:** iOS, Android

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  supabase_flutter: ^2.12.4
  google_fonts: ^8.1.0
  flutter_riverpod: ^3.3.1
  intl: ^0.20.2
  fl_chart: ^0.69.0
  shimmer: ^3.0.0
  blur: ^4.0.0
  go_router: ^14.6.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  shared_preferences: ^2.3.3
  connectivity_plus: ^6.0.5
  flutter_animate: ^4.5.0
```

### State Management
- **Riverpod** with code generation for reactive state management
- Providers for auth, loans, savings, and user state

### Architecture Pattern
- **Clean Architecture** with feature-first organization
- Layers: Presentation → Domain → Data
- Shared core modules for UI components and utilities

## 3. Feature List

### Authentication & Security
- Supabase Auth integration (email/password)
- TOTP 2FA support for admin accounts
- Secure session management
- RBAC with role-based UI rendering

### Loan Management
- Manual underwriting with custom principal, interest rate, tenure
- EMI schedule generation (Daily/Weekly/Monthly/Fortnightly)
- Amortization calculator with principal/interest breakdown
- Loan status pipeline: Draft → Submitted → Under Review → Approved/Rejected
- Risk tracking: Standard vs Default indicators

### Savings Mobilization
- Recurring savings plan configuration
- Target maturity value tracking
- Progress visualization with animated gauges
- Deposit ledger with penalty calculation
- Maturity readiness indicators

### Member Management
- Smart KYC validation (PAN, Aadhar, Phone)
- PAN format: AAAAA1111A
- Aadhar: 12-digit numeric
- Phone: Localized formatting
- Address auto-standardization
- Member 360-degree profile view

### Portfolio & Analytics
- Real-time KPI dashboard
- Disbursement vs Collection charts
- Savings growth trends
- Delinquency tracking
- CSV/JSON export capability

### Navigation & UX
- **Web:** Floating glassmorphic HUD navigation island
- **Mobile:** LumaBar - bottom navigation with glowing active states
- Animated page transitions (150-300ms)
- Pull-to-refresh with custom animations
- Skeleton loading states

## 4. UI/UX Design Direction

### Visual Style
- **"Futuristic Professional"** - Premium fintech aesthetic
- Heavy use of **Glassmorphism** with frosted glass effects
- High-intensity background blurs with subtle border highlights
- Depth through layered translucent surfaces

### Color Scheme
```
Primary Gradient:
  - Teal: #00D9FF (Cyan accent)
  - Indigo: #6366F1 (Primary)
  - Slate: #1E293B (Background)

Aurora Mesh Palette:
  - #00D9FF (Cyan)
  - #6366F1 (Indigo)
  - #8B5CF6 (Purple)
  - #06B6D4 (Teal)

Glass Effect:
  - Background: rgba(255, 255, 255, 0.08)
  - Border: rgba(255, 255, 255, 0.15)
  - Blur: 20-40px
```

### Typography
- **Primary Font:** Inter (Google Fonts)
- **Headings:** 600-700 weight
- **Body:** 400-500 weight
- **Monospace:** JetBrains Mono (for numbers/amounts)

### Layout Approach
- Single-page dashboard with bottom navigation
- Modal sheets for forms and details
- Card-based content organization
- Floating action buttons for primary actions
- Hero animations for page transitions

### Micro-Animations
- Form height transitions: 200ms ease-out
- Status badge updates: 150ms
- Hover/press states: 100ms scale transform
- Page transitions: 300ms slide-fade
- Loading skeletons: Shimmer effect
- Progress animations: 600ms spring curve

### Component Library
1. **GlassButton** - Frosted glass with gradient border
2. **GlassCard** - Translucent container with blur
3. **GlassTextField** - Premium input with glow effect
4. **AuroraBackground** - Animated mesh gradient
5. **LumaBar** - Mobile bottom navigation
6. **HUDNavigation** - Web floating nav island
7. **ProgressGauge** - Circular progress with animation
8. **StatusBadge** - Pill with glow effect
9. **PremiumAppBar** - Glassmorphic top bar

## 5. Database Schema (Supabase)

### Tables
- `profiles` - User profiles with RBAC
- `members` - MFI member records
- `loans` - Loan applications and details
- `loan_schedules` - EMI schedules
- `savings` - Savings accounts
- `savings_plans` - Savings plan configurations
- `transactions` - Financial events ledger
- `audit_log` - Immutable action timeline

## 6. File Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── glass_button.dart
│   │   ├── glass_card.dart
│   │   ├── glass_text_field.dart
│   │   ├── aurora_background.dart
│   │   ├── luma_bar.dart
│   │   ├── hud_navigation.dart
│   │   ├── progress_gauge.dart
│   │   ├── status_badge.dart
│   │   ├── premium_app_bar.dart
│   │   └── shimmer_loading.dart
│   └── utils/
│       ├── kyc_validators.dart
│       ├── formatters.dart
│       └── calculations.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   ├── loans/
│   ├── savings/
│   ├── members/
│   └── analytics/
└── router/
    └── app_router.dart
```