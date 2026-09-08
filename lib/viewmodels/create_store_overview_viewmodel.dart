import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/store_repository.dart';

class CreateStoreOverviewViewModel extends ChangeNotifier {
  final String storeId;
  final StoreRepository _storeRepository;
  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();

  String _storeName = '';
  String _description = '';
  List<String> _imageUrls = [];

  bool _isLoading = true;
  bool _isUploading = false;
  int? _deletingIndex;
  String? _errorMessage;

  CreateStoreOverviewViewModel({
    required this.storeId,
    StoreRepository? storeRepository,
    AuthRepository? authRepository,
  })  : _storeRepository = storeRepository ?? StoreRepository(),
        _authRepository = authRepository ?? AuthRepository();

  String get storeName => _storeName;
  String get description => _description;
  List<String> get imageUrls => List.unmodifiable(_imageUrls);
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  int? get deletingIndex => _deletingIndex;
  String? get errorMessage => _errorMessage;

  Future<void> loadStoreData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _storeRepository.getStoreOverview(storeId);
      _description = data['description'] ?? '';
      _storeName = data['name'] ?? '';
      if (data['image_urls'] != null) {
        _imageUrls = List<String>.from(data['image_urls']);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '가게 정보를 가져오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(int index, String imageUrl) async {
    _deletingIndex = index;
    notifyListeners();

    try {
      final filePath = StorageService.extractFilePathFromUrl(imageUrl, 'stores');
      if (filePath != null) {
        await StorageService.removeFiles(bucket: 'stores', filePaths: [filePath]);
      }

      _imageUrls.removeAt(index);
      await _storeRepository.updateStoreOverview(
        storeId: storeId,
        name: _storeName,
        description: _description,
        imageUrls: _imageUrls,
      );
    } catch (e) {
      _errorMessage = '이미지 삭제에 실패했습니다: $e';
    } finally {
      _deletingIndex = null;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImages() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      _errorMessage = '로그인이 필요합니다.';
      notifyListeners();
      return;
    }

    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty) return;

      _isUploading = true;
      notifyListeners();

      for (final file in pickedFiles) {
        final fileName = file.name;
        final filePath = '$userId/$storeId/$fileName';

        try {
          final uploadFile = File(file.path);
          final imageUrl = await StorageService.uploadFile(
            bucket: 'stores',
            filePath: filePath,
            file: uploadFile,
          );
          if (!_imageUrls.contains(imageUrl)) {
            _imageUrls.add(imageUrl);
          }
        } catch (e) {
          debugPrint('이미지 업로드 오류: $e');
        }
      }
    } catch (e) {
      _errorMessage = '이미지 처리 중 오류 발생: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> saveStoreOverview(String name, String description) async {
    _storeName = name;
    _description = description;
    _isLoading = true;
    notifyListeners();

    try {
      await _storeRepository.updateStoreOverview(
        storeId: storeId,
        name: _storeName,
        description: _description,
        imageUrls: _imageUrls,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '저장 실패: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
