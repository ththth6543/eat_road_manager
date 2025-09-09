import 'package:flutter/material.dart';
import 'login/login_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    final currentUser = supabase.auth.currentUser;
    final name = currentUser?.userMetadata?['full_name'] ?? '사용자';
    final email = currentUser?.email ?? '로그인 필요';
    final avatarUrl = currentUser?.userMetadata?['avatar_url'];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (currentUser != null)
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (avatarUrl != null)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            )
          else
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "로그인이 필요합니다.",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text('가게 관리'),
            onTap: () {
              // 추후 구현
            },
          ),
          const Divider(),

          // 로그인 상태에 따라 '로그인' 또는 '로그아웃'으로 변경
          if (currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  setState(() {});
                }
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('로그인'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MainLoginScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
