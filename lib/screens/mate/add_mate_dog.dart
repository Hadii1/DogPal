import 'package:dog_pal/bloc/add_mate_dog_bloc.dart';
import 'package:dog_pal/utils/enums.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/breed_filter_widget.dart';
import 'package:dog_pal/widgets/coat_color_filter_widget.dart';
import 'package:dog_pal/widgets/filter_check_box.dart';
import 'package:dog_pal/widgets/gender_filter_widget.dart';
import 'package:dog_pal/widgets/image_slide_widget.dart';
import 'package:dog_pal/widgets/input_fields.dart';
import 'package:dog_pal/widgets/location_widget.dart';
import 'package:dog_pal/widgets/size_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class AddMateDogScreen extends StatefulWidget {
  @override
  _AddMateDogScreenState createState() => _AddMateDogScreenState();
}

class _AddMateDogScreenState extends State<AddMateDogScreen> {
  AddMateDogBloc _bloc;

  GlobalKey<FormState> _nameKey = GlobalKey();

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _bloc = Provider.of<AddMateDogBloc>(context, listen: false);
    _bloc.errors.listen((error) {
      Scaffold.of(context).showSnackBar(errorSnackBar(error));
    });

    _bloc.state.listen((state) {
      switch (state) {
        case PostAdditionState.loading:
          break;

        case PostAdditionState.shouldNavigate:
          Navigator.popUntil(context, (route) => route.isFirst);
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
    _scrollController.dispose();
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

        // FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Add For Mating'),
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ImageSlide(
                      allowedPhotos: 4,
                      initalPhotos: _bloc.assets,
                      onChanged: (images) => _bloc.assets = images,
                    ),
                    NameField(
                      nameKey: _nameKey,
                      onChanged: (name) => _bloc.mateDog.dogName = name,
                    ),
                    AgeField(
                      onChanged: (age) => _bloc.mateDog.age = age,
                      initialAge: _bloc.mateDog.age,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: BreedFilterWidget(
                        onChanged: (breed) => _bloc.mateDog.breed = breed,
                        orientation: WidgetOrientation.horizontal,
                        initalBreed: _bloc.mateDog.breed,
                      ),
                    ),
                    Divider(),
                    GenderFilter(
                      isRequired: true,
                      onChanged: (gender) => _bloc.mateDog.gender = gender,
                      initialValue: _bloc.mateDog.gender,
                    ),
                    Divider(),
                    CoatColor(
                      onChanged: (colors) => _bloc.mateDog.coatColors = colors,
                    ),
                    Divider(),
                    SizeFilter(
                      isRequired: true,
                      onChanged: (size) => _bloc.mateDog.size = size,
                      initialValue: _bloc.mateDog.size,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: FilterCheckBox(
                        label: 'Vaccinated',
                        initialValue: _bloc.mateDog.vaccinated,
                        onChanged: (value) => _bloc.mateDog.vaccinated = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: FilterCheckBox(
                        label: 'Pedigree',
                        initialValue: _bloc.mateDog.pedigree,
                        onChanged: (bool value) =>
                            _bloc.mateDog.pedigree = value,
                      ),
                    ),
                    Divider(),
                    DescriptionField(
                      onChanged: (desc) => _bloc.description = desc,
                    ),
                    LocationField(),
                    Divider(),
                    PhoneField(
                      onChanged: (number) =>
                          _bloc.mateDog.owner.phoneNumber = number,
                    ),
                    _addButton(),
                  ],
                ),
              ),
              StreamBuilder<PostAdditionState>(
                  stream: _bloc.state,
                  builder: (context, snapshot) {
                    return Center(
                      child: AnimatedCrossFade(
                        duration: Duration(milliseconds: 300),
                        crossFadeState:
                            snapshot.data == PostAdditionState.loading
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
                  }),
            ],
          )),
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

  void _validateValues() {
    if (_nameKey.currentState.validate()) {
      if (_bloc.mateDog.age.isNotEmpty) {
        if (_bloc.assets.isNotEmpty) {
          _bloc.sendPostToAppBloc();
        } else {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('At least one photo for the dog should be added'),
            ),
          );
        }
      } else {
        _scrollController.animateTo(
          0.1,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCirc,
        );
        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            'Please specify the age',
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      _scrollController.animateTo(
        0.1,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCirc,
      );
    }
  }
}
