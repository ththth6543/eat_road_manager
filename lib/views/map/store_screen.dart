import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../core/constants/app_colors.dart';
import '../../models/store.dart';
import '../../viewmodels/store_map_viewmodel.dart';
import '../detailed_store/detailed_store_screen.dart';
import 'widgets/store_info_window.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final Completer<NaverMapController> _mapController = Completer();
  late final StoreMapViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StoreMapViewModel();
    _initData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _viewModel.initialize();
    if (!mounted) return;

    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${_viewModel.errorMessage}')),
      );
      return;
    }

    final controller = await _mapController.future;
    _updateMap(controller, _viewModel.groupedStores);
  }

  void _updateMap(
    NaverMapController controller,
    Map<String, List<Store>> allGroups,
  ) {
    if (_viewModel.currentPosition != null) {
      controller.updateCamera(
        NCameraUpdate.withParams(
          target: NLatLng(
            _viewModel.currentPosition!.latitude,
            _viewModel.currentPosition!.longitude,
          ),
          zoom: 15,
        ),
      );
    }

    controller.clearOverlays(type: NOverlayType.marker);
    final markers = <NMarker>{};

    allGroups.forEach((key, storesInGroup) {
      if (storesInGroup.isEmpty) return;
      final firstStore = storesInGroup.first;
      NMarker marker;

      if (storesInGroup.length >= 2) {
        marker = NMarker(
          id: key,
          size: const Size(30, 40),
          position: NLatLng(firstStore.latitude, firstStore.longitude),
          caption: NOverlayCaption(text: '${storesInGroup.length}개'),
        );
        marker.setOnTapListener(
          (_) => _handleClusterTap(storesInGroup, marker.position),
        );
      } else {
        marker = NMarker(
          id: firstStore.id.toString(),
          size: const Size(30, 40),
          position: NLatLng(firstStore.latitude, firstStore.longitude),
          caption: NOverlayCaption(text: firstStore.name),
        );
        marker.setOnTapListener(
          (_) => _viewModel.showDetailedScreen(firstStore.id),
        );
      }
      markers.add(marker);
    });

    controller.addOverlayAll(markers);
  }

  Future<void> _handleClusterTap(List<Store> stores, NLatLng position) async {
    final controller = await _mapController.future;
    final point = await controller.latLngToScreenLocation(position);
    _viewModel.showInfoWindow(
      stores,
      Offset(point.x.toDouble(), point.y.toDouble()),
      stores.first.bdMgtSn ?? stores.first.id.toString(),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Container(
      color: Colors.black.withAlpha(120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accentBlue),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 가게')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Stack(
            children: [
              NaverMap(
                options: const NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(37.5666102, 126.9783881),
                    zoom: 15,
                  ),
                  locationButtonEnable: true,
                ),
                onMapReady: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
                onMapTapped: (point, latLng) {
                  _viewModel.closeInfoWindow();
                  _viewModel.closeDetailedScreen();
                },
                onCameraChange: (reason, animated) =>
                    _viewModel.closeInfoWindow(),
              ),
              if (_viewModel.isLoading)
                _buildLoadingIndicator(_viewModel.message),

              // 말풍선 정보창
              if (_viewModel.selectedMarkerIdForInfoWindow != null &&
                  _viewModel.selectedStoresForInfoWindow != null &&
                  _viewModel.infoWindowOffset != null)
                StoreInfoWindow(
                  stores: _viewModel.selectedStoresForInfoWindow!,
                  offset: _viewModel.infoWindowOffset!,
                  onStoreSelected: (id) => _viewModel.showDetailedScreen(id),
                ),

              // 가게 상세 화면 (Draggable Sheet)
              if (_viewModel.selectedStoreIdForSheet != null)
                DetailedStoreScreen(
                  key: ValueKey(_viewModel.selectedStoreIdForSheet!),
                  storeId: _viewModel.selectedStoreIdForSheet!,
                  onClose: _viewModel.closeDetailedScreen,
                ),
            ],
          );
        },
      ),
    );
  }
}
