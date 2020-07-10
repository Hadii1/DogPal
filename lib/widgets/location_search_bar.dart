import 'dart:io';
import 'package:dog_pal/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';

class LocationSeachBar extends StatefulWidget {
  const LocationSeachBar({
    @required this.onSuggestionSelected,
    @required this.suggestionCallback,
    @required this.onNearbyPressed,
    @required this.cityController,
    @required this.isLoading,
  });

  final Function(Prediction prediction) onSuggestionSelected;
  final Future<List<Prediction>> Function(String input) suggestionCallback;
  final TextEditingController cityController;
  final Stream<bool> isLoading;
  final Function() onNearbyPressed;
  @override
  _LocationSeachBarState createState() => _LocationSeachBarState();
}

class _LocationSeachBarState extends State<LocationSeachBar> {
  TextEditingController get _nameCtrl => widget.cityController;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //To toggle the trailer icon which depends on the text being empty or not
    _nameCtrl.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _focusNode.dispose();
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
          child: Row(
            children: <Widget>[
              Expanded(
                child: TypeAheadField(
                  animationDuration: Duration(milliseconds: 300),
                  suggestionsBoxVerticalOffset: 10,
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    offsetX: 10,
                    elevation: 20,
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
                          style: TextStyle(fontSize: 50.sp),
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
                    print(error);
                    return ListTile(
                      title: Text(
                        error is SocketException
                            ? 'No Internet Connection'
                            : 'Error',
                        style: TextStyle(
                          fontSize: 60.sp,
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
                    if (input.isNotEmpty) {
                      List<Prediction> predictions =
                          await widget.suggestionCallback(input);

                      return predictions;
                    } else {
                      return null;
                    }
                  },
                  onSuggestionSelected: (Prediction prediction) {
                    _nameCtrl.text = prediction.description;
                    widget.onSuggestionSelected(prediction);
                  },
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _nameCtrl,
                    autocorrect: false,
                    autofocus: false,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 50.sp,
                      color: blackishColor,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Search Cities',
                      labelStyle: TextStyle(fontFamily: 'OpenSans'),
                      filled: true,
                      fillColor: yellowishColor,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 24,
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
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _nameCtrl.text.isEmpty
                      ? InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () {
                            widget.onNearbyPressed();
                            _focusNode.unfocus();
                          },
                          child: Icon(
                            Icons.location_on,
                            size: 21,
                            color: blackishColor.withOpacity(0.8),
                          ),
                        )
                      : Container(
                          child: InkWell(
                            onTap: () =>
                                WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                                _nameCtrl.clear();
                                if (!_focusNode.hasFocus) {
                                  _focusNode.requestFocus();
                                }
                              },
                            ),
                            child: Icon(
                              Icons.close,
                              size: 21,
                              color: blackishColor.withAlpha(200),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<bool>(
          stream: widget.isLoading,
          initialData: false,
          builder: (_, snapshot) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: snapshot.data
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 12.sp),
                      child: Container(
                        height: 3,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          child: LinearProgressIndicator(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            );
          },
        )
      ],
    );
  }
}
