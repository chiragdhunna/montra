import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/blocs/account_bloc/account_bloc.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/budget_bloc/budget_bloc.dart';
import 'package:montra/logic/blocs/expense/expense_bloc.dart';
import 'package:montra/logic/blocs/export_data/export_data_bloc.dart';
import 'package:montra/logic/blocs/income_bloc/income_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';
import 'package:montra/logic/blocs/network_bloc/network_bloc.dart';
import 'package:montra/logic/blocs/transactions_bloc/transactions_bloc.dart';
import 'package:montra/logic/blocs/transfer_bloc/transfer_bloc.dart';
import 'package:montra/screens/on_boarding/on_boarding_screen.dart';
import 'package:montra/screens/on_boarding/upload_profile_screen.dart';
import 'package:montra/screens/splash/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/screens/user_screens/home.dart';

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
        BlocProvider<IncomeBloc>(create: (context) => IncomeBloc()),
        BlocProvider<ExpenseBloc>(create: (context) => ExpenseBloc()),
        BlocProvider<TransferBloc>(create: (context) => TransferBloc()),
        BlocProvider<TransactionsBloc>(create: (context) => TransactionsBloc()),
        BlocProvider<ExportDataBloc>(create: (context) => ExportDataBloc()),
        BlocProvider<BudgetBloc>(create: (context) => BudgetBloc()),
        BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<AuthenticationBloc>(
          create: (context) {
            final authBloc = AuthenticationBloc();
            authBloc.add(AuthenticationEvent.checkExisting());
            return authBloc;
          },
        ),
        BlocProvider<NetworkBloc>(
          create: (context) {
            final networkBloc = NetworkBloc();
            networkBloc.add(NetworkEvent.observer());
            return networkBloc;
          },
        ),
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
            state.maybeWhen(
              orElse: () {},
              success: () {
                ScaffoldMessenger.of(
                  navigatorKey.currentContext!,
                ).hideCurrentSnackBar();
                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(
                    content: Text('Back online!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              failure: () {
                ScaffoldMessenger.of(
                  navigatorKey.currentContext!,
                ).hideCurrentSnackBar();

                ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                  const SnackBar(
                    content: Text('No internet connection'),
                    backgroundColor: Colors.red,
                    duration: Duration(days: 1), // stays until online
                  ),
                );
              },
            );
          },
          child: BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              // TODO: implement listener
              state.maybeWhen(
                orElse: () {},
                authenticated: (user, authToken) {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => Home(user: user)),
                  );
                },
                unAuthenticated: () {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnBoardingScreen(),
                    ),
                  );
                },
                userImageUploaded: (user) {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => Home(user: user)),
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
                    MaterialPageRoute(builder: (context) => Home(user: user)),
                  );
                },
                failure: (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
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
