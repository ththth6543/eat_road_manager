import 'package:eat_road_manager/detailed_store_screen_text_button.dart';
import 'package:flutter/material.dart';

class BlockIcon extends StatelessWidget {
  final bool parkingAvailable;
  final bool reservationAvailable;
  final bool wifiAvailable;
  final bool takeoutAvailable;

  const BlockIcon({
    super.key,
    required this.parkingAvailable,
    required this.reservationAvailable,
    required this.wifiAvailable,
    required this.takeoutAvailable,
  });

  static const mainColor = Color.fromRGBO(255, 143, 33, 1);
  // 주차, 예약, wifi, 포장,

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          children: [
            buildBlockIcon(parkingAvailable, Icons.local_parking, '주차'),
            buildBlockIcon(false, Icons.local_parking, '주차'),
            buildBlockIcon(reservationAvailable, Icons.event_available, '예약'),
            buildBlockIcon(false, Icons.event_available, '예약'),
            buildBlockIcon(wifiAvailable, Icons.wifi, 'wifi'),
            buildBlockIcon(false, Icons.wifi, 'wifi'),
            buildBlockIcon(takeoutAvailable, Icons.food_bank, '포장'),
            buildBlockIcon(false, Icons.food_bank, '포장'),
          ],
        ),
      ),
    );
  }

  Widget buildBlockIcon(bool isAvailable, IconData iconName, String label) {
    var cannotParkIcon = Stack(
      children: [
        Icon(iconName, size: 25,),
        Icon(Icons.close, color: Colors.red, size: 25),
      ],
    );
    return Material(
      color: mainColor.withAlpha(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        highlightColor: mainColor.withAlpha(150),
        splashColor: mainColor.withAlpha(120),
        onTap: () {},
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: mainColor.withAlpha(200), width: 3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isAvailable ? Icon(iconName, size: 25,) : cannotParkIcon,
                //cannotParkIcon,
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: '$label '),
                      isAvailable ?
                      TextSpan(
                        text: 'O',
                        style: TextStyle(color: Colors.blueAccent),
                      ) :
                      TextSpan(
                        text: 'X',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
