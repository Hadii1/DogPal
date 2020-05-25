import 'package:dog_pal/bloc/add_lost_dog_bloc.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/breed_filter_widget.dart';
import 'package:dog_pal/widgets/coat_color_filter_widget.dart';
import 'package:dog_pal/widgets/gender_filter_widget.dart';
import 'package:dog_pal/widgets/image_slide_widget.dart';
import 'package:dog_pal/widgets/input_fields.dart';
import 'package:dog_pal/widgets/location_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class AddLostDogScreen extends StatefulWidget {
  const AddLostDogScreen();

  @override
  _AddLostDogScreenState createState() => _AddLostDogScreenState();
}

class _AddLostDogScreenState extends State<AddLostDogScreen> {
  AddLostDogBloc _bloc;

  GlobalKey<FormState> _nameKey = GlobalKey();

  ScrollController _scrolCtrl = ScrollController();

  @override
  void initState() {
    _bloc = Provider.of<AddLostDogBloc>(context, listen: false);
    _bloc.errors.listen((error) {
      Scaffold.of(context).showSnackBar(errorSnackBar(error));
    });
    _bloc.state.listen((state) {
      switch (state) {
        case PostAdditionState.loading:
          return;
          break;
        case PostAdditionState.shouldNavigate:
          Navigator.pop(context);
          break;
        case PostAdditionState.noInternet:
          Scaffold.of(context).showSnackBar(noConnectionSnackbar());
          break;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _scrolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //So that the keyboard hides when the user taps anywhere outside
      onTap: () {
        FocusScopeNode node = FocusScope.of(context);
        if (!node.hasPrimaryFocus) {
          node.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Lost Dog'),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: _scrolCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ImageSlide(
                    allowedPhotos: 3,
                    initalPhotos: _bloc.assetsList,
                    onChanged: (List<Asset> images) =>
                        _bloc.assetsList = images,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        NameField(
                          nameKey: _nameKey,
                          onChanged: (name) => _bloc.dog.dogName = name,
                        ),
                        BreedFilterWidget(
                          orientation: WidgetOrientation.horizontal,
                          initalBreed: _bloc.dog.breed,
                          onChanged: (breed) => _bloc.dog.breed = breed,
                        ),
                        Divider(),
                        GenderFilter(
                          onChanged: (String gender) =>
                              _bloc.dog.gender = gender,
                          initialValue: _bloc.dog.gender,
                        ),
                        Divider(),
                        CoatColor(
                          onChanged: (colorsList) =>
                              _bloc.dog.coatColors = colorsList,
                          initialColors: _bloc.dog.coatColors.cast<String>(),
                        ),
                        Divider(),
                        DescriptionField(
                          onChanged: (description) =>
                              _bloc.description = description,
                        ),
                        LocationField(
                          Provider.of<LocalStorage>(context, listen: false)
                              .getPostLocationData()
                              .postDisplay,
                        ),
                        PhoneField(
                          onChanged: (number) =>
                              _bloc.dog.owner.phoneNumber = number,
                        ),
                        _addButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<PostAdditionState>(
              stream: _bloc.state,
              builder: (BuildContext _, AsyncSnapshot snapshot) {
                return Center(
                  child: AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: snapshot.data == PostAdditionState.loading
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                        color: yellowishColor.withOpacity(0.5),
                        child: SpinKitThreeBounce(
                          color: Theme.of(context).primaryColor,
                        )),
                    secondChild: SizedBox.shrink(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: RaisedButton(
        onPressed: () => _validateValues(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Add',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              fontSize: ScreenUtil().setSp(54),
            ),
          ),
        ),
      ),
    );
  }

  _validateValues() {
    if (_nameKey.currentState.validate()) {
      if (_bloc.assetsList.length > 0) {
        _bloc.sendPostToAppBloc();
      } else {
        _scrolCtrl.animateTo(
          0.1,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            'At least one photo for the dog should be added',
          ),
        );
      }
    } else {
      _scrolCtrl.animateTo(0.1,
          duration: Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }
}
