import 'package:chatapp/providers/authentication_provider.dart';
import 'package:flutter/material.dart';

//Packages
import 'package:firebase_analytics/firebase_analytics.dart';

//Provider
import 'package:provider/provider.dart';

//Pages
import './pages/splash_pages.dart';
import './pages/login_page.dart';
import './pages/home_page.dart';
import './pages/register_page.dart';

//Services
import './services/navigation.service.dart';

void main() {
  runApp(
    SplashPages(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(
          MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext context) {
            return AuthenticationProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          // ignore: deprecated_member_use
          backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: 'login',
        routes: {
          '/login': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
          '/home': (BuildContext context) => HomePage(),
        },
      ),
    );
  }
}
