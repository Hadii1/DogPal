import 'dart:ui';
import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/user.dart';
import 'package:dog_pal/navigators/profile_navigator.dart';
import 'package:dog_pal/screens/login.dart';
import 'package:dog_pal/utils/general_functions.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/utils/privacy_policy.dart';
import 'package:dog_pal/utils/styles.dart';
import 'package:dog_pal/utils/terms_and_conditions.dart';
import 'package:dog_pal/utils/ui_functions.dart';
import 'package:dog_pal/widgets/fade_in_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileBloc _bloc;
  LocalStorage _localStorage;
  @override
  void initState() {
    _bloc = Provider.of<ProfileBloc>(context, listen: false);
    _localStorage = Provider.of<LocalStorage>(context, listen: false);

    _bloc.screenStateStream.listen(
      (state) {
        if (state == ProfileScreenState.error) {
          if (mounted) {
            Scaffold.of(context).showSnackBar(
              errorSnackBar(_bloc.errorMsg),
            );
          }
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ProfileScreenState>(
        stream: _bloc.screenStateStream,
        initialData: _localStorage.isAuthenticated()
            ? ProfileScreenState.authenticated
            : ProfileScreenState.unAuthenticated,
        builder: (_, AsyncSnapshot<ProfileScreenState> snapshot) {
          switch (snapshot.data) {
            case ProfileScreenState.loading:
              return _LoadingWidget();
              break;

            default:
              return ProfileWidget();
              break;
          }
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: yellowishColor.withOpacity(0.4),
          alignment: Alignment.center,
          child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }
}

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localStorage = Provider.of<LocalStorage>(context, listen: false);
    final profileBloc = Provider.of<ProfileBloc>(context, listen: false);
    return Fader(
      child: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _ProfileHeader(), // The header takes care of the user auth/unauth state preview
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32.0, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ProfileItem(
                        hideDivier: false,
                        iconData: MdiIcons.dogSide,
                        text: 'Posts',
                        onPressed: () {
                          localStorage.isAuthenticated()
                              ? Navigator.of(context)
                                  .pushNamed(ProfileRoutes.POSTS_SCREEN)
                              : Scaffold.of(context).showSnackBar(
                                  signInSnackBar(
                                    context,
                                    text: 'Sign in to add and view posts',
                                  ),
                                );
                        },
                      ),
                      _ProfileItem(
                        hideDivier: false,
                        iconData: Icons.favorite_border,
                        text: 'Favorites',
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(ProfileRoutes.FAVORTIES_SCREEN);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.settings,
                      color: blackishColor,
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'OpenSans',
                        fontSize: ScreenUtil().setSp(50),
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            _ProfileItem(
                              hideDivier: true,
                              iconData: MdiIcons.messageOutline,
                              text: 'Contact Us',
                              onPressed: () async => _contactUsPressed(context),
                            ),
                            _ProfileItem(
                              hideDivier: true,
                              iconData: Icons.list,
                              text: 'Terms',
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(ProfileRoutes.TERMS_SCREEN),
                            ),
                            _ProfileItem(
                              hideDivier: true,
                              iconData: MdiIcons.fileDocumentBoxOutline,
                              text: 'Privacy Policy',
                              onPressed: () => Navigator.of(context).pushNamed(
                                  ProfileRoutes.PRIVACY_POLICY_SCREEN),
                            ),
                            _ProfileItem(
                              hideDivier: true,
                              iconData: Icons.people_outline,
                              text: 'Credentials',
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(ProfileRoutes.CREDENTIALS_SCREEN),
                            ),
                            localStorage.isAuthenticated()
                                ? _ProfileItem(
                                    hideDivier: true,
                                    iconData: Icons.keyboard_return,
                                    text: 'Sign Out',
                                    onPressed: () =>
                                        profileBloc.signOutPressed(),
                                  )
                                : _ProfileItem(
                                    hideDivier: true,
                                    iconData: MdiIcons.login,
                                    text: 'Sign in',
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .push(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (c) {
                                          return Provider(
                                            create: (_) =>
                                                AuthBloc(localStorage),
                                            child: LoginScreen(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                            localStorage.isAuthenticated()
                                ? _ProfileItem(
                                    hideDivier: true,
                                    iconData: Icons.delete,
                                    text: 'Delete Account',
                                    onPressed: () async {
                                      showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              title: Text('Warning'),
                                              content: Text(
                                                  'Are you sure you want to delete all your posts and data?'),
                                              actions: <Widget>[
                                                FlatButton(
                                                    child: Text(
                                                      'Confirm',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                      profileBloc
                                                          .deleteAccountPressed();
                                                    }),
                                                FlatButton(
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .accentColor),
                                                  ),
                                                  onPressed: () => Navigator.of(
                                                          context,
                                                          rootNavigator: true)
                                                      .pop(),
                                                )
                                              ],
                                            );
                                          });
                                    })
                                : SizedBox.shrink()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactUsPressed(BuildContext context) async {
    if (await canLaunch('mailto:dogpalteam@outlook.com').timeout(
      Duration(seconds: 3),
      onTimeout: () => false,
    )) {
      launch('mailto:dogpalteam@outlook.com');
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Please use this email to contact us:\n',
                  style: TextStyle(
                    color: blackishColor,
                    fontSize: ScreenUtil().setSp(44),
                  ),
                ),
                TextSpan(
                  text: 'dogpalteam@outlook.com',
                  style: TextStyle(
                    color: Color(0xff007A7D),
                    fontWeight: FontWeight.w500,
                    fontSize: ScreenUtil().setSp(44),
                  ),
                ),
              ],
            ),
          ),
          action: SnackBarAction(
              label: 'Copy',
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: 'dogpalteam@outlook.com',
                  ),
                );
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 2),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Copied',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(44),
                          ),
                        ),
                        Icon(
                          Icons.check_box,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      );
    }
  }
}

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: blackishColor,
        ),
        title: Text(
          'TERMS & CONDITIONS',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              TERMS,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: ScreenUtil().setSp(42),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CredentialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credentials'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: blackishColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(44),
                          color: Colors.black87,
                        ),
                        text:
                            '''This project is developed and maintained on personal efforts. As it is with most individual software projects, the project makes use of many open source libraries and graphical content that was given for the world to enjoy. Here we mention some of these uses: ''',
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: ScreenUtil().setSp(42),
                        ),
                        children: [
                          TextSpan(
                              text:
                                  '• The tips to consider before adding your dog to mating was written by'),
                          TextSpan(
                              style: TextStyle(fontWeight: FontWeight.bold),
                              text: ' Dobie Houson.'),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: ScreenUtil().setSp(42),
                        ),
                        children: [
                          TextSpan(
                              text:
                                  '• Most graphical content including the dog vectors was designed by'),
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _launchUrl(
                                  context, 'https://www.freepik.com/home'),
                            text: ' Freepik.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: ScreenUtil().setSp(42),
                          ),
                          children: [
                            TextSpan(
                                text:
                                    '• The cautious dog and the good doggy images were designed by:'),
                            TextSpan(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchUrl(
                                    context, 'https://www.freepik.com/stories'),
                              text: ' Stories / Freepik .',
                            ),
                          ]),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: ScreenUtil().setSp(42),
                        ),
                        children: [
                          TextSpan(
                              text:
                                  '• The image shown while fetching location was designed by'),
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _launchUrl(context,
                                  'https://www.freepik.com/rawpixel-com'),
                            text: ' rawpixel / Freepik .',
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: ScreenUtil().setSp(42),
                          ),
                          children: [
                            TextSpan(
                                text:
                                    '• Gratitude and appreciation for google and especially the'),
                            TextSpan(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    _launchUrl(context, 'https://dart.dev/'),
                              text: ' Dart ',
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    _launchUrl(context, 'https://flutter.dev/'),
                              text: ' Flutter ',
                            ),
                            TextSpan(
                                text:
                                    'teams for their great framework that we used for building this project.'),
                          ]),
                    ),
                  )
                ],
              ),
            ),
            Text(
              'if you beleive that we\'re missing something that relates to you or someone you know, please do contact us at: dogpalteam@outlook.com ',
              style: TextStyle(
                color: Colors.grey,
                fontSize: ScreenUtil().setSp(34),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    print('launching ');
    if (await canLaunch(url)) {
      launch(url);
    } else {
      Scaffold.of(context)
          .showSnackBar(errorSnackBar(''' Couldn't launch url'''));
    }
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(),
          color: blackishColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            PRIVACY_POLICY,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(42),
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localStorage = Provider.of<LocalStorage>(context, listen: false);

    final user = localStorage.getUser();

    return Material(
      elevation: 2,
      color: yellowishColor,
      child: PreferredSize(
        preferredSize: const Size(double.maxFinite, kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        (() {
                          if (localStorage.isAuthenticated()) {
                            return user != null
                                ? user.firstName ?? user.username ?? ''
                                : '';
                          } else {
                            return 'Anonymous';
                          }
                        })(),
                        softWrap: true,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(66),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                          color: blackishColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: localStorage.isAuthenticated()
                          ? Text(
                              user == null ? '' : user.email ?? '',
                              style: dogBreedStyle.copyWith(
                                fontSize: ScreenUtil().setSp(50),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Container(),
                    ),
                    InkWell(
                      onTap: () {
                        if (!localStorage.isAuthenticated()) {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (_) {
                                return Provider(
                                  create: (_) => AuthBloc(localStorage),
                                  child: LoginScreen(),
                                );
                              },
                            ),
                          );
                        }
                      },
                      child: Text(
                        localStorage.isAuthenticated()
                            ? 'Joined in ${getMonth(user.dataJoined.month)} - ${user.dataJoined.year}'
                            : 'Sign in to unlock you profile',
                        softWrap: true,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(42),
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: blackishColor,
                      backgroundImage: localStorage.isAuthenticated()
                          ? ExtendedImage.network(user.photo).image
                          : null,
                      child: localStorage.isAuthenticated()
                          ? user.photo.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: yellowishColor,
                                  size: 35,
                                )
                              : SizedBox.shrink()
                          : Icon(
                              Icons.person,
                              color: yellowishColor,
                              size: 35,
                            ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    @required this.iconData,
    @required this.text,
    @required this.onPressed,
    @required this.hideDivier,
  });
  final IconData iconData;
  final String text;
  final Function() onPressed;
  final bool hideDivier;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(52),
                    fontWeight: FontWeight.w300,
                    color: blackishColor),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(
                  iconData,
                  size: 24,
                  color: blackishColor.withAlpha(230),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: hideDivier
                ? Container(
                    padding: const EdgeInsets.all(8),
                  )
                : Divider(),
          ),
        ],
      ),
    );
  }
}