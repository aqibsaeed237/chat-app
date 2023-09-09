import 'package:flutter/material.dart';

//Packages
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/navigation.service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_services.dart';

class SplashPages extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPages({
    required Key key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  _SplashPageState createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPages> {
  @override
  void initState() {
    super.initState();
    _setup().then((_) => widget.onInitializationComplete);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      theme: ThemeData(
        // ignore: deprecated_member_use
        backgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
        scaffoldBackgroundColor: const Color.fromRGBO(36, 35, 49, 1.0),
      ),
      home: Scaffold(
        body: Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/logo.png'))),
            )),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _registerServices();
  }

  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(
      NavigationService(),
    );
    GetIt.instance.registerSingleton<MediaSevice>(
      MediaSevice(),
    );
    GetIt.instance.registerSingleton<CloudStorageService>(
      CloudStorageService(),
    );
    GetIt.instance.registerSingleton<DatabaseService>(
      DatabaseService(),
    );
  }
}