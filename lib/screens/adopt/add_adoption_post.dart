import 'package:dog_pal/bloc/add_adoption_dog_bloc.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/breed_filter_widget.dart';
import 'package:dog_pal/widgets/coat_color_filter_widget.dart';
import 'package:dog_pal/widgets/filter_check_box.dart';
import 'package:dog_pal/widgets/filter_choice_chip.dart';
import 'package:dog_pal/widgets/gender_filter_widget.dart';
import 'package:dog_pal/widgets/image_slide_widget.dart';
import 'package:dog_pal/widgets/input_fields.dart';
import 'package:dog_pal/widgets/location_widget.dart';
import 'package:dog_pal/widgets/size_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class AddAdoptPostScreen extends StatefulWidget {
  @override
  _AddAdoptPostScreenState createState() => _AddAdoptPostScreenState();
}

class _AddAdoptPostScreenState extends State<AddAdoptPostScreen> {
  GlobalKey<FormState> _nameKey = GlobalKey();

  ScrollController _pageScroller = ScrollController();
  AddAdoptionDogBloc _bloc;
  @override
  void initState() {
    super.initState();
    _bloc = Provider.of<AddAdoptionDogBloc>(context, listen: false);

    _bloc.state.listen(
      (state) {
        switch (state) {
          case PostAdditionState.loading:
            break;
          case PostAdditionState.shouldNavigate:
            Navigator.pop(context);
            break;
          case PostAdditionState.noInternet:
            Scaffold.of(context).showSnackBar(noConnectionSnackbar());
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _pageScroller.dispose();
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
        print('tapped');
        // FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Add Adoption Dog'),
          ),
          body: Scrollbar(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  controller: _pageScroller,
                  child: Column(
                    children: <Widget>[
                      ImageSlide(
                        allowedPhotos: 6,
                        initalPhotos: _bloc.assetList,
                        onChanged: (images) => _bloc.assetList = images,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            NameField(
                              nameKey: _nameKey,
                              onChanged: (name) =>
                                  _bloc.adoptionDog.dogName = name,
                            ),
                            AgeField(
                              onChanged: (age) => _bloc.adoptionDog.age = age,
                              initialAge: _bloc.adoptionDog.age,
                            ),
                            BreedFilterWidget(
                              orientation: WidgetOrientation.horizontal,
                              initalBreed: _bloc.adoptionDog.breed,
                              onChanged: (String breed) =>
                                  _bloc.adoptionDog.breed = breed,
                            ),
                            Divider(),
                            GenderFilter(
                              onChanged: (String gender) =>
                                  _bloc.adoptionDog.gender = gender,
                              initialValue: _bloc.adoptionDog.gender,
                            ),
                            Divider(),
                            CoatColor(
                              onChanged: (List<String> colors) =>
                                  _bloc.adoptionDog.coatColors = colors,
                            ),
                            Divider(),
                            SizeFilter(
                              onChanged: (String size) =>
                                  _bloc.adoptionDog.size = size,
                              initialValue: 'Medium',
                            ),
                            Divider(),
                            FilterChoiceChip(
                              initialValue: _bloc.adoptionDog.energyLevel,
                              onChanged: (String value) =>
                                  _bloc.adoptionDog.energyLevel = value,
                              title: 'Energy Level:',
                              values: ['Calm', 'Regular', 'Energetic'],
                            ),
                            Divider(),
                            FilterChoiceChip(
                              initialValue: _bloc.adoptionDog.barkTendencies,
                              onChanged: (String value) =>
                                  _bloc.adoptionDog.barkTendencies = value,
                              title: 'Barking Tendency:',
                              values: ['Rarely', 'Moderate', 'Vocalist'],
                            ),
                            Divider(),
                            FilterChoiceChip(
                              initialValue: _bloc.adoptionDog.sheddingLevel,
                              onChanged: (value) =>
                                  _bloc.adoptionDog.sheddingLevel = value,
                              title: 'Shedding Level:',
                              values: ['Little', 'Moderate', 'A lot'],
                            ),
                            Divider(),
                            FilterChoiceChip(
                              initialValue: _bloc.adoptionDog.trainingLevel,
                              onChanged: (String value) =>
                                  _bloc.adoptionDog.trainingLevel = value,
                              values: ['None', 'Basic', 'Advanced'],
                              title: 'Training Level:',
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: FilterCheckBox(
                                label: 'Pet Friendly',
                                initialValue: _bloc.adoptionDog.petFriendly,
                                onChanged: (bool value) =>
                                    _bloc.adoptionDog.petFriendly = value,
                              ),
                            ),
                            FilterCheckBox(
                              label: 'Appartment Friendly',
                              initialValue:
                                  _bloc.adoptionDog.appartmentFriendly,
                              onChanged: (bool value) =>
                                  _bloc.adoptionDog.appartmentFriendly = value,
                            ),
                            FilterCheckBox(
                              label: 'Vaccinated',
                              initialValue: _bloc.adoptionDog.vaccinated,
                              onChanged: (bool value) =>
                                  _bloc.adoptionDog.vaccinated = value,
                            ),
                            FilterCheckBox(
                              label: 'Pedigree',
                              initialValue: _bloc.adoptionDog.pedigree,
                              onChanged: (bool value) =>
                                  _bloc.adoptionDog.pedigree = value,
                            ),
                            Divider(),
                            DescriptionField(
                              onChanged: (String value) =>
                                  _bloc.description = value,
                            ),
                            LocationField(
                              Provider.of<LocalStorage>(context, listen: false)
                                  .getPostLocationData()
                                  .postDisplay,
                            ),
                            PhoneField(
                              onChanged: (number) =>
                                  _bloc.adoptionDog.owner.phoneNumber = number,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                                onPressed: () => _validateValues(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: StreamBuilder<PostAdditionState>(
                      stream: _bloc.state,
                      builder: (_, snapshot) {
                        return AnimatedCrossFade(
                          duration: Duration(milliseconds: 300),
                          crossFadeState:
                              snapshot.data == PostAdditionState.loading
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                          firstChild: Container(
                            color: yellowishColor.withOpacity(0.5),
                            child: SpinKitThreeBounce(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          secondChild: SizedBox.shrink(),
                        );
                      }),
                ),
              ],
            ),
          )),
    );
  }

  _validateValues() {
    if (_bloc.adoptionDog.age.isNotEmpty) {
      if (_nameKey.currentState.validate()) {
        if (_bloc.assetList.isNotEmpty) {
          _bloc.sendPostToAppBloc();
        } else {
          Scaffold.of(context).showSnackBar(
            errorSnackBar(
              'At least one photo for the dog should be added',
              duration: Duration(seconds: 4),
            ),
          );
          _pageScroller.animateTo(0.1,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic);
        }
      } else {
        _pageScroller.animateTo(0.1,
            duration: Duration(milliseconds: 200), curve: Curves.easeOutCubic);
      }
    } else {
      _pageScroller.animateTo(0.1,
          duration: Duration(milliseconds: 200), curve: Curves.easeOutCubic);
      Scaffold.of(context).showSnackBar(
        errorSnackBar(
          'Please specify the age',
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
