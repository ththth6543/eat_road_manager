import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/auth_repository.dart';
import '../repositories/menu_repository.dart';

class MenuFormItem {
  String? dbId;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  XFile? newImageFile;
  String? existingImageUrl;

  MenuFormItem({
    this.dbId,
    String? name,
    int? price,
    String? description,
    this.existingImageUrl,
  }) : nameController = TextEditingController(text: name ?? ''),
       priceController = TextEditingController(text: price?.toString() ?? ''),
       descriptionController = TextEditingController(text: description ?? '');

  bool get isPersisted => dbId != null;

  ImageProvider? get imageProvider {
    if (newImageFile != null) return FileImage(File(newImageFile!.path));
    if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      return NetworkImage(existingImageUrl!);
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}

class CreateStoreMenuViewModel extends ChangeNotifier {
  final String storeId;
  final MenuRepository _menuRepository;
  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();

  List<MenuFormItem> _menuItems = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  CreateStoreMenuViewModel({
    required this.storeId,
    MenuRepository? menuRepository,
    AuthRepository? authRepository,
  }) : _menuRepository = menuRepository ?? MenuRepository(),
       _authRepository = authRepository ?? AuthRepository();

  List<MenuFormItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadExistingMenus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final menus = await _menuRepository.fetchMenusByStoreId(storeId);
      if (menus.isNotEmpty) {
        _menuItems = menus.map((m) {
          return MenuFormItem(
            dbId: m.id,
            name: m.name,
            price: m.price,
            description: m.description,
            existingImageUrl: m.imageUrl,
          );
        }).toList();
      } else {
        _menuItems = [MenuFormItem()];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('메뉴 로드 오류: $e');
      _menuItems = [MenuFormItem()];
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMenuItem() {
    _menuItems.add(MenuFormItem());
    notifyListeners();
  }

  void removeMenuItem(int index) {
    if (index >= 0 && index < _menuItems.length) {
      _menuItems[index].dispose();
      _menuItems.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> pickImage(int index) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null && index >= 0 && index < _menuItems.length) {
      _menuItems[index].newImageFile = pickedFile;
      notifyListeners();
    }
  }

  Future<bool> saveAllMenus() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      _errorMessage = '로그인 상태가 아닙니다.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingMenus = await _menuRepository.fetchMenusByStoreId(storeId);
      final oldMenusMap = {for (var v in existingMenus) v.id: v};
      final newMenusMap = {for (var v in _menuItems) v.dbId: v};

      final List<String> idsToDelete = [];
      final List<String> storageFilesToDelete = [];

      for (final oldId in oldMenusMap.keys) {
        if (oldId != null && !newMenusMap.containsKey(oldId)) {
          idsToDelete.add(oldId);
          final oldImageUrl = oldMenusMap[oldId]?.imageUrl;
          if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
            storageFilesToDelete.add(oldImageUrl);
          }
        }
      }

      final List<Map<String, dynamic>> recordsToInsert = [];
      final List<Map<String, dynamic>> recordsToUpdate = [];

      for (final item in _menuItems) {
        String? imageUrl = item.existingImageUrl;
        if (item.newImageFile != null) {
          imageUrl = await _menuRepository.uploadMenuImage(
            userId: userId,
            storeId: storeId,
            file: File(item.newImageFile!.path),
            fileName: item.newImageFile!.name,
          );
        }

        final record = {
          'store_id': storeId,
          'user_id': userId,
          'name': item.nameController.text,
          'price': int.tryParse(item.priceController.text) ?? 0,
          'description': item.descriptionController.text,
          'image_url': imageUrl,
        };

        if (!item.isPersisted) {
          recordsToInsert.add(record);
        } else {
          final oldItem = oldMenusMap[item.dbId];
          if (oldItem != null) {
            if (item.newImageFile != null &&
                oldItem.imageUrl != null &&
                oldItem.imageUrl!.isNotEmpty) {
              storageFilesToDelete.add(oldItem.imageUrl!);
            }
            record['id'] = item.dbId;
            recordsToUpdate.add(record);
          }
        }
      }

      if (idsToDelete.isNotEmpty) {
        await _menuRepository.deleteMenus(idsToDelete);
      }
      if (recordsToUpdate.isNotEmpty) {
        await _menuRepository.upsertMenus(recordsToUpdate);
      }
      if (recordsToInsert.isNotEmpty) {
        await _menuRepository.insertMenus(recordsToInsert);
      }
      if (storageFilesToDelete.isNotEmpty) {
        await _menuRepository.deleteMenuImages(storageFilesToDelete);
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '메뉴 저장 중 오류 발생: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    for (var item in _menuItems) {
      item.dispose();
    }
    super.dispose();
  }
}
