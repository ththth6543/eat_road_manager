import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../create_store/business_license_screen.dart';
import '../create_store/business_registration_screen.dart';
import '../create_store/create_store_others_screen.dart';
import '../create_store/create_store_overview_screen.dart';
import '../map/store_screen.dart';
import 'widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleNavigateToCreateStore() async {
    final storeId = await _viewModel.getOrCreateDraftStore();
    if (!mounted) return;

    if (storeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateStoreOverviewScreen(storeId: storeId),
        ),
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${_viewModel.errorMessage}')),
      );
    }
  }

  Widget _createButton({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(100),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withAlpha(220),
                ),
              ),
            ],
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
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05,
                  children: <Widget>[
                    _createButton(
                      title: '가게 등록 / 수정',
                      subtitle: '소개 · 메뉴 · 위치 등록',
                      icon: Icons.add_business,
                      color: AppColors.accentBlue,
                      onTap: _handleNavigateToCreateStore,
                    ),
                    _createButton(
                      title: '주변 가게 지도',
                      subtitle: '내 주변 가게 마커 확인',
                      icon: Icons.map_outlined,
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StoreScreen(),
                          ),
                        );
                      },
                    ),
                    _createButton(
                      title: '영업 허가증 인증',
                      subtitle: '식품안전나라 인허가 조회',
                      icon: Icons.verified_outlined,
                      color: AppColors.accentGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BusinessLicenseScreen(),
                          ),
                        );
                      },
                    ),
                    _createButton(
                      title: '사업자등록 인증',
                      subtitle: '국세청 사업자 진위 확인',
                      icon: Icons.badge_outlined,
                      color: AppColors.accentPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BusinessRegistrationScreen(),
                          ),
                        );
                      },
                    ),
                    _createButton(
                      title: '영업 및 편의 정보',
                      subtitle: '영업시간 · 편의시설 관리',
                      icon: Icons.access_time_filled,
                      color: AppColors.accentRed,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateStoreOthersScreen(storeId: '20'),
                          ),
                        );
                      },
                    ),
                    _createButton(
                      title: '설정',
                      subtitle: '앱 환경설정 및 관리',
                      icon: Icons.settings,
                      color: AppColors.grey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('설정 기능 준비 중입니다.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (_viewModel.isCreatingStore)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Backward compatibility alias
typedef MyHomePage = HomeScreen;
