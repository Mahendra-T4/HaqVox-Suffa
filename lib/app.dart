import 'package:haqvox/app/constant/constant.dart';
import 'package:haqvox/app/core/router/router_config.dart';
import 'package:haqvox/app/src/screens.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HaqVox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: whiteColor,
        fontFamily: 'Rubik',
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 2,
          iconTheme: IconThemeData(color: whiteColor),
        ),
      ),
      routerConfig: Config.router,
    );
  }
}
