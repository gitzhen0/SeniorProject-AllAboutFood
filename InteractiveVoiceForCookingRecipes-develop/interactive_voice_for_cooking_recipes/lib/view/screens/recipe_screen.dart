import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:fraction/fraction.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';
import 'package:interactive_voice_for_cooking_recipes/view/widgets/recipe_widgets.dart';

import 'package:url_launcher/url_launcher_string.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class RecipeScreen extends StatefulWidget {
  /// Recipe object that is used to construct this pages
  final Recipe recipe;

  /// Callback functions to call when the associated actions are taken.
  final Function() onEdit;
  final Function() onDelete;
  final Function(String uid, String name) onFork;
  final Function() onDownload;
  final List<Recipe> recipes;

  /// Constructor
  const RecipeScreen({super.key, required this.recipe, required this.onEdit, required this.onDelete, required this.onFork, required this.onDownload, required this.recipes});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  int rStabTextIndexSelected = 0;
  SampleItem? selectedMenu;
  double dropdownValue = 1; // switch for ingredient and instruction
  TextEditingController servingsController = TextEditingController();
  @override
  void initState() {
    super.initState();
    servingsController.text = widget.recipe.servings.toString();
    dropdownValue = double.tryParse(servingsController.text) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    String uid = GetIt.I<AuthService>().firebaseUser?.uid ?? '';
    String displayName = GetIt.I<AuthService>().firebaseUser?.displayName ?? '';
    Widget recipeImage = Image.network(
      widget.recipe.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
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
    return Scaffold(
      floatingActionButton: uid != '' && !kIsWeb
          ? FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(115, 191, 191, 150),
              onPressed: () async {
                await widget.onDownload();

                /// calls the callback from earlier
              },
              child: const Icon(Icons.download),
            )
          : null,

      /// Top bar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                width: 800,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),

                  // color: Colors.blueGrey,
                  // color: Colors.red,
                ),
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: recipeImage,
                ),
              ),

              Positioned(
                left: 24.0,
                top: 55.0,
                child: FloatingActionButton(
                  heroTag: 'close',
                  elevation: 20,
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 35),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              //if user loged in and is the owner of this recipe
              if (uid == widget.recipe.ownerId)
                Positioned(
                  right: 24.0,
                  top: 55.0,
                  child: FloatingActionButton(
                    heroTag: 'edit',
                    elevation: 20,
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 35),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17.0),
                    ),
                    onPressed: widget.onEdit,
                    child: const ImageIcon(
                      AssetImage("assets/icons/recipe_Edit.png"),
                      size: 30,
                    ),
                  ),
                ),

              // if user loged in but not the owner of this recipe
              if (uid != "" && uid != widget.recipe.ownerId)
                Positioned(
                  right: 24.0,
                  top: 55.0,
                  child: FloatingActionButton(
                    heroTag: 'like',
                    elevation: 20,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17.0),
                    ),
                    onPressed: () async {
                      await widget.onFork(
                        uid,
                        displayName,
                      );
                    },
                    child: const Icon(
                      //AssetImage("assets/icons/like_heart.png"),
                      Icons.fork_left,
                      size: 30,
                    ),
                  ),
                ),
            ]),
//-----------------------------------------------------------------------------------------------
            /// This first row object contains the recipe's name, and the buttons for editing and deleting if allowed
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Row(
                children: [
                  Expanded(
                    flex: 75,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0, top: 0),
                      child: SizedBox(
                        height: 50,
                        child: AutoSizeText(
                          widget.recipe.title,

                          /// recipe title
                          style: const TextStyle(
                            fontSize: 22,
                          ),
                          maxLines: 3,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  if (widget.recipe.videoLink.isNotEmpty)
                    IconButton(
                      iconSize: 30,
                      color: const Color.fromARGB(255, 4, 38, 40),
                      icon: const Icon(
                        Icons.play_circle_outline,
                      ),
                      onPressed: () => launchUrlString(widget.recipe.videoLink),
                    ),
                  if (uid == widget.recipe.ownerId)
                    IconButton(
                      iconSize: 30,
                      color: const Color.fromARGB(255, 4, 38, 40),
                      icon: const Icon(
                        Icons.delete,
                      ),
                      // onPressed: () => widget.onDelete(),
                      onPressed: () => {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                AppText.deleteConfirmation,
                                style: TextStyle(color: Color.fromARGB(255, 4, 38, 40), fontSize: 25),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: const <Widget>[
                                    Text(
                                      AppText.deleteConfirmationBody,
                                      style: TextStyle(color: Color.fromARGB(255, 4, 38, 40), fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text(
                                    AppText.no,
                                    style: TextStyle(color: Color.fromARGB(255, 4, 38, 40), fontSize: 22),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    AppText.yes,
                                    style: TextStyle(color: Color.fromARGB(255, 4, 38, 40), fontSize: 22),
                                  ),
                                  onPressed: () {
                                    widget.onDelete();
                                  },
                                ),
                              ],
                            );
                          },
                        )
                      },
                    ),
                  const Spacer(),
                  const SizedBox(width: 20, height: 20),
                ],
              ),
            ),
