import 'dart:io';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/auth_bloc.dart';
import 'package:dog_pal/bloc/decisions_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/screens/home.dart';
import 'package:dog_pal/screens/login.dart';
import 'package:dog_pal/screens/profile/profile_screen.dart';
import 'package:dog_pal/utils/decision_util.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:dog_pal/widgets/breed_filter_widget.dart';
import 'package:dog_pal/widgets/image_preview_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String HOME = '/homeScreen';
  static const String FULL_SCREEN_IMAGE = '/fullScreenImage';
  static const String TERMS_SCREEN = '/termsScreen';
  static const String AUTH_SCREEN = '/authScreen';
  static const String DECISIONS_SCREEN = '/decisionsScreen';
  static const String BREED_DIALOGE = '/breedDialoge';

  static Route onGenerateRoute(RouteSettings settings) {
    if (settings.name == FULL_SCREEN_IMAGE) {
      assert(settings.arguments is Widget);
      return Platform.isIOS
          ? TransparentRoute(builder: () => settings.arguments)
          : TransparentMaterialPageRoute(builder: (_) => settings.arguments);
    } else
      return MaterialPageRoute(
        fullscreenDialog: settings.name == AUTH_SCREEN ||
            settings.name == BREED_DIALOGE ||
            settings.name == DECISIONS_SCREEN,
        builder: (_) {
          switch (settings.name) {
            case DECISIONS_SCREEN:
              assert(settings.arguments is LocalStorage);
              return Provider<DecisionsBloc>(
                create: (_) => DecisionsBloc(settings.arguments),
                child: DecisionsScreen(),
              );
              break;

            case HOME:
              var localStorage = settings.arguments;
              var _dogPostsBloc = DogPostsBloc(localStorage: localStorage);
              var _profileBloc = ProfileBloc(localStorage: localStorage);
              var _appBloc = AppBloc(_dogPostsBloc);
              return MultiProvider(
                providers: [
                  Provider<DogPostsBloc>(
                    create: (_) => _dogPostsBloc,
                  ),
                  Provider<ProfileBloc>(
                    create: (_) => _profileBloc,
                  ),
                  Provider<AppBloc>(
                    create: (_) => _appBloc,
                  )
                ],
                child: Home(),
              );
              break;

            case BREED_DIALOGE:
              assert(settings.arguments is Function(String));
              return BreedsDialog(
                onBreedChosen: settings.arguments,
              );
              break;

            case AUTH_SCREEN:
              assert(settings.arguments is LocalStorage);
              return Provider(
                create: (_) => AuthBloc(settings.arguments),
                child: LoginScreen(),
              );
              break;

            case TERMS_SCREEN:
              return TermsScreen();
              break;

            default:
              print('App navigator returned a null route: ${settings.name}');
              return null;
          }
        },
      );
  }
}
