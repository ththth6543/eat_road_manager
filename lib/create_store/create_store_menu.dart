import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eat_road_manager/create_store/create_store_marker.dart';

final supabase = Supabase.instance.client;

//하나의 메뉴 항목을 관리하는 데이터 클래스
class MenuViewModel {
  //db에 저장된 메뉴의 고유 id(새 메뉴는 null)
  String? dbId;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  //사용자가 새로 선택한 이미지 파일
  XFile? newImageFile;

  // DB에 이미 저장된 이미지 url
  String? existingImageUrl;

  MenuViewModel({
    this.dbId,
    String? name,
    int? price,
    String? description,
    this.existingImageUrl,
  }) {
    nameController.text = name ?? '';
    priceController.text = price?.toString() ?? '';
    descriptionController.text = description ?? '';
  }

  // 이 메뉴가 DB에 이미 존재하는지 여부
  bool get isPersisted => dbId != null;

  // 화면에 표시할 이미지 (새 파일 > 기존 URL)
  ImageProvider? get image {
    if (newImageFile != null) return FileImage(File(newImageFile!.path));
    if (existingImageUrl != null) return NetworkImage(existingImageUrl!);
    return null;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}

class CreateStoreMenu extends StatefulWidget {
  //가게의 ID를 이전 화면에서 전달 받기
  final String storeId;

  const CreateStoreMenu({super.key, required this.storeId});

  @override
  State<CreateStoreMenu> createState() => _CreateStoreMenuState();
}

class _CreateStoreMenuState extends State<CreateStoreMenu>
    with WidgetsBindingObserver {
  final _imagePicker = ImagePicker();
  List<MenuViewModel> _menuItems = [];

  // 초기 데이터 로딩 상태 - 기존에 작성하던 것이 있을 경우 가져 올 때
  bool _isLoading = true;
  bool _isSaving = false;

  // 키보드 가시성 상태 변수
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    //리스너 등록
    WidgetsBinding.instance.addObserver(this);
    _loadExistingMenus();
  }

  @override
  void dispose() {
    //리스너 할당 해제
    WidgetsBinding.instance.removeObserver(this);
    // 모든 컨트롤러의 리소스 할당 해제
    for (var item in _menuItems) {
      item.dispose();
    }
    super.dispose();
  }

