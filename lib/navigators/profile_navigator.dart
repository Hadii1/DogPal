import 'package:dog_pal/bloc/app_bloc.dart';
import 'package:dog_pal/bloc/dog_posts_bloc.dart';
import 'package:dog_pal/bloc/post_details_bloc.dart';
import 'package:dog_pal/bloc/profile_bloc.dart';
import 'package:dog_pal/models/lost_post.dart';
import 'package:dog_pal/navigators/dogs_screen_navigator.dart';
import 'package:dog_pal/screens/adopt/adoption_dog_details.dart';
import 'package:dog_pal/screens/lost/lost_dog_details_screen.dart';
import 'package:dog_pal/screens/mate/mate_details_screen.dart';
import 'package:dog_pal/screens/profile/favorites_screen.dart';
import 'package:dog_pal/screens/profile/posts_Screen.dart';
import 'package:dog_pal/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileRoutes {
  static const String PROFILE_SCREEN = '/profileScreen';
  static const String POSTS_SCREEN = '/postsScreen';
  static const String FAVORTIES_SCREEN = '/favoritesScreen';
  static const String TERMS_SCREEN = '/termsScreen';
  static const String PRIVACY_POLICY_SCREEN = '/privacyPolicy';
  static const String CREDENTIALS_SCREEN = '/credetials';
}

class ProfileNavigator extends StatelessWidget {
  ProfileNavigator(this.navigatorKey);
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    var appBloc = Provider.of<AppBloc>(context);
    var dogPostsBloc = Provider.of<DogPostsBloc>(context);
    var profileBloc = Provider.of<ProfileBloc>(context);

    return Navigator(
      observers: [HeroController()],
      key: navigatorKey,
      onGenerateRoute: (RouteSettings setting) {
        return MaterialPageRoute(
          settings: setting,
          builder: (context) {
            switch (setting.name) {
              case DogsScreenRoutes.LOST_DOG_WALL:
                assert(setting.arguments is LostPost);
                return Provider(
                  create: (_) => PostDeletionBloc(
                    appBloc: appBloc,
                    profileBloc: profileBloc,
                    dogPostsBloc: dogPostsBloc,
                  ),
                  child: LostDogDetailsScreen(post:setting.arguments),
                );
                break;

              case ProfileRoutes.TERMS_SCREEN:
                return TermsScreen();
                break;

              case ProfileRoutes.PRIVACY_POLICY_SCREEN:
                return PrivacyPolicyScreen();
                break;

              case ProfileRoutes.CREDENTIALS_SCREEN:
                return CredentialsScreen();
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

              case ProfileRoutes.POSTS_SCREEN:
                return PostsScreen();
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

              case ProfileRoutes.FAVORTIES_SCREEN:
                return FavoritesScreen();
                break;

              default:
                return ProfileScreen();
                break;
            }
          },
        );
      },
    );
  }
}
