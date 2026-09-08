import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BlockIcon extends StatelessWidget {
  final bool parkingAvailable;
  final bool reservationAvailable;
  final bool wifiAvailable;
  final bool takeoutAvailable;
  final VoidCallback? onParkingTap;
  final VoidCallback? onReservationTap;
  final VoidCallback? onWifiTap;
  final VoidCallback? onTakeoutTap;

  const BlockIcon({
    super.key,
    required this.parkingAvailable,
    required this.reservationAvailable,
    required this.wifiAvailable,
    required this.takeoutAvailable,
    this.onParkingTap,
    this.onReservationTap,
    this.onWifiTap,
    this.onTakeoutTap,
  });

  static const mainColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          children: [
            buildBlockIcon(
              parkingAvailable,
              Icons.local_parking,
              '주차',
              onTap: onParkingTap,
            ),
            buildBlockIcon(
              reservationAvailable,
              Icons.event_available,
              '예약',
              onTap: onReservationTap,
            ),
            buildBlockIcon(wifiAvailable, Icons.wifi, 'wifi', onTap: onWifiTap),
            buildBlockIcon(
              takeoutAvailable,
              Icons.food_bank,
              '포장',
              onTap: onTakeoutTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBlockIcon(
    bool isAvailable,
    IconData iconName,
    String label, {
    VoidCallback? onTap,
  }) {
    var cannotParkIcon = Stack(
      children: [
        Icon(iconName, size: 25),
        const Icon(Icons.close, color: Colors.red, size: 25),
      ],
    );
    return Material(
      color: mainColor.withAlpha(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        highlightColor: mainColor.withAlpha(150),
        splashColor: mainColor.withAlpha(120),
        onTap: onTap,
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
                isAvailable ? Icon(iconName, size: 25) : cannotParkIcon,
                const SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: '$label '),
                      isAvailable
                          ? const TextSpan(
                              text: 'O',
                              style: TextStyle(color: Colors.blueAccent),
                            )
                          : const TextSpan(
                              text: 'X',
                              style: TextStyle(color: Colors.redAccent),
                            ),
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
