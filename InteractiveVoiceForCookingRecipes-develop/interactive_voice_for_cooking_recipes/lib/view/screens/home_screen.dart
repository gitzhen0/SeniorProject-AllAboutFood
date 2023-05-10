import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/recipe_data_service.dart';
import 'package:interactive_voice_for_cooking_recipes/view/flows/flow_wrapper.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/add_recipe_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/loading_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/login_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/search_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
                      AppText.appTitle,
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Colors.black),
                  ),
                  drawer: (loginSnapshot.data?.isNotEmpty ?? true)
                      ? Drawer(
                          // Add a ListView to the drawer. This ensures the user can scroll
                          // through the options in the drawer if there isn't enough vertical
                          // space to fit everything.
                          child: ListView(
                            // Important: Remove any padding from the ListView.
                            padding: EdgeInsets.zero,
                            children: [
                              const DrawerHeader(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(100, 4, 38, 40),
                                ),
                                child: Text(AppText.appTitle),
                              ),
                              if (loginSnapshot.data?.isNotEmpty ?? true)
                                ListTile(
                                    title: Row(children: const [Text(AppText.logout), Spacer(), Icon(Icons.logout)]),
                                    onTap: () async {
                                      FlowWrapper.push(context, const LoadingScreen(message: AppText.loggingOut));
                                      GetIt.I<AuthService>().signOut();
                                      await Future.delayed(const Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      });

                                      setState(() {});
                                    }),
                              if (loginSnapshot.data?.isNotEmpty ?? true)
                                ListTile(
                                    title: Row(children: const [Text(AppText.settings), Spacer(), Icon(Icons.settings)]),
                                    onTap: () async {
                                      FlowWrapper.push(context, SettingsScreen(
                                        onNameUpdate: (String? n) async {
                                          Navigator.of(context).pop();
                                          await GetIt.I<AuthService>().updateAuthDisplayName(n);

                                          setState(() {});
                                        },
                                      ));
                                    }),
                            ],
                          ),
                        )
                      : null,
                  body: SingleChildScrollView(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        if (loginSnapshot.data?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Welcome ${loginSnapshot.data?[0]?.displayName ?? loginSnapshot.data?[0]?.email ?? ''}',
                              style: const TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              AppText.toAddARecipe,
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        HomeButton(
                          onPressed: () => FlowWrapper.push(
                            context,
                            const SearchScreen(),
                          ),
                          displayText: AppText.viewRecipes,
                          assetImage: const AssetImage('assets/images/viewRecipe.jpg'),
                        ),
                        const SizedBox(height: 20),
                        if (loginSnapshot.data?.isNotEmpty ?? false)
                          HomeButton(
                            onPressed: () => FlowWrapper.push(
                              context,
                              AddRecipeScreen(
                                onAddRecipe: (r) async {
                                  FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                                  await GetIt.I<RecipeDataService>().addRecipeToDatabase(r).whenComplete(() {
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                    FlowWrapper.pushNoTransition(context, const SearchScreen());
                                  });

                                  setState(() {});
                                },
                                showSnackBar: (String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))),
                                recipes: snapshot.data ?? [],
                              ),
                            ),
                            displayText: AppText.addRecipe,
                            assetImage: const AssetImage('assets/images/addRecipe.jpg'),
                          )
                        else
                          HomeButton(
                            onPressed: () => FlowWrapper.push(
                              context,
                              LoginScreen(onLogin: (username, password) async {
                                FlowWrapper.push(context, const LoadingScreen(message: AppText.loggingIn));
                                await GetIt.I<AuthService>()
                                    .signIn(
                                  email: username.trim(),
                                  password: password.trim(),
                                )
                                    .then((u) {
                                  if (u != null) {
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(AppText.loginFailed)),
                                    );
                                  }
                                });

                                setState(() {});
                              }, onGoogleLogin: () async {
                                FlowWrapper.push(context, const LoadingScreen(message: AppText.loggingIn));
                                await GetIt.I<AuthService>().signInGoogle().then((u) {
                                  if (u != null) {
                                    Navigator.of(context).popUntil(
                                      (route) => route.isFirst,
                                    );
                                    setState(() {});
                                  } else {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(AppText.loginFailed)),
                                    );
                                  }
                                });

                                setState(() {});
                              }, onAccountCreation: (username, password, confirmPassword, name) async {
                                if (password.text.isNotEmpty && password.text.trim() == confirmPassword.text.trim()) {
                                  FlowWrapper.push(context, const LoadingScreen(message: AppText.creatingAccount));
                                  await GetIt.I<AuthService>()
                                      .signUp(
                                    email: username.text.trim(),
                                    password: password.text.trim(),
                                    name: name.trim(),
                                  )
                                      .then((u) {
                                    if (u != null) {
                                      Navigator.of(context).popUntil(
                                        (route) => route.isFirst,
                                      );
                                    } else {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text(AppText.accountFailed)),
                                      );
                                    }
                                  });
                                }
                                setState(() {});
                              }),
                            ),
                            displayText: AppText.login,
                            assetImage: const AssetImage('assets/images/login.jpg'),
                          ),
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

class HomeButton extends StatelessWidget {
  final String displayText;
  final VoidCallback onPressed;
  final AssetImage assetImage;
  const HomeButton({
    super.key,
    required this.displayText,
    required this.onPressed,
    required this.assetImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
              image: DecorationImage(
                image: assetImage,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
              ),
            ),
            // color: Colors.pink),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //const SizedBox(height: 7),
                      SizedBox(
                        child: Text(
                          displayText,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 10, 37, 51),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          maxLines: 1,
                        ),
                      ),
                      //const SizedBox(height: 5),
                      //const Spacer(),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: IconButton(
                    iconSize: 35,
                    onPressed: onPressed,
                    icon: Image.asset('assets/icons/recipe_go.jpg'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
