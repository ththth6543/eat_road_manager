import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../models/juso_address.dart';
import '../../viewmodels/create_store_marker_viewmodel.dart';
import 'create_store_marker_search_address_screen.dart';
import 'create_store_others_screen.dart';

class CreateStoreMarkerScreen extends StatefulWidget {
  final String storeId;

  const CreateStoreMarkerScreen({super.key, required this.storeId});

  @override
  State<CreateStoreMarkerScreen> createState() =>
      _CreateStoreMarkerScreenState();
}

class _CreateStoreMarkerScreenState extends State<CreateStoreMarkerScreen> {
  late final CreateStoreMarkerViewModel _viewModel;
  late NaverMapController _mapController;
  final Completer<NaverMapController> _controllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _viewModel = CreateStoreMarkerViewModel(storeId: widget.storeId);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAddressSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchView()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final juso = JusoAddress.fromJson(result);
      final success = await _viewModel.selectAddress(juso);

      if (success && _viewModel.initialCoordinates != null) {
        final coords = _viewModel.initialCoordinates!;
        _mapController.clearOverlays();
        _mapController.addOverlay(
          NMarker(
            id: 'initial',
            position: coords,
            caption: NOverlayCaption(text: _viewModel.storeName),
          ),
        );
        _mapController.updateCamera(
          NCameraUpdate.withParams(target: coords, zoom: 16),
        );
      } else if (_viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
      }
    }
  }

  Future<void> _confirmFineTunedLocation() async {
    final cameraPosition = await _mapController.getCameraPosition();
    final center = cameraPosition.target;
    _viewModel.updateFineTuningCoordinates(center);
    _viewModel.confirmPosition();

    _mapController.clearOverlays();
    _mapController.addOverlay(
      NMarker(
        id: 'final',
        position: center,
        caption: NOverlayCaption(text: _viewModel.storeName),
      ),
    );
  }

  Future<void> _saveLocation() async {
    final success = await _viewModel.saveStoreLocation();
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateStoreOthersScreen(storeId: widget.storeId),
        ),
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_viewModel.errorMessage!)));
    }
  }

  Widget _buildStepUI() {
    switch (_viewModel.step) {
      case MarkerCreationStep.initial:
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('주소 검색으로 시작하기', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            onPressed: _openAddressSearch,
          ),
        );
      case MarkerCreationStep.fineTuning:
        return Stack(
          children: [
            const Center(child: Icon(Icons.add, size: 30, color: Colors.black)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withAlpha(150),
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                  '지도를 움직여 마커를 정확한 위치에 맞추고, 아래 버튼을 눌러주세요.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _confirmFineTunedLocation,
                child: const Text('이 위치로 확정'),
              ),
            ),
          ],
        );
      case MarkerCreationStep.confirmed:
        final roadAddress = _viewModel.selectedAddress?.roadAddr ?? '주소 정보 없음';
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roadAddress,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '위도: ${_viewModel.finalCoordinates?.latitude.toStringAsFixed(5)}',
                  ),
                  Text(
                    '경도: ${_viewModel.finalCoordinates?.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _viewModel.isLoading ? null : _saveLocation,
                    child: _viewModel.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('가게 위치 저장 후 다음 단계로'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('가게 위치 등록'),
            leading: _viewModel.step != MarkerCreationStep.initial
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_viewModel.step == MarkerCreationStep.confirmed) {
                        _viewModel.updateFineTuningCoordinates(
                          _viewModel.finalCoordinates ??
                              const NLatLng(37.5665, 126.9780),
                        );
                      } else if (_viewModel.step ==
                          MarkerCreationStep.fineTuning) {
                        _viewModel.resetToSearch();
                        _mapController.clearOverlays();
                      }
                    },
                  )
                : null,
          ),
          body: Stack(
            children: [
              NaverMap(
                options: const NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(37.5665, 126.9780),
                    zoom: 12,
                  ),
                  locationButtonEnable: true,
                ),
                onMapReady: (controller) {
                  _mapController = controller;
                  if (!_controllerCompleter.isCompleted) {
                    _controllerCompleter.complete(controller);
                  }
                },
              ),
              _buildStepUI(),
            ],
          ),
        );
      },
    );
  }
}

// Backward compatibility alias
typedef CreateStoreMarker = CreateStoreMarkerScreen;
