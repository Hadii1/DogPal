import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Color blackishColor = Color(0xff3D3B40);
Color yellowishColor = Color(0xfffffffa);

TextStyle normalTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: ScreenUtil().setSp(45),
    fontFamily: 'Comfortaa');

TextStyle detailsHeader = TextStyle(
  color: blackishColor,
  fontSize: ScreenUtil().setSp(60),
  fontWeight: FontWeight.w700,
  fontFamily: 'Montserrat',
);

TextStyle subHeaderStyle = TextStyle(
    color: blackishColor,
    fontSize: ScreenUtil().setSp(55),
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

ThemeData appTheme = ThemeData(
  bottomSheetTheme: BottomSheetThemeData(
    modalBackgroundColor: Color(0xfffffffa),
    elevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
    ),
    backgroundColor: Color(0xfffffffa),
  ),
  splashColor: Colors.orangeAccent,
  backgroundColor: yellowishColor,
  scaffoldBackgroundColor: yellowishColor,
  tabBarTheme: TabBarTheme(
    labelColor: blackishColor,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: TextStyle(color: blackishColor, fontFamily: 'OpenSans'),
    unselectedLabelStyle:
        TextStyle(color: blackishColor, fontFamily: 'OpenSans'),
  ),
  appBarTheme: AppBarTheme(
    color: yellowishColor,
    brightness: Brightness.light,
    elevation: 0.8,
    iconTheme: IconThemeData(color: blackishColor),
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontFamily: 'OpenSans',
        letterSpacing: 0.5,
      ),
    ),
  ),
  brightness: Brightness.light,
  snackBarTheme: SnackBarThemeData(
    shape: Border(
      top: BorderSide(color: blackishColor, width: 0.3),
    ),
    actionTextColor: Color(0xff004d51),
    contentTextStyle: TextStyle(
      color: blackishColor,
      fontFamily: 'OpenSans',
      fontSize: 14,
    ),
    backgroundColor: yellowishColor,
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    buttonColor: Color(0xff007A7D),
    textTheme: ButtonTextTheme.primary,
    splashColor: Color(0xffD7A339),
    highlightColor: Color(0xffD7A339),
  ),
  primaryColor: Color(0xff007A7D),
  primaryColorDark: Color(0xff004d51),
  primaryColorLight: Color(0xff4ba9ac),
  accentColor: Color(0xffD7A339),
  fontFamily: 'Comfortaa',
  inputDecorationTheme: InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: blackishColor),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(width: 0.5, color: blackishColor),
    ),
    labelStyle: TextStyle(color: blackishColor),
  ),
);
