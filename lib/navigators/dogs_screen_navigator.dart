import 'package:dog_pal/bloc/add_adoption_dog_bloc.dart';
import 'package:dog_pal/bloc/add_lost_dog_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/post_details_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/screens/mate/add_mate_dog.dart';
import 'package:dog_pal/bloc/add_mate_dog_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/post_location_bloc.dart';
import 'package:dog_pal/screens/adopt/add_adoption_post.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/screens/lost/add_lost_dog.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_warning.dart';
import 'package:dog_pal/screens/post_location.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DogsScreenNavigator extends StatelessWidget {
  DogsScreenNavigator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    var appBloc = Provider.of<AppBloc>(context);
    var localStorage = Provider.of<LocalStorage>(context);
    var dogPostsBloc = Provider.of<DogPostsBloc>(context);
    var profileBloc = Provider.of<ProfileBloc>(context);

    return Navigator(
      observers: [
        HeroController(),
      ],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
          settings: setting,
          fullscreenDialog: setting.name == DogsScreenRoutes.POST_LOCATION,
          builder: (context) {
            switch (setting.name) {
              case DogsScreenRoutes.ADD_MATE_DOG:
                return Provider(
                  create: (_) => AddMateDogBloc(
                    appBloc,
                    localStorage,
                  ),
                  child: AddMateDogScreen(),
                );
                break;

              case DogsScreenRoutes.MATE_WARNING:
                return MateWarningScreen();
                break;

              case DogsScreenRoutes.MATE_DOG_WALL:
                assert(setting.arguments is MateDetailsArgs);
                return Provider(
                  create: (_) => PostDeletionBloc(
                    appBloc: appBloc,
                    profileBloc: profileBloc,
                    dogPostsBloc: dogPostsBloc,
                  ),
                  child: MateDogDetailsScreen(setting.arguments),
                );
                break;

              case DogsScreenRoutes.ADD_ADOPTION_POST:
                return Provider(
                  create: (_) => AddAdoptionDogBloc(appBloc, localStorage),
                  child: AddAdoptPostScreen(),
                );
                break;

              case DogsScreenRoutes.ADOPTION_DOG_WALL:
                assert(setting.arguments is AdoptDetailsArgs);
                return Provider(
                  create: (_) => PostDeletionBloc(
                    appBloc: appBloc,
                    profileBloc: profileBloc,
                    dogPostsBloc: dogPostsBloc,
                  ),
                  child: AdoptionDogWall(setting.arguments),
                );
                break;

              case DogsScreenRoutes.ADD_LOST_DOG:
                return Provider(
                  create: (_) => AddLostDogBloc(
                    appBloc,
                    localStorage,
                  ),
                  child: AddLostDogScreen(),
                );
                break;

              case DogsScreenRoutes.LOST_DOG_WALL:
                assert(setting.arguments is LostPost);
                return Provider(
                  create: (_) => PostDeletionBloc(
                    appBloc: appBloc,
                    profileBloc: profileBloc,
                    dogPostsBloc: dogPostsBloc,
                  ),
                  child: LostDogDetailsScreen(post: setting.arguments),
                );
                break;

              case DogsScreenRoutes.POST_LOCATION:
                assert(setting.arguments is Function(String));
                return Provider(
                  create: (_) => PostLocationBloc(localStorage),
                  child: PostLocation(
                    onLocationChanged: setting.arguments,
                  ),
                );
                break;

              default:
                return DogsScreen();
                break;
            }
          },
        );
      },
    );
  }
}

class DogsScreenRoutes {
  static const String ADD_MATE_DOG = '/addMateDog';
  static const String MATE_DOG_WALL = '/mateDogWall';
  static const String MATE_WARNING = '/mateWarning';
  static const String LOST_DOG_WALL = '/lostDetailsScreen';
  static const String ADD_LOST_DOG = '/addLostDog';
  static const String ADD_ADOPTION_POST = '/addAdoptionPost';
  static const String ADOPTION_DOG_WALL = '/adoptDogWall';
  static const String DOGS_SCREEN = '/dogsScreen';
  static const String POST_LOCATION = '/postLocation';
}
