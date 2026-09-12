import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_client.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 환경변수 로드
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env 파일 로드 실패 또는 누락: $e");
  }

  // 네이버 지도 초기화
  await FlutterNaverMap().init(
    clientId: ApiConstants.naverMapClientId,
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          debugPrint("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAuthFailedException():
          debugPrint("인증 실패: $ex");
          break;
      }
    },
  );

  // Supabase 초기화
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '잇로드 매니저',
      theme: AppTheme.lightTheme,
      // 한글 및 기타 언어 설정을 위한 localizationsDelegates 추가
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원할 언어 설정
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      locale: const Locale('ko'),
      // 인증 상태 스트림에 따른 초기 화면
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accentBlue),
              ),
            );
          }
          return const HomeScreen();
        },
      ),
      onGenerateRoute: (settings) {
        // Supabase OAuth 로그인 콜백 (예: /?code=...) 및 딥링크 처리
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      },
    );
  }
}
