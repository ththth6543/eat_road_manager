import 'package:flutter_test/flutter_test.dart';
import 'package:eat_road_manager/models/store.dart';

void main() {
  test('Basic smoke test', () {
    const store = Store(
      id: 1,
      name: '테스트 식당',
      latitude: 37.5,
      longitude: 127.0,
    );
    expect(store.id, 1);
    expect(store.name, '테스트 식당');
  });
}
