import 'package:flutter/material.dart';

class BlockIcon extends StatelessWidget {
  const BlockIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(itemBuilder: (context, index) {
        
      }),
    );
  }

  Widget blockIconParking() {
    const cannotParkIcon = Stack(
      children: [
        Icon(Icons.local_parking, size: 25),
        Icon(Icons.close, color: Colors.red, size: 25),
      ],
    );
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueAccent[100]!, width: 3),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_parking, size: 25),
              //cannotParkIcon,
              SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: '주차 '),
                    TextSpan(
                      text: 'O',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
