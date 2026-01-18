import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_block_icon.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_text_button.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_expand_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:eat_road_manager/detailed_store/store_info.dart';
import 'package:eat_road_manager/detailed_store/detailed_store_screen_full_screen_image_view.dart';

class InfoTab extends StatefulWidget {
  final StoreInfo storeInfo;
  final ScrollController scrollController;


  const InfoTab({
    super.key,
    required this.storeInfo,
    required this.scrollController,
  });

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final CarouselSliderController carouselSliderController = CarouselSliderController();

  int currentPage = 0;

  final GlobalKey _parkingTileKey = GlobalKey();
  final GlobalKey _reservationTileKey = GlobalKey();
  final GlobalKey _wifiTileKey = GlobalKey();

  bool _isParkingExpanded = false;
  bool _isReservationExpanded = false;
  bool _isWifiExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String wifiInfo = '와이파이 이름: ${widget.storeInfo.wifiId}\n와이파이 비밀번호: ${widget.storeInfo.wifiPw}';

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        children: [
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider.builder(
                carouselController: carouselSliderController,
                itemCount: widget.storeInfo.interiorImageUrls?.length ?? 0,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  final imageUrls = widget.storeInfo.interiorImageUrls![itemIndex];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailedStoreScreenFullScreenImageView(
                                imageUrls: widget.storeInfo.interiorImageUrls!,
                                initialIndex: itemIndex,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrls,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 8),
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                child: AnimatedSmoothIndicator(
                  activeIndex: currentPage,
                  count: widget.storeInfo.interiorImageUrls?.length ?? 0,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    dotColor: Color.fromRGBO(255, 143, 33, 0.5),
                    activeDotColor: Color.fromRGBO(255, 143, 33, 1),
                  ),
                  onDotClicked: (index) {
                    carouselSliderController.animateToPage(index);
                  },
                ),
              ),
            ],
          ),
          // Iconbutton
          BlockIcon(
            parkingAvailable: widget.storeInfo.isParkingAvailable,
            reservationAvailable: widget.storeInfo.isReservationAvailable,
            wifiAvailable: widget.storeInfo.isWifiAvailable,
            takeoutAvailable: widget.storeInfo.isTakeoutAvailable,
            onParkingTap: () => _scrollToAndExpand(_parkingTileKey, 'parking'),
            onReservationTap: () =>
                _scrollToAndExpand(_reservationTileKey, 'reservation'),
            onWifiTap: () => _scrollToAndExpand(_wifiTileKey, 'wifi'),
            onTakeoutTap: () {},
          ),
          //description
          Container(
            padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 10),
            width: double.infinity,
            child: Text(widget.storeInfo.description),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
            child: Column(
              children: [
                // 주소 address
                IconTextButton(
                  icon: Icons.location_on,
                  text: '${widget.storeInfo.roadAddr} ${widget.storeInfo.detailAddr ?? ''}'.trim(),
                  onPressed: () {
                    final fullAddress =
                        '${widget.storeInfo.roadAddr} ${widget.storeInfo.detailAddr ?? ''}'.trim();

                    if (fullAddress.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: fullAddress));
                    }
                  },
                ),
                IconTextButton(
                  icon: Icons.phone,
                  text: widget.storeInfo.storePhoneNumber ?? '전화번호 정보 없음',
                  onPressed: () {
                    if (widget.storeInfo.storePhoneNumber != null &&
                        widget.storeInfo.storePhoneNumber!.isNotEmpty) {
                      Clipboard.setData(
                        ClipboardData(text: widget.storeInfo.storePhoneNumber!),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  "영업 시간",
                ),
                SizedBox(height: 10),
                IconTextButton(
                  icon: Icons.access_time,
                  text: '${widget.storeInfo.openTime} ~ ${widget.storeInfo.closeTime}',
                ),
                IconTextButton(
                  icon: Icons.dining,
                  text: '주문 마감 시간: ${widget.storeInfo.lastOrderTime ?? '정보 없음'}',
                ),
                IconTextButton(
                  icon: Icons.calendar_today,
                  text: "영업일: ${widget.storeInfo.businessDays.join(', ')}",
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.grey[300],
            indent: 15,
            endIndent: 15,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  "세부 사항",
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    //세부 사항 주차
                    ExpandInfoTile(
                      title: '주차',
                      key: _parkingTileKey,
                      iconData: Icons.local_parking,
                      expandedInfo: widget.storeInfo.parkingInfo,
                      isExpanded: _isParkingExpanded,
                      onTap: () {
                        setState(() {
                          _isParkingExpanded = !_isParkingExpanded;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    //세부 사항 예약
                    ExpandInfoTile(
                      title: '좌석',
                      key: _reservationTileKey,
                      iconData: Icons.event_seat,
                      expandedInfo: widget.storeInfo.seatsInfo,
                      isExpanded: _isReservationExpanded,
                      onTap: () {
                        setState(() {
                          _isReservationExpanded = !_isReservationExpanded;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ExpandInfoTile(
                      title: '와이파이',
                      key: _wifiTileKey,
                      iconData: Icons.wifi,
                      expandedInfo: wifiInfo,
                      isExpanded: _isWifiExpanded,
                      onTap: () {
                        setState(() {
                          _isWifiExpanded = !_isWifiExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToAndExpand(GlobalKey key, String tileName) {
    final context = key.currentContext;
    if (context!= null) {
      setState(() {
        _isParkingExpanded = (tileName == 'parking') ? !_isParkingExpanded : false;
        _isReservationExpanded = (tileName == 'reservation') ? !_isReservationExpanded : false;
        _isWifiExpanded = (tileName == 'wifi') ? !_isWifiExpanded : false;
      });

      Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
    }
  }
}