  //키보드 상태 변경 감지 함수
  @override
  void didChangeMetrics() {
    final bottomInsets = View.of(context).viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInsets > 0;
    });
  }

  //DB에서 기존 메뉴들을 불러와 화면에 불러옴
  Future<void> _loadExistingMenus() async {
    try {
      final List<dynamic> data = await supabase
          .from('menus')
          .select('*')
          .eq('store_id', widget.storeId);

      // 기존에 작성하던 메뉴가 있다
      if (data.isNotEmpty) {
        _menuItems = data
            .map(
              (itemData) => MenuViewModel(
                dbId: itemData['id'].toString(),
                name: itemData['name'],
                price: itemData['price'],
                description: itemData['description'],
                existingImageUrl: itemData['image_url'],
              ),
            )
            .toList();
      } else {
        // 기존에 작성하던 메뉴가 없다
        _addMenuItem();
      }
    } catch (e) {
      debugPrint('메뉴를 불러오는 데 오류가 발생했습니다: $e');
      // 메뉴 불러오는데 오류가 발생하면 그냥 빈 양식으로 시작
      _addMenuItem();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 메뉴 목록에 새로운 빈 양식을 추가
  void _addMenuItem() {
    setState(() {
      _menuItems.add(MenuViewModel());
    });
  }

  // 특정 인덱스의 메뉴 양식을 목록에서 제거
  void _removeMenuItem(int index) {
    // 제거하기 전에 컨트롤러를 할당 해제하여 메모리 누수 방지
    _menuItems[index].dispose();
    setState(() {
      _menuItems.removeAt(index);
    });
  }

  // 특정 메뉴 항목에 대한 이미지 선택기를 열기
  Future<void> _pickImage(int index) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _menuItems[index].newImageFile = pickedFile;
      });
    }
  }

  // 메뉴가 수정되었는지 확인하는 헬퍼 함수
  bool _isMenuModified(MenuViewModel item, Map<String, dynamic> oldItem) {
    return item.newImageFile != null ||
        item.nameController.text != oldItem['name'] ||
        (int.tryParse(item.priceController.text) ?? 0) != oldItem['price'] ||
        item.descriptionController.text != oldItem['description'];
  }

  // DB에 저장할 레코드(Map)를 준비하는 헬퍼 함수
  Future<Map<String, dynamic>> _prepareRecord(
    MenuViewModel item,
    String userId, {
    bool isUpdate = false,
  }) async {
    String? imageUrl = item.existingImageUrl;
    if (item.newImageFile != null) {
      final file = File(item.newImageFile!.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${item.newImageFile!.name}';
      final folderPath = 'menu_images/$userId/${widget.storeId}';
      final filePath = '$folderPath/$fileName';
      await supabase.storage.from('menus').upload(filePath, file);
      imageUrl = supabase.storage.from('menus').getPublicUrl(filePath);
    }

    final record = {
      'store_id': widget.storeId,
      'user_id': userId,
      'name': item.nameController.text,
      'price': int.tryParse(item.priceController.text) ?? 0,
      'description': item.descriptionController.text,
      'image_url': imageUrl,
    };
    if (isUpdate) record['id'] = item.dbId;
    return record;
  }

  //"델타 업데이트" 방식으로 메뉴를 저장
  Future<void> _saveAllMenus() async {
    print('Saving menus for store ID: ${widget.storeId}');
    setState(() {
      _isSaving = true;
    });
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 상태가 아닙니다.')));
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      // 1. DB의 원본 메뉴 목록 가져오기
      final List<dynamic> oldMenusData = await supabase
          .from('menus')
          .select('id, name, price, description, image_url')
          .eq('store_id', widget.storeId);

      final oldMenusMap = {for (var v in oldMenusData) v['id'].toString(): v};
      final newMenusMap = {for (var v in _menuItems) v.dbId: v};

      // 2. 삭제/수정/추가할 그룹 분류
      final List<String> idsToDelete = [];
      final List<Map<String, dynamic>> recordsToUpdate = [];
      final List<Map<String, dynamic>> recordsToInsert = [];
      final List<String> storageFilesToDelete = [];

      // 삭제된 메뉴 찾기
      for (final oldId in oldMenusMap.keys) {
        if (!newMenusMap.containsKey(oldId)) {
          idsToDelete.add(oldId);
          final oldImageUrl = oldMenusMap[oldId]['image_url'];
          if (oldImageUrl != null) storageFilesToDelete.add(oldImageUrl);
        }
      }

      // 기존 메뉴들 처리 (이미지 교체 확인을 먼저 수행)
      for (final item in _menuItems) {
        // 새로 추가된 메뉴
        if (!item.isPersisted) {
          recordsToInsert.add(await _prepareRecord(item, userId));
        }
        // 기존 메뉴 처리
        else {
          final oldItem = oldMenusMap[item.dbId];
          if (oldItem != null) {
            // 이미지가 교체되었는지 먼저 확인하고 기존 이미지 삭제 목록에 추가
            if (item.newImageFile != null) {
              final oldImageUrl = oldItem['image_url'];
              if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
                storageFilesToDelete.add(oldImageUrl);
              }
            }

            // 메뉴가 수정되었는지 확인하여 업데이트 목록에 추가
            if (_isMenuModified(item, oldItem)) {
              recordsToUpdate.add(
                await _prepareRecord(item, userId, isUpdate: true),
              );
            }
          }
        }
      }

      // 3. 분류된 작업 실행
      if (idsToDelete.isNotEmpty) {
        await supabase.from('menus').delete().inFilter('id', idsToDelete);
      }
      if (recordsToUpdate.isNotEmpty) {
        await supabase.from('menus').upsert(recordsToUpdate);
      }

      if (recordsToInsert.isNotEmpty) {
        await supabase.from('menus').insert(recordsToInsert);
      }

      // 스토리지 파일 삭제
      if (storageFilesToDelete.isNotEmpty) {
        final filePaths = storageFilesToDelete
            .map((url) => _extractFilePathFromUrl(url, userId, widget.storeId))
            .nonNulls
            .toList();

        if (filePaths.isNotEmpty) {
          try {
            debugPrint('삭제할 파일 경로들: $filePaths');
            await supabase.storage.from('menus').remove(filePaths);
            debugPrint('사용하지 않는 파일 삭제 완료: $filePaths');
          } catch (e) {
            debugPrint('파일 삭제 실패: $e');
            // 개별 파일 삭제 시도
            for (final filePath in filePaths) {
              try {
                await supabase.storage.from('menus').remove([filePath]);
                debugPrint('개별 파일 삭제 성공: $filePath');
              } catch (individualError) {
                debugPrint('개별 파일 삭제 실패: $filePath, 오류: $individualError');
              }
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('성공적으로 저장되었습니다!')));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateStoreMarker(storeId: widget.storeId),
          ),
        );
      }
    } catch (e) {
      debugPrint('메뉴 저장 시 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Supabase Storage URL에서 파일 경로 추출하는 헬퍼 함수
  String? _extractFilePathFromUrl(String url, String userId, String storeId) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Method 1: Standard Supabase URL structure
      // URL 형태: https://project.supabase.co/storage/v1/object/public/menus/menu_images/userId/storeId/filename
      final publicIndex = pathSegments.indexOf('public');
      final menusIndex = pathSegments.indexOf('menus');

      if (publicIndex != -1 && menusIndex != -1 && menusIndex == publicIndex + 1) {
        // public/menus/ 다음부터가 실제 파일 경로 (menu_images/ 포함)
        if (menusIndex + 1 < pathSegments.length) {
          return pathSegments.sublist(menusIndex + 1).join('/');
        }
      }

      // Method 2: Look for menu_images in path
      final menuImagesIndex = pathSegments.indexWhere((segment) => segment == 'menu_images');
      if (menuImagesIndex != -1) {
        // menu_images부터 전체 경로 사용 (기존 업로드 구조와 일치)
        return pathSegments.sublist(menuImagesIndex).join('/');
      }

      // Method 3: Extract filename and reconstruct path (기존 구조 유지)
      final fileName = pathSegments.last;
      if (fileName.isNotEmpty && fileName.contains('_')) {
        // 기존 업로드 구조와 동일하게 재구성
        return 'menu_images/$userId/$storeId/$fileName';
      }

      return null;
    } catch (e) {
      debugPrint('URL 파싱 실패: $url, 오류: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset은 true로 유지합니다.
      appBar: AppBar(title: const Text('메뉴 생성')),
      body: Stack(
        children: [
          // 스크롤 가능한 메뉴 목록
          ListView.builder(
            // 키보드가 보일 때는 하단 패딩을 없애고, 보이지 않을 때는 버튼 높이만큼 패딩을 줍니다.
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              _isKeyboardVisible ? 16 : 100,
            ),
            itemCount: _menuItems.length + 1,
            itemBuilder: (context, index) {
              if (index == _menuItems.length) {
                return Center(
                  child: TextButton.icon(
                    onPressed: _addMenuItem,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('메뉴 추가하기'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                );
              }

              // 기존 메뉴 아이템 카드 렌더링
              final menuItem = _menuItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... (메뉴 카드 UI는 이전과 동일)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(index),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Builder(
                                builder: (context) {
                                  if (menuItem.newImageFile != null) {
                                    return Image.file(
                                      File(menuItem.newImageFile!.path),
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  if (menuItem.existingImageUrl != null) {
                                    return Image.network(
                                      menuItem.existingImageUrl!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.black54,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: menuItem.nameController,
                                  decoration: const InputDecoration(
                                    labelText: '메뉴이름',
                                  ),
                                ),
                                TextFormField(
                                  controller: menuItem.priceController,
                                  decoration: const InputDecoration(
                                    labelText: '메뉴가격',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: menuItem.descriptionController,
                        decoration: const InputDecoration(
                          labelText: '메뉴 설명(선택사항)',
                        ),
                        maxLines: 5,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeMenuItem(index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 키보드가 보이지 않을 때만 하단 버튼을 렌더링합니다.
          if (!_isKeyboardVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAllMenus,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('전체 메뉴 저장 후 다음 단계로'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
