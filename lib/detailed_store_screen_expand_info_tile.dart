import 'package:flutter/material.dart';

class ExpandInfoTile extends StatefulWidget {
  final String title;
  final String? expandedInfo;

  const ExpandInfoTile({
    super.key,
    required this.title,
    required this.expandedInfo,
  });

  @override
  State<ExpandInfoTile> createState() => _ExpandInfoTileState();
}

class _ExpandInfoTileState extends State<ExpandInfoTile> {
  bool _isExpanded = false;
  static const Color mainColor = Color.fromRGBO(255, 143, 43, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(5),
            highlightColor: mainColor.withAlpha(200),
            splashColor: mainColor.withAlpha(120),
            child: Container(
              width: double.infinity,
              height: 45,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: mainColor.withAlpha(150),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.black.withAlpha(180),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.black.withAlpha(180),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: mainColor.withAlpha(120), width: 2),
                right: BorderSide(color: mainColor.withAlpha(120), width: 2),
                bottom: BorderSide(color: mainColor.withAlpha(120), width: 2),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(widget.expandedInfo ?? '정보 없음'),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
