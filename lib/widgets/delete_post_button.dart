import 'dart:io';

import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:dog_pal/utils/firestore_util.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class DeletePostButton extends StatefulWidget {
  const DeletePostButton({
    @required this.bloc,
    @required this.post,
    this.onDeletePressed,
  });
  final DogPost post;
  final Function onDeletePressed;
  final DogPostsBloc bloc;

  @override
  _DeletePostButtonState createState() => _DeletePostButtonState();
}

class _DeletePostButtonState extends State<DeletePostButton> {
  DogPost get _post => widget.post;

  bool _isLoading = false;

  LocalStorage _localStorage;

  @override
  void initState() {
    _localStorage = Provider.of<LocalStorage>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24, top: 24),
      child: FlatButton(
        color: blackishColor,
        splashColor: Theme.of(context).accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        onPressed: () async {
          if (!_isLoading) {
            if (widget.post.dog.owner.uid == _localStorage.getUser().uid) {
              _deletePost();
            } else {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Something went wrong'),
                ),
              );
            }
          } else {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('In progress'),
              ),
            );
          }
        },
        child: AnimatedCrossFade(
          crossFadeState:
              _isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: SpinKitThreeBounce(
            color: yellowishColor,
            size: 25,
          ),
          secondChild: Text(
            'Delete Post',
          ),
          duration: Duration(milliseconds: 150),
        ),
      ),
    );
  }

  Future<void> _deletePost() async {
    setState(() {
      _isLoading = true;
    });

    FirestoreService firestoreUtil = FirestoreService();

    String collectionName;

    switch (_post.type) {
      case 'lost':
        collectionName = FirestoreConsts.LOST_DOGS;
        break;
      case 'adopt':
        collectionName = FirestoreConsts.ADOPTION_DOGS;
        break;
      case 'mate':
        collectionName = FirestoreConsts.MATE_DOGS;
        break;
    }

    if (await isOnline()) {
      try {
        await firestoreUtil.deletePost(
          id: _post.id,
          collection: collectionName,
        );

        //notify the user of success

        AppBloc appBloc = Provider.of<AppBloc>(context, listen: false);
        appBloc.notificationsSender.sink.add(
          SnackBar(
            duration: Duration(seconds: 3),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Post Deleted'),
                Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        );

        //Remove from the user favorites if exists
        if (_localStorage.getFavorites().containsKey(_post.id)) {
          _localStorage.editFavorites(_post.id, _post.type);

          firestoreUtil.saveUserFavs(
              _localStorage.getFavorites(), _localStorage.getUser().uid);
        }

        //delete images in storage
        firestoreUtil.deleteImages(_post.dog.imagesUrls.cast<String>());

        //refresh the list
        widget.bloc.getPosts();

        //any other functionality is passed(mainly from user posts screen or favs screen)
        if (widget.onDeletePressed != null) {
          widget.onDeletePressed();
        }

        Navigator.pop(context);
      } on PlatformException catch (e) {
        print(e.message ?? e.code);

        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            'We\'re having some errors on our side',
            duration: Duration(seconds: 3),
            onRetry: () => _deletePost(),
          ),
        );
      } on SocketException {
        Scaffold.of(context).showSnackBar(
          errorSnackBar(
            'Poor Internet Connection',
            duration: Duration(seconds: 3),
            onRetry: () => _deletePost(),
          ),
        );
      }
    } else {
      Scaffold.of(context).showSnackBar(
        noConnectionSnackbar(),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
}
