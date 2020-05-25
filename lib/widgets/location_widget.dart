import 'package:dog_pal/bloc/post_location_bloc.dart';
import 'package:dog_pal/screens/post_location.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationField extends StatelessWidget {
  const LocationField(this.locationDisplay);
  final String locationDisplay;

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
            onPressed: () => Navigator.of(context).push(
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
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  locationDisplay,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
