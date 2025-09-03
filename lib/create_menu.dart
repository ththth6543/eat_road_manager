import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart'; // 파일명 가져오기 위해 필요
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateMenu extends StatefulWidget {
  const CreateMenu({super.key});

  @override
  _CreateMenuState createState() => _CreateMenuState();
}

class _CreateMenuState extends State<CreateMenu> {
  final List<File> _images = [];
  final List<String> _imageNames = [];
  final TextEditingController controller = TextEditingController();

  //임시 유저아이디
  final String userID = '5039cd19-96ec-41b9-9bd1-5d69d2d671f1';

  // 갤러리에서 이미지 가져오기
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
        _imageNames.addAll(pickedFiles.map((file) => basename(file.path)));
      });
    }
  }

  //이미지 업로드
  Future<void> _uploadImages(String bucketName) async {
    final storage = Supabase.instance.client.storage;
    var bucket = bucketName;

    for (var i = 0; i < _images.length; i++) {
      try {
        final file = _images[i];
        final fileName = _imageNames[i];

        final filePath = 'ownerID/$fileName';
        await storage.from(bucket).upload(filePath, file);
        final fileUrl = await storage.from(bucket).getPublicUrl(filePath);
        print("Upload successful: $fileName");
        print("File URL: $fileUrl");
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // 이미지 지우기
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _imageNames.removeAt(index);
    });
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
        appBar: AppBar(title: Text("메뉴 생성")),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("소개", style: TextStyle(fontSize: 20)),
              ),
              // 소개 적는 곳
              Container(
                width: double.infinity,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12, width: 2),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none, // 기본 테두리 제거
                    hintText: "가게에 대한 간단한 소개 부탁 드립니다!", // 플레이스홀더 텍스트
                  ),
                  style: TextStyle(fontSize: 16), // 텍스트 크기 조절
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("인테리어, 내부 전경", style: TextStyle(fontSize: 20)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageListWidget(
                      images: _images,
                      imageNames: _imageNames,
                      onRemove: _removeImage,
                    ),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_circle_outline,
                            color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            fixedSize: Size(200, 45),
                            foregroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          //업로드
                          _uploadImages('interior');
                          uploadMenu(controller.text, userID);
                        },
                        child: Text("계속하기"))),
              ),
            ],
          ),
        ));
  }
}

//이미지 보여주는 위젯
class ImageListWidget extends StatelessWidget {
  final List<File> images;
  final List<String> imageNames;
  final Function(int) onRemove;

  const ImageListWidget({
    super.key,
    required this.images,
    required this.imageNames,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(images.length, (index) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0, right: 5),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    width: 100,
                    height: 100,
                    child: Image.file(
                      images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    imageNames[index].length > 15
                        ? '${imageNames[index].substring(0, 15)}...'
                        : imageNames[index],
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 95,
              top: 0,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: cancelIcon(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget cancelIcon() {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 2, left: 2),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        width: 20,
        height: 20,
      ),
      Icon(Icons.cancel, color: Colors.red),
    ],
  );
}
