import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(255, 143, 33, 0.2),
          ),
          child: Icon(
            icon,
            color: Color.fromRGBO(255, 143, 33, 1),
          ),),
        Flexible(
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.start,
              maxLines: null,
              text,
            ),
          ),
        ),
      ],
    );
  }
}
