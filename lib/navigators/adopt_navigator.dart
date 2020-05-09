import 'package:dog_pal/bloc/add_adoption_dog_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/screens/adopt/add_adoption_post.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdoptRoutes {
  static const String ADD_ADOPTION_POST = '/addAdoptionPost';
  static const String ADOPT_SCREEN = '/adoptScreen';
  static const String ADOPTION_DOG_WALL = '/adoptDogWall';
  static const String EXAMPLE = '/example';
}

class AdoptNavigator extends StatelessWidget {
  AdoptNavigator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
          settings: setting,
          builder: (_) {
            switch (setting.name) {
              case AdoptRoutes.ADD_ADOPTION_POST:
                return Provider(
                  create: (_) => AddAdoptionDogBloc(
                    Provider.of<AppBloc>(context, listen: false),
                    Provider.of<LocalStorage>(context, listen: false),
                  ),
                  child: AddAdoptPostScreen(),
                );
                break;

              case AdoptRoutes.ADOPTION_DOG_WALL:
                assert(setting.arguments is AdoptDetailsArgs);
                return AdoptionDogWall(setting.arguments);
                break;

              default:
                return DogsScreen(
                  postType: PostType.adopt,
                );
            }
          },
        );
      },
    );
  }
}
