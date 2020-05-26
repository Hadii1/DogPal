import 'dart:io';

import 'package:dog_pal/navigators/mate_navigator.dart';
import 'package:dog_pal/utils/mate_warnings.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MateWarningScreen extends StatefulWidget {
  @override
  _MateWarningScreenState createState() => _MateWarningScreenState();
}

class _MateWarningScreenState extends State<MateWarningScreen> {
  bool _documentRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Warning',
          style: TextStyle(fontSize: 65.sp),
        ),
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            size: 75.sp,
            color: blackishColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Things to consider before adding your dog for mating:',
                  softWrap: true,
                  style: TextStyle(
                    color: blackishColor,
                    fontSize: 65.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                child: Text(
                  MATE_WARNING,
                  style: normalTextStyle,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'I have read and understood the document',
                      style: TextStyle(fontFamily: 'OpenSans'),
                    ),
                  ),
                  Checkbox(
                    value: _documentRead,
                    onChanged: (value) {
                      setState(() {
                        _documentRead = value;
                      });
                    },
                  )
                ],
              ),
              FlatButton(
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _documentRead
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  width: double.maxFinite,
                  height: 150.sp,
                  duration: Duration(milliseconds: 300),
                  child: Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onPressed: () => _documentRead
                    ? Navigator.of(context).pushNamed(MateRoutes.ADD_MATE_DOG)
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
