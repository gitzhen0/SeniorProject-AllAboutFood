import 'package:flutter/material.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: MaterialApp(
          title: AppText.appTitle,
          theme: ThemeData(
            // hintColor: Colors.red,

            scaffoldBackgroundColor: Colors.white,
            inputDecorationTheme: const InputDecorationTheme(
              floatingLabelStyle: TextStyle(
                // color: Color.fromARGB(255, 112, 185, 190),
                color: Color.fromARGB(255, 10, 37, 51),
              ),
              enabledBorder: OutlineInputBorder(
                // borderRadius: BorderRadius.circular(10.5),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                borderSide: BorderSide(
                  width: 3,
                  color: Color.fromARGB(255, 230, 235, 242),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                borderSide: BorderSide(
                  width: 3,
                  color: Color.fromARGB(255, 230, 235, 242),
                  // color: Color.fromARGB(255, 112, 185, 190),
                ),
              ),
            ),
            // primaryColor: const Color.fromARGB(235, 0, 8, 101),
            backgroundColor: const Color.fromARGB(0, 249, 145, 0),
          ),
          home: const HomeScreen(),
          // home: const SearchScreen(),
          // Changed entrance here
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.textScaleFactor.clamp(0.75, 1.25);
            return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: scale), child: child!);
          },
        ),
      ),
    );
  }
}
