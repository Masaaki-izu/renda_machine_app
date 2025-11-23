import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final Color color;
  final double edge;
  final double redius1;
  final double redius2;
  final double fontsize;

  const MyCustomOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.color,
    required this.edge,
    required this.redius1,
    required this.redius2,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: edge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(redius1),
              topRight: Radius.circular(redius2),
              bottomLeft: Radius.circular(redius2),
              bottomRight: Radius.circular(redius1),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontsize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
