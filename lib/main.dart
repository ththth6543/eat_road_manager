import 'dart:async';

import 'package:eat_road_manager/create_store_marker.dart';
import 'package:flutter/material.dart';
import 'package:eat_road_manager/create_store/create_store_overview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'main_drawer.dart';
import 'store_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'create_store/create_store_others.dart';
import 'create_store/create_store_check_document.dart';
import 'test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //네이버 지도 사용을 위한 초기화
  await FlutterNaverMap().init(
    clientId: "vbjkz22vte",
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

  await Supabase.initialize(
    url: 'https://xvxyrdqnidcygepvnmjl.supabase.co',
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHlyZHFuaWRjeWdlcHZubWpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MDYzMjYsImV4cCI6MjA3MjQ4MjMyNn0.Sz8ZKu_oCrocfd6nRo9RNDtljpTKLwXmMvsNNZ3vj-s",
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 한글 및 기타 언어 설정을 위한 localizationsDelegates 추가
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원할 언어 설정 (여기서는 한국어와 영어)
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      // 앱의 기본 로케일을 한국어로 설정
      locale: const Locale('ko'),
      // streambuilder를 사용하여 인증 상태에 따라 첫 화면을 결정
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // 스트림에서 첫 데이터를 기다리는 동안 띄울 로딩화면
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.blueAccent,)),
            );
          }
          // 데이터가 있고 세션이 null이면 로그인 상태
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const MyHomePage();
          } else {
            // 로그아웃 상태일때 띄울 화면
            return const MyHomePage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isCreatingStore = false;

  Future<void> _navigateToCreateStore() async {
    if (_isCreatingStore) return;
    setState(() => _isCreatingStore = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('로그인 해주세요');

      final List<dynamic> drafts = await supabase
          .from('stores')
          .select('id')
          .eq('owner_id', userId)
          .eq('status', 'DRAFT');

      String storeId;
      if (drafts.isNotEmpty) {
        storeId = drafts.first['id'].toString();
      } else {
        final newData = await supabase
            .from('stores')
            .insert({'owner_id': userId, 'name': '임시 가게', 'status': 'DRAFT'})
            .select('id')
            .single();
        storeId = newData['id'].toString();
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateStoreOverview(storeId: storeId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류가 발생했습니다: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingStore = false);
      }
    }
  }

  // 파라미터를 받는 새로운 버튼 생성 헬퍼 메소드
  Widget _createButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("사장님용"),
      ),
      endDrawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 2x3 그리드 뷰 생성
        child: GridView.count(
          crossAxisCount: 2, // 2열
          crossAxisSpacing: 16, // 열 사이 간격
          mainAxisSpacing: 16, // 행 사이 간격
          children: <Widget>[
            _createButton(
              title: '가게 등록 / 수정',
              icon: Icons.add_business,
              color: Colors.blueAccent,
              onTap: _navigateToCreateStore,
            ),
            _createButton(
              title: '내 가게 목록',
              icon: Icons.store,
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StoreScreen()));
              },
            ),
            _createButton(
              title: '예약 관리',
              icon: Icons.calendar_today,
              color: Colors.green,
              onTap: () { /* TODO: 예약 관리 화면으로 이동 */ },
            ),
            _createButton(
              title: '리뷰 관리',
              icon: Icons.rate_review,
              color: Colors.purpleAccent,
              onTap: () { /* TODO: 리뷰 관리 화면으로 이동 */ },
            ),
            _createButton(
              title: 'others',
              icon: Icons.bar_chart,
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateStoreOthers(storeId: '20',)));
              },
            ),
            _createButton(
              title: '설정',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Test()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
