import 'dart:io';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/location_util.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';

class LocationSeachBar extends StatefulWidget {
  const LocationSeachBar({
    @required this.onSuggestionSelected,
    @required this.cityController,
    this.autoFocus,
  });
  final Function(
    String town,
    String city,
    String district,
    String display,
  ) onSuggestionSelected;

  final TextEditingController cityController;

  final bool autoFocus;

  @override
  _LocationSeachBarState createState() => _LocationSeachBarState();
}

class _LocationSeachBarState extends State<LocationSeachBar> {
  TextEditingController get _nameCtrl => widget.cityController;

  final LocationUtil _locationUtil = LocationUtil();

  bool _isLoading = false;

  @override
  void initState() {
    _nameCtrl.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          color: yellowishColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: TypeAheadField(
            animationDuration: Duration(milliseconds: 600),
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              color: yellowishColor,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (_, Prediction prediction) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: ListTile(
                  title: Text(
                    prediction.description,
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                  leading: Icon(
                    Icons.place,
                    color: Colors.black54,
                  ),
                ),
              );
            },
            errorBuilder: (_, error) {
              return ListTile(
                title: Text(
                  error is SocketException ? 'No Internet Connection' : 'Error',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              );
            },
            noItemsFoundBuilder: (_) {
              if (_nameCtrl.text.isEmpty) {
                return SizedBox.shrink();
              }
              return ListTile(
                leading: Icon(Icons.error, color: blackishColor),
                title: Text('Nothing Found'),
              );
            },
            hideOnEmpty: false,
            hideSuggestionsOnKeyboardHide: true,
            suggestionsCallback: (input) async {
              return await _locationUtil.completePlacesQuery(input);
            },
            onSuggestionSelected: (Prediction prediction) async =>
                _suggestionSelected(prediction),
            textFieldConfiguration: TextFieldConfiguration(
              controller: _nameCtrl,
              autocorrect: false,
              autofocus: widget.autoFocus ?? false,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: blackishColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                suffixIcon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _nameCtrl.text.isNotEmpty
                      ? InkWell(
                          onTap: () =>
                              WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              _nameCtrl.clear();
                            },
                          ),
                          child: Icon(
                            Icons.close,
                            color: blackishColor.withAlpha(200),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                labelText: 'Search Cities',
                labelStyle: TextStyle(fontFamily: 'OpenSans'),
                filled: true,
                fillColor: yellowishColor,
                prefixIcon: Icon(
                  Icons.search,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).accentColor,
                    ),
                  ),
                )
              : Container(),
        )
      ],
    );
  }

  Future<void> _suggestionSelected(Prediction prediction) async {
    //Throwing exceptions will call error builder in the TypeAheadfield

    setState(() {
      _isLoading = true;
    });

    try {
      _nameCtrl.text = prediction.description;

      Map<String, String> info =
          await _locationUtil.getDetailsFromPrediction(prediction);

      if (info == null) {
        Scaffold.of(context).showSnackBar(
          errorSnackBar('Something went wrong on our side'),
        );

        _nameCtrl.text = '';

        return;
      }

      String town = info[UserConsts.TOWN];
      String city = info[UserConsts.CITY];
      String district = info[UserConsts.DISTRICT];
      String display = prediction.description;
      widget.onSuggestionSelected(
        town,
        city,
        district,
        display,
      );
    } on SocketException {
      Scaffold.of(context).showSnackBar(
        errorSnackBar('Poor Internet Connection'),
      );
      _nameCtrl.text = '';
    } on PlatformException {
      Scaffold.of(context).showSnackBar(
        errorSnackBar('Something went wrong on our side'),
      );
      _nameCtrl.text = '';
    }

    setState(() {
      _isLoading = false;
    });
  }
}
