import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';
import 'package:montra/logic/blocs/network_bloc/network_bloc.dart';
import 'package:montra/screens/on_boarding/on_boarding_screen.dart';
import 'package:montra/screens/on_boarding/upload_profile_screen.dart';
import 'package:montra/screens/splash/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/screens/user%20screens/home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<AuthenticationBloc>(
          create: (context) {
            final authBloc = AuthenticationBloc();
            authBloc.add(AuthenticationEvent.checkExisting());
            return authBloc;
          },
        ),
        BlocProvider<NetworkBloc>(create: (context) => NetworkBloc()),
      ],
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loginSuccess: () {},
            loginFail: () {},
            inProgress: () {},
          );
        },
        child: BlocListener<NetworkBloc, NetworkState>(
          listener: (context, state) {
            // TODO: implement listener
            state.maybeWhen(orElse: () {}, success: () {}, failure: () {});
          },
          child: BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              // TODO: implement listener
              state.maybeWhen(
                orElse: () {},
                authenticated: (user, authToken) {},
                unAuthenticated: () {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnBoardingScreen(),
                    ),
                  );
                },
                userImageUploaded: () {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                userSignedUp: () {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const UploadImageScreen(),
                    ),
                  );
                },
                userLoggedIn: (user, authToken) {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
              );
            },
            child: ScreenUtilInit(
              builder:
                  (_, child) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    navigatorKey: navigatorKey,
                    title: 'Montra',
                    theme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: Colors.deepPurple,
                      ),
                    ),
                    home: SplashScreen(),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
