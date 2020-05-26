import 'package:dog_pal/bloc/post_location_bloc.dart';
import 'package:dog_pal/screens/post_location.dart';
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
        .postDisplay;
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
              _locationDisplay = await Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) {
                        return Provider(
                          create: (_) => PostLocationBloc(
                            Provider.of<LocalStorage>(context, listen: false),
                          ),
                          child: PostLocation(),
                        );
                      },
                    ),
                  ) ??
                  _locationDisplay ??
                  '';

              setState(() {});
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
