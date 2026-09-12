import 'package:flutter/material.dart';
import '../../../core/utils/speech_bubble_painter.dart';
import '../../../models/store.dart';

class StoreInfoWindow extends StatelessWidget {
  final List<Store> stores;
  final Offset offset;
  final ValueChanged<String> onStoreSelected;

  const StoreInfoWindow({
    super.key,
    required this.stores,
    required this.offset,
    required this.onStoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    const double infoWindowWidth = 250.0;
    final double infoWindowHeight = 60.0 + (stores.length * 50.0);

    return Positioned(
      left: offset.dx - (infoWindowWidth / 2),
      top: offset.dy - infoWindowHeight - 45,
      child: CustomPaint(
        painter: SpeechBubblePainter(
          bubbleColor: Colors.white,
          borderColor: Colors.grey[400]!,
          borderWidth: 2,
        ),
        child: Container(
          width: infoWindowWidth,
          height: infoWindowHeight,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stores.first.roadAddress ?? '가게 목록',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.lightBlue.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onStoreSelected(store.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            store.name,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
