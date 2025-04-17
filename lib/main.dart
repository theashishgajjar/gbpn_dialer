import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbpn_dealer/helpers/call_manager.dart';
import 'package:gbpn_dealer/services/firebase_options.dart';
import 'package:gbpn_dealer/services/firebase_service.dart';
import 'package:gbpn_dealer/services/twilio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseService().initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  bool isFirstLaunch = await _checkFirstLaunch();
  runApp(MyApp(initialRoute: isFirstLaunch ? '/intro' : '/splash'));
}

Future<bool> _checkFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstLaunch') ?? true;
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final TwilioService _twilioService = TwilioService();
  final CallManager _callManager = CallManager();


  @override
  void initState() {
    super.initState();
    // Initialize CallManager after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get BuildContext from the navigator key
      final context = navigatorKey.currentContext;
      if (context != null) {
        _callManager.initialize(context);
      }
    });
  }
  
  @override
  void dispose() {
    _callManager.dispose();
    _twilioService.dispose();
    super.dispose();
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,

      theme: ThemeData(
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Container(
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: widget.initialRoute,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
