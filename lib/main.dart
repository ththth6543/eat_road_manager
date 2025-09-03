import 'package:eat_road_manager/create_store_marker.dart';
import 'package:flutter/material.dart';
import 'package:eat_road_manager/create_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
    }
  );

  await Supabase.initialize(
    url: 'https://xvxyrdqnidcygepvnmjl.supabase.co',
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eHlyZHFuaWRjeWdlcHZubWpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MDYzMjYsImV4cCI6MjA3MjQ4MjMyNn0.Sz8ZKu_oCrocfd6nRo9RNDtljpTKLwXmMvsNNZ3vj-s",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateMenu()));
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.amber,
                child: Text("가게 생성"),
              ),
            ),
            SizedBox(height: 20,),
            //지도
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateStoreMarker()));
              },
              child: Container(
                width: 200,
                height: 200,
                color: Colors.green,
                child: Text("가게 마커"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