//-----------------------------------------------------------------------------------------------

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Center(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(
                      children: [
                        if (widget.recipe.type != "")
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(95, 121, 179, 242),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                                  child: Text(widget.recipe.type, style: const TextStyle(fontSize: 15)),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: widget.recipe.characteristics
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromARGB(84, 118, 214, 187),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                                    child: Text(
                                      "#$e",
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ]),
                ),
              ),
            ),

//-----------------------------------------------------------------------------------------------
            Row(
              // description Row
              children: [
                const SizedBox(
                  width: 20,
                ),
                if (widget.recipe.summary.isNotEmpty)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.recipe.summary,

                        /// recipe title
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 40,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              // description Row
              children: [
                const SizedBox(
                  width: 20,
                ),
                if (widget.recipe.description.isNotEmpty)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.recipe.description,

                        /// recipe title
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 40,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),

//-----------------------------------------------------------------------------------------------
            Row(
//sliding switch Row

              children: [
                const Spacer(),
                Container(
                  alignment: Alignment.center,
                  child: FlutterToggleTab(
// width in percent
                    width: MediaQuery.of(context).size.width > 800 ? ((0.9 * 800) / (MediaQuery.of(context).size.width)) * 100 : 90,
                    borderRadius: 16,
                    height: 50,

                    selectedIndex: rStabTextIndexSelected,
                    unSelectedBackgroundColors: const [Color.fromARGB(255, 230, 235, 242)],
                    selectedBackgroundColors: const [Color.fromARGB(255, 4, 38, 40)],
                    selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    unSelectedTextStyle: const TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontSize: 14, fontWeight: FontWeight.w500),
                    labels: const [AppText.ingredients, AppText.directionsKey],
                    selectedLabelIndex: (index) {
                      setState(() {
                        rStabTextIndexSelected = index;
                      });
                    },
                    isScroll: false,
                  ),
                ),
                const Spacer()
              ],
            ),
            const Divider(),
            if (rStabTextIndexSelected == 1) ...[recipeDirections()] else if (rStabTextIndexSelected == 0) ...[recipeIngredients()],
            const Divider(),
//-----------------------------------------------------------------------------------------------

            if (widget.recipe.recipeLinks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    '${AppText.relatedRecipes}:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: widget.recipe.recipeLinks.map((e) {
                      Recipe r = widget.recipes.firstWhere((recipe) => recipe.uid == e,
                          orElse: () => Recipe(
                                title: '',
                                steps: [],
                                ingredients: [],
                                cookTime: Duration.zero,
                                public: false,
                                uid: '-1',
                                ownerId: '',
                                activeTime: Duration.zero,
                                prepTime: Duration.zero,
                                totalTime: Duration.zero,
                                type: '',
                                characteristics: [],
                                description: '',
                                summary: '',
                                videoLink: '',
                                recipeLinks: [],
                                pairsWith: [],
                                imageUrl: '',
                                source: '',
                                nutrition: '',
                                equipment: '',
                                servings: 1,
                              ));

                      return RelatedRecipeCard(
                        r,
                        setState: (() {
                          setState(() {});
                        }),
                        recipes: widget.recipes,
                      );
                    }).toList(),
                  ),
                ]),
              ),
            const SizedBox(height: 20),

            if (widget.recipe.source.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(
                    AppText.sourceKey,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    elevation: 6,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: const Color.fromARGB(255, 4, 38, 40),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Flexible(
                            child: InkWell(
                              child: Text(
                                widget.recipe.source, //todo: replace source link
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ), // todo: replace this source link placeholder with source variable
                              onTap: () => launchUrlString(widget.recipe.source), //todo: replace
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
              ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  Widget recipeIngredients() {
    //return Row(children: const [Text("Ingredients")]);
    return

        /// Top row done
        Padding(
      // padding: const EdgeInsets.all(20),
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Column(
        /// This column contains all of the recipe information
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  const Text(
                    AppText.ingredientsKey,
                    style: TextStyle(
                      color: Color.fromARGB(255, 116, 129, 137),
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "${widget.recipe.ingredients.length} Items",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 116, 129, 137),
                      fontSize: 15,
                    ),
                  )
                ],
              ),
              // const SizedBox(width: 10),
              const Spacer(),
              const Text('${AppText.servings}: '),
              SizedBox(
                height: 30,
                width: 50,
                child: TextField(
                  controller: servingsController,
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    counterText: "",
                  ),
                  onSubmitted: ((value) {
                    servingsController.text = value;
                  }),
                  onChanged: (value) {
                    try {
                      setState(() {
                        dropdownValue = double.parse(value);
                      });
                    } catch (e) {
                      setState(() {
                        dropdownValue = 1;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ///end steps
          // const Text(AppText.ingredientsKey,

          //     /// Same deal for ingredients
          //     style: TextStyle(fontSize: 30)),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children: widget.recipe.ingredients.map((e) => Text(e.ingredient)).toList()
            // //[Text('asdasdsad'), ElevatedButton(onPressed: (){}, child: Text('button'))],
            children: widget.recipe.ingredients.map((i) {
              ///Maps ingredients to a list of columns that have their information
              return Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color.fromARGB(255, 230, 235, 242),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text(
                        '${Utils.forceEmpty(Utils.forceReduce(Fraction.fromDouble((i.amount ?? -1) * (dropdownValue / widget.recipe.servings)).toString()))} ${i.unit}${i.amount != 1 && i.unit.isNotEmpty ? 's' : ''} ${i.ingredient}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (widget.recipe.pairsWith.isNotEmpty) const Divider(),
          const SizedBox(height: 20),
          if (widget.recipe.pairsWith.isNotEmpty)
            const Text(
              '${AppText.pairsWellWith}:',
              style: TextStyle(fontSize: 20),
            ),

          const SizedBox(height: 5),

          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: widget.recipe.pairsWith.map((e) => Text(e)).toList(),
          // ),

          Padding(
            padding: const EdgeInsets.only(left: 0, right: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Row(
                  children: widget.recipe.pairsWith
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(255, 230, 235, 242),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                                child: Text(
                                  e,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              if (widget.recipe.nutrition.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${AppText.nutritionKey}: ${widget.recipe.nutrition}',

                    /// recipe title
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (widget.recipe.equipment.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${AppText.equipmentKey}: ${widget.recipe.equipment}',

                    /// recipe title
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),

          /// end ingredients

          ///Show the cooktime at the bottom
        ],
      ),
    );
  }

//-----------------------------------------------------------------------------------------------

  //use button to switch between direction and ingredients
  Widget recipeDirections() {
    return

        /// Top row done
        Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        /// This column contains all of the recipe information
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(AppText.directionsKey, style: TextStyle(fontSize: 20)),
              const Spacer(),
              Text("${widget.recipe.steps.length.toString()} Steps", style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 116, 129, 137))),
            ],
          ),

          ///Directions label
          // const Divider(),
          const SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.recipe.steps.map((e) {
              /// Maps the recipe steps to a list of columns
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      // child: Text(e.description),
                      child: Material(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: const Color.fromARGB(255, 230, 235, 242),
                                        ),
                                        alignment: Alignment.center,
                                        height: 20,
                                        width: 20,
                                        child: Text(
                                          "${widget.recipe.steps.indexOf(e).toInt() + 1}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Color.fromARGB(255, 112, 185, 190)),
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Container(),
                                    // )
                                  ],
                                ),

                                //the text of each step
                                Expanded(
                                  child: Text(
                                    e.description,
                                    softWrap: true,
                                    maxLines: 10,
                                  ),
                                )
                              ],
                            ),
                          ))

                      /// each step text
                      )
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const Divider(),
          Row(
            children: const [
              Text(AppText.timesKey, style: TextStyle(fontSize: 20)),
              Spacer(),
            ],
          ),

          Material(
            elevation: 3,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Text('${AppText.cookTime}: ${Utils.convertToReadableCookTime(widget.recipe.cookTime)}', style: const TextStyle(fontSize: 15)),
                  const Spacer(),
                  Text('${AppText.prepTime}: ${Utils.convertToReadableCookTime(widget.recipe.prepTime)}', style: const TextStyle(fontSize: 15)),
                  const SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          Material(
            elevation: 3,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Text('${AppText.activeTime}: ${Utils.convertToReadableCookTime(widget.recipe.activeTime)}', style: const TextStyle(fontSize: 15)),
                  const Spacer(),
                  Text('${AppText.totalTime}: ${Utils.convertToReadableCookTime(widget.recipe.totalTime)}', style: const TextStyle(fontSize: 15)),
                  const SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),

          ///Show the cooktime at the bottom

          ///Show the cooktime at the bottom
        ],
      ),
    );
  }
}
