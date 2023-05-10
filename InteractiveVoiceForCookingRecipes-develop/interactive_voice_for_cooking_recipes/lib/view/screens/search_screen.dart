//import 'dart:html' as html;
import 'dart:io' as io;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/recipe_data_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';
import 'package:interactive_voice_for_cooking_recipes/view/flows/flow_wrapper.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/edit_recipe_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/loading_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/recipe_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  // void downloadFile(String url, String name) {
  //   AnchorElement a = AnchorElement(href: url);
  //   a.download = name;
  //   a.click();
  // }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User?>>(
      future: GetIt.I<AuthService>().checkAuth(),
      builder: (context, loginSnapshot) {
        if (loginSnapshot.hasData) {
          return FutureBuilder<List<Recipe>>(
            future: GetIt.I<RecipeDataService>().getAllRecipes(),
            builder: (context, AsyncSnapshot<List<Recipe>> snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  appBar: AppBar(
                      title: const Text(
                        "Search",
                        style: TextStyle(color: Colors.black),
                      ),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      leading: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      )
                      // BackButton(color: Colors.black, onPressed: (){},),

                      ),
                  body: SingleChildScrollView(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: searchController,
                          onChanged: (newText) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(labelText: AppText.searchRecipes),
                        ),
                        const SizedBox(height: 20),
                        if (loginSnapshot.data?.isNotEmpty ?? false)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppText.myRecipes,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        if (loginSnapshot.data?.isNotEmpty ?? false) const Divider(),
                        Column(
                          children: snapshot.data
                                  ?.map((e) => RecipeCard(
                                        e,
                                        setState: () {
                                          setState(() {});
                                        },
                                        recipes: snapshot.data ?? [],
                                      ))
                                  .toList()
                                  .where((element) =>
                                      element.recipe.ownerId == GetIt.I<AuthService>().firebaseUser?.uid &&
                                      (element.recipe.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
                                          element.recipe.summary.toLowerCase().contains(searchController.text.toLowerCase())))
                                  .toList() ??
                              [
                                const Text(AppText.noRecipes),
                              ],
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppText.publicRecipes,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const Divider(),
                        Column(
                          children: snapshot.data
                                  ?.map((e) => RecipeCard(
                                        e,
                                        setState: () {
                                          setState(() {});
                                        },
                                        recipes: snapshot.data ?? [],
                                      ))
                                  .toList()
                                  .where((element) =>
                                      element.recipe.ownerId != GetIt.I<AuthService>().firebaseUser?.uid &&
                                      (element.recipe.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
                                          element.recipe.summary.toLowerCase().contains(searchController.text.toLowerCase())))
                                  .toList() ??
                              [
                                const Text(AppText.noRecipes),
                              ],
                        ),
                        const SizedBox(height: 20),
                      ]),
                    )),
                  ),
                );
              } else {
                return const LoadingScreen(message: AppText.loadingRecipes);
              }
            },
          );
        } else {
          return const LoadingScreen(message: AppText.loggingIn);
        }
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<Recipe> recipes;

  final Function() setState;

  const RecipeCard(
    this.recipe, {
    super.key,
    required this.setState,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    Widget recipeImage = Image.network(
      recipe.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        //return Image.asset('assets/images/recipe_main_image_placeholder.png');
        return Stack(alignment: Alignment.center, children: [
          Container(
            color: Colors.blueGrey[100],
            height: 200,
            width: 200,
          ),
          const Icon(Icons.local_pizza),
        ]);
      },
    );
    return Column(
      children: [
        Material(
          borderRadius: BorderRadius.circular(26),
          elevation: 3,
          child: Padding(
            // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            padding: const EdgeInsets.all(0),
            child: Container(
              height: 115,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                // color: const Color.fromARGB(255, 235, 235, 235),
                // color:Colors.white,
                color: const Color.fromARGB(255, 245, 245, 245),
              ),
              // color: Colors.pink),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 0, 9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Container(
                        width: 113,
                        height: 95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                          // color: Colors.blueGrey,
                          // color: Colors.red,
                        ),
                        child: recipeImage,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 75,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 0, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.summary.isEmpty) const SizedBox(height: 7),
                          AutoSizeText(
                            recipe.title,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 10, 37, 51),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                          if (recipe.summary.isNotEmpty) const SizedBox(height: 5),
                          if (recipe.summary.isNotEmpty)
                            AutoSizeText(
                              recipe.summary,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 10, 37, 51),
                              ),
                              maxLines: 4,
                              maxFontSize: 15,
                              minFontSize: 8,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: IconButton(
                      iconSize: 35,
                      onPressed: () {
                        FlowWrapper.push(
                            context,
                            RecipeScreen(
                              recipe: recipe,
                              onEdit: () {
                                FlowWrapper.push(

                                    ///pushes a new screen
                                    context,
                                    EditRecipeScreen(
                                      onEditRecipe: (r) async {
                                        FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                                        await GetIt.I<RecipeDataService>().updateRecipeInDatabase(r).whenComplete(() {
                                          Navigator.of(context).popUntil(
                                            (route) => route.isFirst,
                                          );
                                          FlowWrapper.pushNoTransition(
                                            context,
                                            const SearchScreen(),
                                          );
                                        });

                                        setState();
                                      },
                                      r: recipe,
                                      showSnackBar: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.recipeExists))),
                                      recipes: recipes,
                                    ));
                              },
                              onDelete: () async {
                                FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                                await GetIt.I<RecipeDataService>().deleteRecipeFromDatabase(recipe).whenComplete(() {
                                  Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                                  );
                                  FlowWrapper.pushNoTransition(
                                    context,
                                    const SearchScreen(),
                                  );
                                });

                                setState();
                              },
                              onFork: (uid, name) async {
                                List<String> myRecipes = recipes.where((element) => element.ownerId == GetIt.I<AuthService>().firebaseUser?.uid).map((e) => e.title.toLowerCase()).toList();
                                FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                                if (!myRecipes.contains("${name.toLowerCase()}'s ${recipe.title.toLowerCase()}")) {
                                  await GetIt.I<RecipeDataService>()
                                      .addRecipeToDatabase(recipe.copyWith(
                                    uidN: GetIt.I<RecipeDataService>().uuid?.v1() ?? '0',
                                    titleN: "$name's ${recipe.title}",
                                    ownerIdN: uid,
                                    publicN: false,
                                  ))
                                      .whenComplete(() {
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                    FlowWrapper.pushNoTransition(
                                      context,
                                      const SearchScreen(),
                                    );
                                  });

                                  setState();
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.recipeExists)));
                                }
                              },
                              onDownload: () async {
                                final pdf = pw.Document();

                                pdf.addPage(pw.Page(
                                    pageFormat: PdfPageFormat.a4,
                                    build: (pw.Context context) {
                                      return pw.Padding(
                                          padding: const pw.EdgeInsets.all(20),
                                          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                            pw.Text(
                                              recipe.title,
                                              style: const pw.TextStyle(fontSize: 25),
                                            ),
                                            pw.SizedBox(height: 20),
                                            pw.Text(
                                              recipe.description,
                                              style: const pw.TextStyle(fontSize: 15),
                                            ),
                                            pw.SizedBox(height: 20),
                                            pw.Text(AppText.directionsKey, style: const pw.TextStyle(fontSize: 20)),
                                            pw.SizedBox(height: 5),
                                            pw.Column(
                                                children: recipe.steps
                                                    .map(
                                                      (i) => pw.Column(
                                                        children: [
                                                          pw.Padding(
                                                            padding: const pw.EdgeInsets.all(10),
                                                            child: pw.Text(i.description),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    .toList()),
                                            pw.SizedBox(height: 20),
                                            pw.Text(AppText.ingredientsKey, style: const pw.TextStyle(fontSize: 20)),
                                            pw.SizedBox(height: 5),
                                            pw.Column(
                                                children: recipe.ingredients
                                                    .map(
                                                      (i) => pw.Column(
                                                        children: [
                                                          pw.Padding(
                                                            padding: const pw.EdgeInsets.all(10),
                                                            child: pw.Text('${i.amount} ${i.unit}${i.amount != 1 ? 's' : ''} ${i.ingredient}'),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    .toList()),
                                            pw.SizedBox(height: 15),
                                            pw.Text('${AppText.cookTime}: ${Utils.convertToReadableCookTime(recipe.cookTime)}', style: const pw.TextStyle(fontSize: 15)),
                                            pw.Text('${AppText.prepTime}: ${Utils.convertToReadableCookTime(recipe.prepTime)}', style: const pw.TextStyle(fontSize: 15)),
                                            pw.Text('${AppText.activeTime}: ${Utils.convertToReadableCookTime(recipe.activeTime)}', style: const pw.TextStyle(fontSize: 15)),
                                            pw.Text('${AppText.totalTime}: ${Utils.convertToReadableCookTime(recipe.totalTime)}', style: const pw.TextStyle(fontSize: 15)),
                                            pw.SizedBox(height: 20),
                                            pw.Text(recipe.type, style: const pw.TextStyle(fontSize: 15)),
                                            pw.SizedBox(height: 20),
                                            pw.Column(
                                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                                              children: recipe.characteristics.map((i) => pw.Text(i)).toList(),
                                            ),
                                          ]));
                                    }));
                                if (kIsWeb) {
                                  // final file = html.File([
                                  //   'data',
                                  // ], '../../assets/pdfs/${e.title.replaceAll(' ', '')}.pdf');
                                  // await file
                                  //     .writeAsBytes(await pdf.save());
                                  // downloadFile(
                                  //     '../../assets/pdfs/${e.title}.pdf',
                                  //     e.title);
                                } else {
                                  if (await Permission.storage.request().isGranted) {
                                    // Either the permission was already granted before or the user just granted it.
                                    final file = io.File('/storage/emulated/0/Download/${recipe.title}.pdf');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.downloaded)));
                                    await file.writeAsBytes(await pdf.save());
                                  }
                                }
                              },
                              recipes: recipes,
                            ));
                      },
                      icon: Image.asset('assets/icons/recipe_go.jpg'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
