import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fraction/fraction.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

class RecipeDataService {
  final String _addRecipeApiUrl;
  final String _getRecipeApiUrl;
  final String _deleteRecipeApiUrl;

  Client? _client;
  Uuid? uuid;

  RecipeDataService(
    this._addRecipeApiUrl,
    this._getRecipeApiUrl,
    this._deleteRecipeApiUrl,
  ) {
    _client = Client();
    uuid = const Uuid();
  }

  Future<Response> uploadImageToDatabase(XFile? image, String uid) async {
    Uint8List imageRep = await image?.readAsBytes() ?? Uint8List(0);
    final Response response = await _client?.put(
          Uri.parse(
            'https://r2addxo0ji.execute-api.us-east-1.amazonaws.com/v1/recipephotosrick/$uid',
          ),
          headers: <String, String>{},
          body: imageRep,
        ) ??
        Response('', 500);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to upload image');
    }

    return response;
  }

  Future<Response> addRecipeToDatabase(Recipe r) async {
    final Response response = await _client?.post(
          Uri.parse(
            _addRecipeApiUrl,
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: await _constructRecipeDatabaseObject(r),
        ) ??
        Response('', 500);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add recipe');
    }

    return response;
  }

  Future<Response> updateRecipeInDatabase(Recipe r) async {
    final Response response = await _client?.post(
          Uri.parse(
            _addRecipeApiUrl,
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: await _constructRecipeDatabaseObject(r),
        ) ??
        Response('', 500);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to edit recipe');
    }

    return response;
  }

  Future<Response> deleteRecipeFromDatabase(Recipe r) async {
    final Response response = await _client?.post(
          Uri.parse(
            _deleteRecipeApiUrl,
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: '{"${AppText.uuidKey}": "${r.uid}", "Token":"${await GetIt.I<AuthService>().getAuthToken()}"}',
        ) ??
        Response('', 500);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete recipe');
    }

    return response;
  }

  Future<List<Recipe>> getAllRecipes() async {
    List<Recipe> recipes = [];
    final Response getResponse = await _client?.post(
          Uri.parse(
            _getRecipeApiUrl,
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: '{"Token":"${await GetIt.I<AuthService>().getAuthToken()}"}',
        ) ??
        Response('', 500);

    if (getResponse.statusCode == HttpStatus.ok) {
      final recipeJson = getResponse.body.codeUnits;

      final decoded = json.decode(const Utf8Decoder().convert(recipeJson));
      for (Map recipe in decoded) {
        Recipe toAdd = _constructRecipeDataObject(recipe);
        recipes.add(toAdd);
      }
    }

    return recipes;
  }

  Recipe _constructRecipeDataObject(Map r) {
    List dirs = r[AppText.directionsKey] ?? [];
    List ings = r[AppText.ingredientsKey] ?? [];
    List chars = r[AppText.characteristicsKey] ?? [];
    List links = r[AppText.linksKey] ?? [];
    List pairs = r[AppText.pairsWithKey] ?? [];
    List<RecipeStep> steps = dirs.map((e) => RecipeStep(description: e)).toList();
    List<RecipeIngredient> ingredients = ings
        .map((e) => RecipeIngredient(
            ingredient: e[0],
            amount: double.parse(e[1].toString()) == -1 ? null : double.parse(e[1].toString()),
            unit: e[2],
            displayAmount: double.parse(e[1].toString()) == -1 ? '' : Fraction.fromDouble(double.parse(e[1].toString())).toString()))
        .toList();

    String title = r[AppText.recipeNameKey] ?? '';

    bool public = r[AppText.publicKey] ?? true;
    String uuid = r[AppText.uuidKey] ?? '';
    String accountId = r[AppText.accountIdKey] ?? '';
    Duration prepTime = Duration(minutes: r[AppText.prepTimeKey] ?? 0);
    Duration activeTime = Duration(minutes: r[AppText.activeTimeKey] ?? 0);
    Duration totalTime = Duration(minutes: r[AppText.totalTimeKey] ?? 0);
    Duration cookTime = Duration(minutes: r[AppText.cookTimeKey] ?? 0);

    String type = r[AppText.typeKey] ?? '';
    List<String> characteristics = chars.map((e) => e.toString()).toList();
    String description = r[AppText.descriptionKey] ?? '';
    String summary = r[AppText.summaryKey] ?? '';
    String videoLink = r[AppText.videoLinkKey] ?? '';
    List<String> recipeLinks = links.map((e) => e.toString()).toList();
    List<String> pairsWith = pairs.map((e) => e.toString()).toList();
    String imageUrl = r[AppText.imageUrlKey] ?? '';
    String source = r[AppText.sourceKey] ?? '';
    String nutrition = r[AppText.nutritionKey] ?? '';
    String equipment = r[AppText.equipmentKey] ?? '';
    double servings = checkDouble(r[AppText.servingsKey]);

    Recipe toReturn = Recipe(
      title: title,
      steps: steps,
      ingredients: ingredients,
      cookTime: cookTime,
      public: public,
      uid: uuid,
      ownerId: accountId,
      activeTime: activeTime,
      prepTime: prepTime,
      totalTime: totalTime,
      type: type,
      characteristics: characteristics,
      description: description,
      summary: summary,
      videoLink: videoLink,
      recipeLinks: recipeLinks,
      pairsWith: pairsWith,
      imageUrl: imageUrl,
      source: source,
      nutrition: nutrition,
      equipment: equipment,
      servings: servings,
    );

    return toReturn;
  }

  static double checkDouble(dynamic value) {
    if (value == null) {
      return 1;
    } else if (value is String) {
      return double.parse(value);
    } else if (value is int) {
      return value.toDouble();
    } else {
      return value.toDouble();
    }
  }

  Future<String> _constructRecipeDatabaseObject(Recipe r) async {
    final String name = r.title;
    final int cookTime = r.cookTime.inMinutes;
    final int activeTime = r.activeTime.inMinutes;
    final int prepTime = r.prepTime.inMinutes;
    final int totalTime = r.totalTime.inMinutes;
    String steps = '';
    String ingredients = '';
    for (int o = 0; o < r.steps.length; o++) {
      RecipeStep s = r.steps[o];
      steps += '"${Utils.removeControlCharacters(s.description)}"${o == r.steps.length - 1 ? '' : ','}';
    }
    for (int j = 0; j < r.ingredients.length; j++) {
      RecipeIngredient i = r.ingredients[j];
      ingredients += '["${Utils.removeControlCharacters(i.ingredient)}", ${i.amount ?? -1}, "${Utils.removeControlCharacters(i.unit)}"]${j == r.ingredients.length - 1 ? '' : ','}';
    }

    String accountId = r.ownerId;

    bool public = r.public;

    String type = r.type;
    String characteristics = '';
    for (int c = 0; c < r.characteristics.length; c++) {
      String s = r.characteristics[c];
      characteristics += '"$s"${c == r.characteristics.length - 1 ? '' : ','}';
    }

    String recipeLinks = '';
    for (int l = 0; l < r.recipeLinks.length; l++) {
      String s = r.recipeLinks[l];
      recipeLinks += '"$s"${l == r.recipeLinks.length - 1 ? '' : ','}';
    }

    String pairsWithList = '';
    for (int p = 0; p < r.pairsWith.length; p++) {
      String s = r.pairsWith[p];
      pairsWithList += '"${Utils.removeControlCharacters(s)}"${p == r.pairsWith.length - 1 ? '' : ','}';
    }

    return '''{"${AppText.ingredientsKey}":[$ingredients], 
    "${AppText.accountIdKey}": "$accountId", 
    "${AppText.directionsKey}":[$steps], 
    "${AppText.publicKey}": ${public.toString()}, 
    "${AppText.recipeNameKey}": "${Utils.removeControlCharacters(name)}",
    "${AppText.cookTimeKey}":$cookTime,
    "${AppText.prepTimeKey}":$prepTime,
    "${AppText.activeTimeKey}":$activeTime, 
    "${AppText.totalTimeKey}":$totalTime,
    "${AppText.uuidKey}": "${r.uid}",
    "${AppText.typeKey}":"$type",
    "${AppText.characteristicsKey}":[$characteristics],
    "${AppText.descriptionKey}": "${Utils.removeControlCharacters(r.description)}",
    "${AppText.summaryKey}": "${Utils.removeControlCharacters(r.summary)}",
    "${AppText.videoLinkKey}": "${r.videoLink}",
    "${AppText.linksKey}":[$recipeLinks], 
    "${AppText.pairsWithKey}":[$pairsWithList],
    "${AppText.imageUrlKey}": "${Utils.removeControlCharacters(r.imageUrl)}",
    "${AppText.sourceKey}": "${Utils.removeControlCharacters(r.source)}",
    "${AppText.nutritionKey}": "${Utils.removeControlCharacters(r.nutrition)}",
    "${AppText.equipmentKey}": "${Utils.removeControlCharacters(r.equipment)}",
    "${AppText.servingsKey}": "${Utils.removeControlCharacters(r.servings.toString())}",
    "Token":"${await GetIt.I<AuthService>().getAuthToken()}"
    }''';
  }
}
