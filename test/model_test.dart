import 'package:flutter_test/flutter_test.dart';
import 'package:eat_road_manager/models/store.dart';
import 'package:eat_road_manager/models/menu_item.dart';
import 'package:eat_road_manager/models/juso_address.dart';

void main() {
  group('MVVM Model Tests', () {
    test('Store model fromMap and toMap', () {
      final map = {
        'id': 101,
        'name': '맛있는 식당',
        'latitude': 37.5665,
        'longitude': 126.9780,
        'bdMgtSn': '1111010100100010000000001',
        'road_address': '서울특별시 중구 세종대로 110',
      };

      final store = Store.fromMap(map);
      expect(store.id, 101);
      expect(store.name, '맛있는 식당');
      expect(store.latitude, 37.5665);
      expect(store.longitude, 126.9780);
      expect(store.roadAddress, '서울특별시 중구 세종대로 110');

      final serialized = store.toMap();
      expect(serialized['id'], 101);
      expect(serialized['name'], '맛있는 식당');
    });

    test('MenuItem model serialization', () {
      final map = {
        'id': 'menu-1',
        'name': '김치찌개',
        'price': 9000,
        'description': '얼큰한 돼지고기 김치찌개',
        'image_url': 'https://example.com/kimchi.jpg',
        'created_at': '2026-01-01T12:00:00.000Z',
      };

      final menuItem = MenuItem.fromMap(map);
      expect(menuItem.id, 'menu-1');
      expect(menuItem.name, '김치찌개');
      expect(menuItem.price, 9000);
      expect(menuItem.description, '얼큰한 돼지고기 김치찌개');
      expect(menuItem.imageUrl, 'https://example.com/kimchi.jpg');
    });

    test('JusoAddress model parsing', () {
      final json = {
        'roadAddr': '서울특별시 강남구 테헤란로 123',
        'jibunAddr': '서울특별시 강남구 역삼동 456',
        'siNm': '서울특별시',
        'sggNm': '강남구',
        'emdNm': '역삼동',
        'liNm': '',
        'bdMgtSn': '1168010100101230000000001',
      };

      final juso = JusoAddress.fromJson(json);
      expect(juso.roadAddr, '서울특별시 강남구 테헤란로 123');
      expect(juso.jibunAddr, '서울특별시 강남구 역삼동 456');
      expect(juso.bdMgtSn, '1168010100101230000000001');
    });
  });
}
