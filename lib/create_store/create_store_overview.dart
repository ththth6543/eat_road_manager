import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'create_store_menu.dart';
import 'package:image_picker/image_picker.dart';

final supabase = Supabase.instance.client;

class CreateStoreOverview extends StatefulWidget {
  final String storeId;

  const CreateStoreOverview({super.key, required this.storeId});

  @override
  _CreateStoreOverviewState createState() => _CreateStoreOverviewState();
}

class _CreateStoreOverviewState extends State<CreateStoreOverview> {
  String? _storeId;
  List<String> _imageUrls = [];
  final _imagePicker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;
  bool _isLoading = true;

  //삭제 중인 이미지의 인덱스를 저장
  int? _deletingIndex;

  @override
  void initState() {
    super.initState();
    // 화면이 시작될 때 기존에 업로드 해둔 데이터를 로드
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      _storeId = widget.storeId;
      // stores 테이블에 해당 id의 스토어 데이터를 가져옴
      final data = await supabase
          .from('stores')
          .select('description, image_urls')
          .eq('id', widget.storeId)
          .single();

      if (data['description'] != null) {
        _descriptionController.text = data['description'];
      }
      if (data['image_urls'] != null) {
        _imageUrls = List<String>.from(data['image_urls']);
      }
    } catch (e) {
      debugPrint('새로운 가게 생성 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('가게 생성에 실패했습니다: $e')));
        Navigator.of(context).pop();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //등록된 이미지를 삭제 하는 함수(이미지 우측상단의 'X' 버튼을 눌렀을 때)
  Future<void> _deleteImage(int index, String imageUrl) async {
    setState(() {
      _deletingIndex = index;
    });

    try {
      //전체 url에서 파일 경로 추출
      final uri = Uri.parse(imageUrl);
      final filePath = uri.pathSegments
          .sublist(uri.pathSegments.indexOf('stores') + 1)
          .join('/');

      //스토리지에서 파일 삭제
      await supabase.storage.from('stores').remove([filePath]);

      setState(() {
        _imageUrls.removeAt(index);
      });

      await supabase
          .from('stores')
          .update({'image_urls': _imageUrls})
          .eq('id', widget.storeId);
    } catch (e) {
      debugPrint('이미지 삭제 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 삭제에 실패했습니다: $e')));
      }
    } finally {
      setState(() {
        _deletingIndex = null;
      });
    }
  }

  // 갤러리에서 여러 이미지를 선택하고 중복되지 않는 파일만 업로드
  Future<void> _pickImages() async {
    final userId = supabase.auth.currentUser?.id;
    // 로그인이 되어 있지 않으면 실행 안함
    if (userId == null) return;

    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        //이미지 너비와 품질을 지정하여 용량을 관리
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty) return;

      setState(() {
        _isUploading = true;
      });

      // 선택된 각 이미지를 순차적으로 업로드하고 URL 목록에 추가
      for (final file in pickedFiles) {
        final fileName = file.name;
        final folderPath = '$userId/${widget.storeId}';
        final filePath = '$folderPath/$fileName';
        
        try {
          final uploadFile = File(file.path);
          await supabase.storage.from('stores').upload(filePath, uploadFile);

          // 업로드 성공시, 중복되는 파일이 없으면 URL을 가져와 목록에 추가
          final imageUrl = supabase.storage.from('stores').getPublicUrl(filePath);
          setState(() {
            _imageUrls.add(imageUrl);
          });
        } on StorageException catch (e) {
          // 409에러면 중복된 파일이 이미 존재, 정상처리하고 무시
          if (e.statusCode == '409') {
            debugPrint('$fileName이 이미 존재합니다.');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$fileName이 이미 존재합니다.')),
              );
            }
          } else { //다른 에러는 아래 catch에서 해결
            rethrow;
          }
        }
      }
    } catch (e) {
      debugPrint('이미지를 피킹 또는 업로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 처리 중 오류 발생: $e')));
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // 현재 입력된 가게 소개와 이미지 url 목록을 DB에 저장(UPDATE)
  Future<void> _saveAndContinue() async {
    if (_storeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase
          .from('stores')
          .update({
            'description': _descriptionController.text,
            'image_urls': _imageUrls,
          })
          .eq('id', _storeId!);

      // 다음 단계 화면으로 이동 (생성된 _storeId를 전달)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateStoreMenu()),
        );
      }
    } catch (e) {
      debugPrint('가게 정보 저장 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // DB 테이블에 올려보기
  Future<void> uploadMenu(String introduction, String userID) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('menu').insert({
        'userID': userID,
        'introduction': introduction,
      });

      print("✅ 메뉴 업로드 성공: $response");
    } catch (e) {
      print("❌ 메뉴 업로드 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가게 소개 및 사진')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(semanticsLabel: '가게 생성 중...'),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '가게 소개',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          hintText: '가게에 대한 간단한 소개 부탁 드립니다!',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '인테리어, 내부 전경',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _imageUrls.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _imageUrls.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                color: Colors.grey[300],
                                child: _isUploading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : const Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.black54,
                                      ),
                              ),
                            );
                          }
                          final imageUrl = _imageUrls[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _deleteImage(index, imageUrl),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              if (_deletingIndex == index)
                                Container(
                                  color: Colors.black.withAlpha(130),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 16),
                    child: ElevatedButton(
                      onPressed: (_storeId == null || _isLoading)
                          ? null
                          : _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('저장 후 계속하기', style: TextStyle(color: Colors.blueAccent),),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
