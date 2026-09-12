import 'package:flutter_test/flutter_test.dart';
import 'package:eat_road_manager/models/store.dart';

void main() {
  test('Basic smoke test', () {
    const store = Store(
      id: 'test-uuid-1234',
      name: '테스트 식당',
      latitude: 37.5,
      longitude: 127.0,
    );
    expect(store.id, 'test-uuid-1234');
    expect(store.name, '테스트 식당');
  });
}
