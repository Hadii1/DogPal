import 'package:dog_pal/bloc/mate_bloc.dart';
import 'package:dog_pal/models/mate_post.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/delete_post_button.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MateDetailsArgs {
  MatePost post;
  Function onDeletePressed;
  MateBloc bloc;
  int activeImageIndex;
  String heroTag;

  MateDetailsArgs({
    @required this.bloc,
    @required this.post,
    this.activeImageIndex,
    this.onDeletePressed,
    this.heroTag,
  });
}

class MateDogDetailsScreen extends StatefulWidget {
  const MateDogDetailsScreen(this.args);
  final MateDetailsArgs args;

  @override
  _MateDogDetailsScreenState createState() => _MateDogDetailsScreenState();
}

class _MateDogDetailsScreenState extends State<MateDogDetailsScreen> {
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
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
              brightness: Brightness.light,
              expandedHeight: MediaQuery.of(context).size.height * 0.6,
              flexibleSpace: FlexibleSpaceBar(
                background: ImagePreview(
                  widget.args.post.dog.imagesUrls,
                  initialImage: _imageScrollIndex,
                  onChanged: (index) => _imageScrollIndex = index,
                  heroTag: widget.args.heroTag,
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DetailsTextPair(
                        title: 'Age:  ',
                        content: widget.args.post.dog.age,
                      ),
                      Divider(),
                      DetailsTextPair(
                        title: 'Size: ',
                        content: widget.args.post.dog.size,
                      ),
                      Divider(),
                      DetailsBools(
                        title: 'Vaccinated:  ',
                        value: widget.args.post.dog.vaccinated,
                      ),
                      Divider(),
                      DetailsBools(
                        title: 'Pedigree:  ',
                        value: widget.args.post.dog.vaccinated,
                      ),
                      Divider()
                    ],
                  ),
                ),
                Description(widget.args.post.description),
                OwnerInformation(user: widget.args.post.dog.owner),
                localStorage.isAuthenticated() &&
                        localStorage.getUser().uid ==
                            widget.args.post.dog.owner.uid
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
