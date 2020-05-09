import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color blackishColor = Color(0xff3D3B40);
Color yellowishColor = Color(0xfffffffa);

TextStyle normalTextStyle = TextStyle(
  color: Colors.black87,
  fontSize: ScreenUtil().setSp(46),
  fontFamily: 'Comfortaa'
);

TextStyle detailsHeader = TextStyle(
  color: blackishColor,
  fontSize: ScreenUtil().setSp(56),
  fontWeight: FontWeight.w700,
  fontFamily: 'Montserrat',
);

TextStyle subHeaderStyle = TextStyle(
    color: blackishColor,
    fontSize: ScreenUtil().setSp(48),
    fontFamily: 'OpenSans');


TextStyle dogNameStyle = TextStyle(
  color: blackishColor,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.5,
  fontSize: ScreenUtil().setSp(90),
  fontFamily: 'Montserrat',
);

TextStyle dogBreedStyle = TextStyle(
  color: blackishColor,
  fontWeight: FontWeight.w500,
  fontSize: ScreenUtil().setSp(65),
  fontFamily: 'Montserrat',
);
