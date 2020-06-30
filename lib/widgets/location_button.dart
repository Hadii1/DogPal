import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({
    @required this.location,
  });

  final Stream<String> location;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 24),
      child: SizedBox(
        height: 100.sp,
        child: OutlineButton(
          splashColor: Colors.transparent,
          onPressed: () {},
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
          highlightedBorderColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: StreamBuilder<String>(
              stream: location,
              initialData: Provider.of<LocalStorage>(context, listen: false)
                  .getUserLocationData()
                  .userDisplay,
              builder: (context, snapshot) {
                return Text(
                  'Searching in:  ${snapshot.data}',
                  style: TextStyle(
                    color: blackishColor,
                    fontSize: 42.sp,
                  ),
                );
              }),
        ),
      ),
    );
  }
}
