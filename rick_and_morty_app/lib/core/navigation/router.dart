import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/core/navigation/routes.dart';
import 'package:rick_and_morty_app/data/repositories/character_repositories_imple.dart';
import 'package:rick_and_morty_app/presentation/screens/home/cubits/character_cubit.dart';
import 'package:rick_and_morty_app/presentation/screens/home/home_screen.dart';
import 'package:http/http.dart' as http;

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return AppTransition.slide(child: buildHomeScreen());
      default:
        return AppTransition.none(child: const SizedBox.shrink());
    }
  }

  static Widget buildHomeScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CharacterCubit(
            CharacterRepositoryImpl(client: http.Client()),
          )..loadCharacters(),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}

class AppTransition {
  static PageRouteBuilder none({
    required Widget child,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  static PageRouteBuilder slide({
    required Widget child,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var slideAnimation = animation.drive(tween);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}
