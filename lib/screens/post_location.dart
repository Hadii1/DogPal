import 'package:dog_pal/bloc/post_location_bloc.dart';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PostLocation extends StatefulWidget {
  const PostLocation({@required this.onLocationChanged});
  final Function(String) onLocationChanged;
  @override
  LocationWidgetDialog createState() => LocationWidgetDialog();
}

class LocationWidgetDialog extends State<PostLocation> {
  TextEditingController _locationFieldCtrl = TextEditingController();

  PostLocationBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<PostLocationBloc>(context, listen: false);

    _bloc.verifiedPlace.listen((city) {
      widget.onLocationChanged(city);
      Navigator.pop(context);
    });

    _bloc.errorStream.listen(
      (error) {
        if (error == GeneralConstants.LOCATION_PERMISSION_ERROR) {
          Scaffold.of(context).showSnackBar(
            permissionSnackbar(
              'Please enable location access',
              androidPermission: Permission.locationWhenInUse,
            ),
          );
        } else if (error == GeneralConstants.LOCATION_SERVICE_OFF_MSG) {
          Scaffold.of(context).showSnackBar(locationServiceSnackbar());
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
            ),
          );
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _locationFieldCtrl.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Location',
          style: TextStyle(
            fontSize: 65.sp,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(21),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _searchBar(),
              _currentLocationButton(),
              _progressIndicator(),
              _locationName(),
              _verifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationName() {
    LocationData postLocData =
        Provider.of<LocalStorage>(context, listen: false).getPostLocationData();
    return StreamBuilder<String>(
      stream: _bloc.display,
      initialData: postLocData.display,
      builder: (_, AsyncSnapshot<String> snapshot) {
        return Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          child: Row(
            children: <Widget>[
              Text(
                'City:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 50.sp,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    snapshot.data,
                    style: TextStyle(
                      fontSize: 50.sp,
                    ),
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _verifyButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: FlatButton(
        color: Color(0xff2F4858),
        onPressed: () => _bloc.onVerifyPressed(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Verify',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentLocationButton() {
    return StreamBuilder<Object>(
        stream: _bloc.shouldLoad,
        initialData: false,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: snapshot.data
                          ? SpinKitThreeBounce(
                              color: Colors.white,
                              size: 25,
                            )
                          : Text(
                              'Use Current Location',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 45.sp,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                _locationFieldCtrl.clear();
                _bloc.onCurrentLocationPressed();
              },
            ),
          );
        });
  }

  Widget _progressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<bool>(
        stream: _bloc.shouldLoad,
        initialData: false,
        builder: (_, AsyncSnapshot<bool> snapshot) {
          return AnimatedOpacity(
            opacity: snapshot.data ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LocationSeachBar(
        isLoading: _bloc.isFetchingLocationSuggestions,
        cityController: TextEditingController(),
        suggestionCallback: (input) => _bloc.onLocationSearch(input),
        onNearbyPressed: () => _bloc.onCurrentLocationPressed(),
        onSuggestionSelected: (Prediction prediction) {
          _bloc.onSuggesstionSelected(prediction);
        },
      ),
    );
  }
}
