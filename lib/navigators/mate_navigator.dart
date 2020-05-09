import 'package:dog_pal/bloc/add_mate_dog.dart';
import 'package:dog_pal/bloc/add_mate_dog_bloc.dart';
import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/models/dog_post_mode.dart';
import 'package:dog_pal/screens/dogs_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_warning.dart';
import 'package:dog_pal/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MateNavigator extends StatelessWidget {
  MateNavigator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
            settings: setting,
            builder: (context) {
              switch (setting.name) {
                case MateRoutes.ADD_MATE_DOG:
                  return Provider(
                    create: (_) => AddMateDogBloc(
                        Provider.of<AppBloc>(context, listen: false),
                        Provider.of<LocalStorage>(context, listen: false)),
                    child: AddMateDogScreen(),
                  );
                  break;

                case MateRoutes.MATE_WARNING:
                  return MateWarningScreen();
                  break;

                case MateRoutes.MATE_DOG_WALL:
                  assert(setting.arguments is MateDetailsArgs);
                  return MateDogDetailsScreen(setting.arguments);
                  break;

                default:
                  return DogsScreen(
                    postType: PostType.mate,
                  );
              }
            });
      },
    );
  }
}

class MateRoutes {
  static const String ADD_MATE_DOG = '/addMateDog';
  static const String MATE_DOG_WALL = '/mateDogWall';
  static const String MATE_WARNING = '/mateWarning';
}
