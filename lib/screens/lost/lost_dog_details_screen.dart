import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_pal/bloc/lost_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/widgets/delete_post_button.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LostDetailsArgs {
  LostPost post;
  Function onDeletePressed;
  LostBloc bloc;

  LostDetailsArgs({
    @required this.post,
    @required this.bloc,
    this.onDeletePressed,
  });
}

class LostDogDetailsScreen extends StatefulWidget {
  LostDogDetailsScreen(this.args);
  final LostDetailsArgs args;

  @override
  _LostDogDetailsScreenState createState() => _LostDogDetailsScreenState();
}

class _LostDogDetailsScreenState extends State<LostDogDetailsScreen> {
  int _imageScrollIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localStorage = Provider.of<LocalStorage>(context, listen: false);
    final user = localStorage.getUser();
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (c, _) {
          return [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              brightness: Brightness.light,
              expandedHeight: MediaQuery.of(context).size.height * 0.6,
              flexibleSpace: FlexibleSpaceBar(
                background: ImagePreview(
                  widget.args.post.dog.imagesUrls,
                  onChanged: (index) => _imageScrollIndex = index,
                  initialImage: _imageScrollIndex,
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(21, 21, 21, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NameAndBreedDetails(
                  widget.args.post.dog.dogName,
                  widget.args.post.dog.breed,
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LocationLost(widget.args.post),
                      DateAdded(widget.args.post.dateAdded),
                      Gender(widget.args.post.dog.gender),
                      CoatColors(widget.args.post.dog.coatColors),
                    ],
                  ),
                ),
                Description(widget.args.post.description),
                OwnerInformation(user: widget.args.post.dog.owner),
                localStorage.isAuthenticated() &&
                        user.uid == widget.args.post.dog.owner.uid
                    ? DeletePostButton(
                        bloc: widget.args.bloc,
                        post: widget.args.post,
                        onDeletePressed: widget.args.onDeletePressed,
                      )
                    : OwnerContactButton(widget.args.post.dog.owner),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoatColors extends StatelessWidget {
  const CoatColors(this.colors);
  final List colors;

  @override
  Widget build(BuildContext context) {
    List<TextSpan> texts = [];
    //Last color wouldn't have a comma after it
    for (int i = 0; i < colors.length; i++) {
      i == colors.length - 1
          ? texts.add(TextSpan(text: '${colors[i]}'))
          : texts.add(TextSpan(text: '${colors[i]}, '));
    }
    return colors.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.invert_colors,
                      color: blackishColor,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: ScreenUtil().setSp(44),
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w600,
                        ),
                        children: texts),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}

class Description extends StatelessWidget {
  const Description(this.description);
  final String description;

  @override
  Widget build(BuildContext context) {
    return description != null && description.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              description,
              style: normalTextStyle,
              softWrap: true,
            ),
          )
        : Container();
  }
}

class Gender extends StatelessWidget {
  const Gender(this.gender);
  final String gender;

  @override
  Widget build(BuildContext context) {
    assert(gender != null);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                gender == 'Female'
                    ? MdiIcons.genderFemale
                    : MdiIcons.genderMale,
                color: blackishColor,
              ),
            ),
            Text(
              gender,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(44),
              ),
            ),
          ],
        ));
  }
}

class LocationLost extends StatelessWidget {
  const LocationLost(this.post);
  final DogPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.location_on,
              color: blackishColor,
            ),
          ),
          Expanded(
              child: Text(
            'at ${post.locationDisplay ?? post.town ?? post.city ?? post.district}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(44),
            ),
            softWrap: true,
          )),
        ],
      ),
    );
  }
}

class OwnerInformation extends StatelessWidget {
  const OwnerInformation({this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Owner Details:',
              style: TextStyle(
                color: blackishColor,
                fontSize: ScreenUtil().setSp(64),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: ScreenUtil().setSp(44),
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '• Email :\n',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: '  ${user.email}\n\n',
                      ),
                      if (user.phoneNumber != null &&
                          user.phoneNumber.isNotEmpty)
                        TextSpan(text: '• Phone :\n'),
                      if (user.phoneNumber != null &&
                          user.phoneNumber.isNotEmpty)
                        TextSpan(text: '  ${user.phoneNumber}'),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          user.photo != null && user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                      child: user.photo != null && user.photo.isNotEmpty
                          ? SizedBox.shrink()
                          : Icon(
                              Icons.person,
                              color: blackishColor,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user.username,
                        textAlign: TextAlign.center,
                        style: normalTextStyle,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DateAdded extends StatelessWidget {
  const DateAdded(this.timestamp);
  final Timestamp timestamp;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.date_range,
            color: blackishColor,
          ),
        ),
        Text(
          'added in ${getMonth(timestamp.toDate().month)} ${timestamp.toDate().day}',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(44),
          ),
        )
      ]),
    );
  }
}

class NameAndBreedDetails extends StatelessWidget {
  const NameAndBreedDetails(this.name, this.breed);
  final String name;
  final String breed;

  @override
  Widget build(BuildContext context) {
    return RichText(
      softWrap: true,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$name\n',
            style: dogNameStyle,
          ),
          TextSpan(
            text: '$breed\n',
            style: dogBreedStyle,
          ),
        ],
      ),
    );
  }
}
