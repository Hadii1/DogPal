import 'package:dog_pal/navigators/dogs_screen_navigator.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LocationField extends StatefulWidget {
  @override
  _LocationFieldState createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  String _locationDisplay;

  @override
  void initState() {
    _locationDisplay = Provider.of<LocalStorage>(context, listen: false)
        .getPostLocationData()
        .display;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Location',
            style: subHeaderStyle,
          ),
          ActionChip(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () async {
              await Navigator.of(context)
                  .pushNamed(DogsScreenRoutes.POST_LOCATION, arguments: (city) {
                setState(() {
                  _locationDisplay = city;
                });
              });
            },
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _locationDisplay,
                  style: TextStyle(fontSize: 40.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
