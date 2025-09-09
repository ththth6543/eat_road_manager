import 'dart:async';

import 'package:eat_road_manager/create_store_marker.dart';
import 'package:flutter/material.dart';
import 'package:eat_road_manager/create_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'main_drawer.dart';
import 'store_screen.dart';

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
      home: MaterialApp(
        // streambuilder를 사용하여 인증 상태에 따라 첫 화면을 결정
        home: StreamBuilder<AuthState>(
          stream: supabase.auth.onAuthStateChange,
          builder: (context, snapshot) {
            // 스트림에서 첫 데이터를 기다리는 동안 띄울 로딩화면
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("사장님 용"),
      ),
      endDrawer: MainDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateMenu()),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.amber,
                child: Text("가게 생성"),
              ),
            ),
            SizedBox(height: 20),
            //지도
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateStoreMarker()),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.green,
                child: Text("가게 마커"),
              ),
            ),
            SizedBox(height: 20),
            //지도
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoreScreen()),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blueAccent,
                child: Text("가게 마커"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
