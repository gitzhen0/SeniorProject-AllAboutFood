import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/recipe_data_service.dart';
import 'package:interactive_voice_for_cooking_recipes/view/app.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await runZonedGuarded(
    () async {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.debug, printer: PrettyPrinter(printTime: true)));
      GetIt.I.registerSingleton<RecipeDataService>(RecipeDataService(
        NetworkingConstants.addApiUrl,
        NetworkingConstants.getApiUrl,
        NetworkingConstants.deleteApiUrl,
      ));
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      GetIt.I.registerSingleton<AuthService>(AuthService());
      runApp(const App());
    },
    (error, stack) {
      GetIt.I<Logger>().e('Unexpected error!:', error, stack);
    },
  );
}
