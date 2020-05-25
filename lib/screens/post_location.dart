import 'package:dog_pal/bloc/post_location_bloc.dart';
import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PostLocation extends StatefulWidget {
  @override
  LocationWidgetDialog createState() => LocationWidgetDialog();
}

class LocationWidgetDialog extends State<PostLocation> {
  TextEditingController _locationFieldCtrl = TextEditingController();

  PostLocationBloc _bloc;

  @override
  void initState() {
    _bloc = Provider.of<PostLocationBloc>(context, listen: false);

    _bloc.errorStream.listen(
      (error) {
        if (error == GeneralConstants.LOCATION_PERMISSION_ERROR) {
          Scaffold.of(context).showSnackBar(
            permissionSnackbar(
              'Please enable location access',
              androidPermission: Permission.locationWhenInUse,
            ),
          );
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
        title: Text('Post Location'),
        leading: IconButton(
          icon: Icon(
            Icons.close,
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: blackishColor,
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
                _verifyButton()
              ]),
        ),
      ),
    );
  }

  Widget _locationName() {
    PostLocationData postLocData =
        Provider.of<LocalStorage>(context, listen: false).getPostLocationData();
    return StreamBuilder<String>(
      stream: _bloc.cityName,
      initialData: postLocData.postDisplay,
      builder: (_, AsyncSnapshot<String> snapshot) {
        return Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Row(
            children: <Widget>[
              Text(
                'City:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        snapshot.data,
                        softWrap: true,
                      ))),
            ],
          ),
        );
      },
    );
  }

  Widget _verifyButton() {
    return Container(
      padding: const EdgeInsets.only(top: 26),
      child: FlatButton(
        color: Color(0xff2F4858),
        onPressed: () {
          _bloc.savePostLocation();
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
            child: FlatButton.icon(
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              label: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: snapshot.data
                    ? SpinKitThreeBounce(
                        color: Colors.white,
                        size: 25,
                      )
                    : Center(
                        child: Text(
                          'Use Current Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(46),
                          ),
                        ),
                      ),
              ),
              onPressed: () async {
                _locationFieldCtrl.clear();
                _bloc.currentLocationPressed();
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
        autoFocus: true,
        cityController: TextEditingController(),
        onSuggestionSelected: (town, city, district, item) {
          _bloc.searchBarLocationSelected(town, city, district, item);
        },
      ),
    );
  }
}
