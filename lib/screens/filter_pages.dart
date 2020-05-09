import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/widgets/breed_filter_widget.dart';
import 'package:dog_pal/widgets/coat_color_filter_widget.dart';
import 'package:dog_pal/widgets/filter_choice_chip.dart';
import 'package:dog_pal/widgets/gender_filter_widget.dart';
import 'package:dog_pal/widgets/size_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

class AdoptFilterSheet extends StatelessWidget {
  const AdoptFilterSheet(this._bloc);
  final AdoptBloc _bloc;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTitle(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                children: <Widget>[
                  BreedFilterWidget(
                    orientation: WidgetOrientation.vertical,
                    initalBreed: _bloc.breed,
                    onChanged: (breed) => _bloc.breed = breed,
                  ),
                  Divider(),
                  GenderFilter(
                    onChanged: (value) => _bloc.gender = value,
                    initialValue: _bloc.gender,
                  ),
                  Divider(),
                  CoatColor(
                    onChanged: (colors) => _bloc.coatColors = colors,
                    initialColors: _bloc.coatColors,
                  ),
                  Divider(),
                  SizeFilter(
                    onChanged: (String size) => _bloc.size = size,
                    initialValue: _bloc.size,
                  ),
                  Divider(),
                  FilterChoiceChip(
                    initialValue: _bloc.energyLevel,
                    onChanged: (String value) => _bloc.energyLevel = value,
                    title: 'Energy Level:',
                    values: ['Calm', 'Regular', 'Energetic'],
                  ),
                  Divider(),
                  FilterChoiceChip(
                    initialValue: _bloc.barkTendencies,
                    onChanged: (String value) => _bloc.barkTendencies = value,
                    title: 'Barking Tendency:',
                    values: ['Rarely', 'Moderate', 'Vocalist'],
                  ),
                  Divider(),
                  FilterChoiceChip(
                    initialValue: _bloc.trainingLevel,
                    onChanged: (String value) => _bloc.trainingLevel = value,
                    values: ['None', 'Basic', 'Advanced'],
                    title: 'Training Level:',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: RaisedButton(
              onPressed: () {
                _bloc.getPosts();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Apply'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MateFilterPage extends StatelessWidget {
  const MateFilterPage(this._bloc);
  final MateBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildTitle(),
              Expanded(
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      BreedFilterWidget(
                        orientation: WidgetOrientation.vertical,
                        initalBreed: _bloc.breed,
                        onChanged: (breed) => _bloc.breed = breed,
                      ),
                      Divider(),
                      GenderFilter(
                        onChanged: (value) => _bloc.gender = value,
                        initialValue: _bloc.gender,
                      ),
                      Divider(),
                      CoatColor(
                        onChanged: (colors) => _bloc.colors = colors,
                        initialColors: _bloc.colors,
                      ),
                      Divider(),
                      SizeFilter(
                        onChanged: (String size) => _bloc.size = size,
                        initialValue: _bloc.size,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: RaisedButton(
                  onPressed: () {
                    _bloc.getPosts();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class LostFilterPage extends StatelessWidget {
  const LostFilterPage(this._bloc);

  final LostBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildTitle(),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView(
                children: <Widget>[
                  BreedFilterWidget(
                    orientation: WidgetOrientation.vertical,
                    initalBreed: _bloc.breed,
                    onChanged: (breed) => _bloc.breed = breed,
                  ),
                  Divider(),
                  GenderFilter(
                    onChanged: (value) => _bloc.gender = value,
                    initialValue: _bloc.gender,
                  ),
                  Divider(),
                  CoatColor(
                    onChanged: (colors) => _bloc.coatColors = colors,
                    initialColors: _bloc.coatColors,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: RaisedButton(
                onPressed: () {
                  _bloc.getPosts();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Apply'),
                ),
              ),
            )
          ],
        ),
      )
    ]);
  }
}

_buildTitle() {
  return Column(
    children: <Widget>[
      SizedBox(
        height: 3,
        width: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Filter',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(60),
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            color: blackishColor,
          ),
        ),
      ),
      Divider()
    ],
  );
}
