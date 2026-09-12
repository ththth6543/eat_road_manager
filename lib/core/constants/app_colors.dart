import 'package:flutter/material.dart';

/// 잇로드 매니저 통합 디자인 시스템 컬러 팔레트 (Design System Colors)
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Primary Brand Palette (잇로드 브랜드 오렌지)
  // ===========================================================================
  static const Color primary50 = Color(0xFFFFF7ED);
  static const Color primary100 = Color(0xFFFFEDD5);
  static const Color primary200 = Color(0xFFFED7AA);
  static const Color primary300 = Color(0xFFFDBA74);
  static const Color primary400 = Color(0xFFFB923C);
  static const Color primary500 = Color(0xFFFF8F21); // Core Brand
  static const Color primary600 = Color(0xFFEA580C);
  static const Color primary700 = Color(0xFFC2410C);
  static const Color primary800 = Color(0xFF9A3412);
  static const Color primary900 = Color(0xFF7C2D12);

  // Brand Highlights & Variants
  static const Color primary = primary500;
  static const Color primaryLight = Color(0xFFFFB066);
  static const Color primaryDark = Color(0xFFE07010);
  static const Color primarySubtle = Color(0xFFFFF4EB);

  // ===========================================================================
  // 2. Secondary Palette (매니저 / 비즈니스 블루)
  // ===========================================================================
  static const Color secondary50 = Color(0xFFEFF6FF);
  static const Color secondary100 = Color(0xFFDBEAFE);
  static const Color secondary200 = Color(0xFFBFDBFE);
  static const Color secondary500 = Color(0xFF3182F6);
  static const Color secondary600 = Color(0xFF2563EB);
  static const Color secondary700 = Color(0xFF1D4ED8);

  static const Color secondary = secondary500;
  static const Color secondaryLight = secondary50;
  static const Color secondaryDark = secondary700;

  // ===========================================================================
  // 3. Semantic / Status Palette (상태 및 피드백)
  // ===========================================================================
  // Success (승인, 등록 완료, 정상)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF047857);

  // Warning (주의, 대기 중, 검토 필요)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningDark = Color(0xFFB45309);

  // Error / Danger (인증 실패, 삭제, 오류)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorDark = Color(0xFFB91C1C);

  // Info (정보, 안내, 팁)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ===========================================================================
  // 4. Grayscale & Neutral Palette (토스/배민 스타일 중립 무채색)
  // ===========================================================================
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF2F4F6);
  static const Color gray200 = Color(0xFFE5E8EB);
  static const Color gray300 = Color(0xFFD1D6DB);
  static const Color gray400 = Color(0xFFB0B8C1);
  static const Color gray500 = Color(0xFF8B95A1);
  static const Color gray600 = Color(0xFF6B7684);
  static const Color gray700 = Color(0xFF4E5968);
  static const Color gray800 = Color(0xFF333D4B);
  static const Color gray900 = Color(0xFF191F28);

  // ===========================================================================
  // 5. Surface & Backgrounds (배경 및 서피스)
  // ===========================================================================
  static const Color background = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF2F4F6);
  static const Color cardBackground = Colors.white;
  static const Color modalBackground = Colors.white;

  // ===========================================================================
  // 6. Text Tokens (텍스트 가독성 계층)
  // ===========================================================================
  static const Color textPrimary = Color(0xFF191F28); // 주요 제목, 본문
  static const Color textSecondary = Color(0xFF4E5968); // 보조 텍스트, 설명
  static const Color textTertiary = Color(0xFF8B95A1); // 캡션, 비활성 레이블
  static const Color textMuted = Color(0xFF8B95A1); // 레거시 호환
  static const Color textDisabled = Color(0xFFB0B8C1); // 비활성화 텍스트
  static const Color textInverse = Colors.white; // 다크/배경 위 텍스트
  static const Color textDark = Color(0xFF191F28); // 레거시 호환

  // ===========================================================================
  // 7. Borders & Dividers (경계선 및 구분선)
  // ===========================================================================
  static const Color border = Color(0xFFE5E8EB);
  static const Color borderLight = Color(0xFFF2F4F6);
  static const Color borderFocused = primary500;
  static const Color divider = Color(0xFFF2F4F6);

  // ===========================================================================
  // 8. Backward-Compatible Accents (기존 코드 100% 호환 및 업그레이드)
  // ===========================================================================
  static const Color accentBlue = Color(0xFF3182F6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color grey = Color(0xFF8B95A1);

  // ===========================================================================
  // 9. Gradients (그라디언트)
  // ===========================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9E43), Color(0xFFFF7A00)],
  );

  static const LinearGradient subtleCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFFF9F5)],
  );

  // ===========================================================================
  // 10. Shadows (그림자)
  // ===========================================================================
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x33FF8F21),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
}
