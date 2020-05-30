import 'dart:io';

import 'package:dog_pal/bloc/adopt_bloc.dart';
import 'package:dog_pal/models/adopt_post.dart';
import 'package:dog_pal/models/dog.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/laucnher_class.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/widgets/delete_post_button.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AdoptDetailsArgs {
  AdoptPost post;
  Function onDeletePressed;
  AdoptBloc bloc;
  int activeImageIndex;
  String heroTag;

  AdoptDetailsArgs({
    @required this.post,
    @required this.bloc,
    this.activeImageIndex,
    this.heroTag,
    this.onDeletePressed,
  });
}

class AdoptionDogWall extends StatefulWidget {
  AdoptionDogWall(
    this.args,
  );

  final AdoptDetailsArgs args;

  @override
  _AdoptionDogWallState createState() => _AdoptionDogWallState();
}

class _AdoptionDogWallState extends State<AdoptionDogWall> {
  int _imageScrollIndex;

  @override
  void initState() {
    _imageScrollIndex = widget.args.activeImageIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localStorage = Provider.of<LocalStorage>(context, listen: false);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (c, _) {
          return [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              expandedHeight: MediaQuery.of(context).size.height * 0.6,
              brightness: Brightness.light,
              leading: IconButton(
                icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: ImagePreview(
                  widget.args.post.dog.imagesUrls,
                  onChanged: (index) => _imageScrollIndex = index,
                  heroTag: widget.args.heroTag,
                  initialImage: _imageScrollIndex,
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.fromLTRB(21, 21, 21, 0),
          child: ListView(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _AdoptionDogDetails(widget.args.post.dog),
              ),
              Description(widget.args.post.description),
              OwnerInformation(user: widget.args.post.dog.owner),
              localStorage.isAuthenticated() &&
                      localStorage.getUser().uid ==
                          widget.args.post.dog.owner.uid
                  ? DeletePostButton(
                      post: widget.args.post,
                      onDeletePressed: widget.args.onDeletePressed,
                      bloc: widget.args.bloc,
                    )
                  : OwnerContactButton(widget.args.post.dog.owner),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerContactButton extends StatelessWidget {
  const OwnerContactButton(this.owner);
  final User owner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: RaisedButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (_) {
                return LaunchersOptions(
                  owner.phoneNumber ?? '',
                  owner.email ?? '',
                );
              });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Contact The Owner',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(44),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdoptionDogDetails extends StatelessWidget {
  const _AdoptionDogDetails(this.dog);
  final AdoptionDog dog;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DetailsTextPair(
          title: 'Age:  ',
          content: dog.age,
        ),
        Divider(),
        DetailsTextPair(
          title: 'Size: ',
          content: dog.size,
        ),
        Divider(),
        DetailsTextPair(
          title: 'Barking Tendency:  ',
          content: dog.barkTendencies,
        ),
        Divider(),
        DetailsTextPair(
          title: 'Shedding Level:  ',
          content: dog.sheddingLevel,
        ),
        Divider(),
        DetailsTextPair(
          title: 'Training Level:  ',
          content: dog.trainingLevel,
        ),
        Divider(),
        DetailsTextPair(
          title: 'Energy Level:  ',
          content: dog.energyLevel,
        ),
        Divider(),
        DetailsBools(
          title: 'Pet Friendly:  ',
          value: dog.petFriendly,
        ),
        Divider(),
        DetailsBools(
          title: 'Appartment Friendly:  ',
          value: dog.appartmentFriendly,
        ),
        Divider(),
        DetailsBools(
          title: 'Vaccinated:  ',
          value: dog.vaccinated,
        ),
        Divider(),
        DetailsBools(
          title: 'Pedigree:  ',
          value: dog.pedigree,
        ),
        Divider(),
      ],
    );
  }
}

class DetailsBools extends StatelessWidget {
  const DetailsBools({
    this.title,
    this.value,
  });
  final String title;
  final bool value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: blackishColor,
              fontSize: ScreenUtil().setSp(54),
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          value
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              : Icon(
                  Icons.cancel,
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}

class DetailsTextPair extends StatelessWidget {
  const DetailsTextPair({@required this.title, @required this.content});

  final String title;
  final String content;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: blackishColor,
              fontSize: ScreenUtil().setSp(54),
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(content,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: ScreenUtil().setSp(46),
              )),
        ],
      ),
    );
  }
}
