import 'package:flutter/material.dart';

class DetailedStoreScreenFullScreenImageView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const DetailedStoreScreenFullScreenImageView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<DetailedStoreScreenFullScreenImageView> createState() =>
      _DetailedStoreScreenFullScreenImageViewState();
}

class _DetailedStoreScreenFullScreenImageViewState
    extends State<DetailedStoreScreenFullScreenImageView> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currnetPageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currnetPageNotifier = ValueNotifier<int>(widget.initialIndex + 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currnetPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: ValueListenableBuilder<int>(
          valueListenable: _currnetPageNotifier,
          builder: (context, value, child) {
            return Text(
              '$value / ${widget.imageUrls.length}',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          _currnetPageNotifier.value = index + 1;
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.white,),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
