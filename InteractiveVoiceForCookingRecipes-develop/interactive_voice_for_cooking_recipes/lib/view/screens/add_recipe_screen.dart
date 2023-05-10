import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/recipe_data_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';
import 'package:interactive_voice_for_cooking_recipes/view/widgets/recipe_widgets.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

class AddRecipeScreen extends StatefulWidget {
  final Function(Recipe) onAddRecipe;
  final Function(String s) showSnackBar;
  final List<Recipe> recipes;

  const AddRecipeScreen({
    super.key,
    required this.onAddRecipe,
    required this.showSnackBar,
    required this.recipes,
  });

  @override
  State<StatefulWidget> createState() => AddRecipeScreenState();
}

class AddRecipeScreenState extends State<AddRecipeScreen> {
  XFile? image;

  final ImagePicker picker = ImagePicker();

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    setState(() {
      image = img;
    });
  }

  final _titleController = TextEditingController();

  TextEditingController _pairsController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  final TextEditingController _nutritionController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  List<String> characteristics = [];
  List<String> recipeLinks = [];
  List<String> pairsWith = [];
  List<RecipeStep> steps = [];
  List<RecipeIngredient> ingredients = [];

  Duration? cookTime;
  Duration? activeTime;
  Duration? prepTime;
  Duration? totalTime;
  bool _isPublic = false;
  String? selectedType;

  var aRtabTextIndexSelected = 0;

  var switchIsPrivate = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Utils.loadUnitList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 250, 248, 248),
          title: const Text(
            AppText.addRecipe,
            style: TextStyle(color: Colors.black),
          ),
          leading: const BackButton(color: Colors.black),
          // leading: const IconButton(onPressed: onPressed, icon: icon)
          actions: [
            TextButton(
                onPressed: () async {
                  List<Recipe> recipes = widget.recipes;
                  List<String> myRecipes = recipes.where((element) => element.ownerId == GetIt.I<AuthService>().firebaseUser?.uid).map((e) => e.title.toLowerCase()).toList();

                  if (!myRecipes.contains(_titleController.text.toLowerCase())) {
                    if (!await GetIt.I<AuthService>().checkEmailVerified()) {
                      widget.showSnackBar(AppText.verifyEmailBeforeAdding);
                      await GetIt.I<AuthService>().sendVerificationEmail();
                    } else {
                      String uid = GetIt.I<RecipeDataService>().uuid?.v1() ?? '0';
                      if (image != null) {
                        _imageUrlController.text = 'https://recipephotosrick.s3.amazonaws.com/$uid';
                      }
                      await widget.onAddRecipe(
                        Recipe(
                          title: _titleController.text,
                          steps: steps,
                          ingredients: ingredients,
                          cookTime: cookTime ?? const Duration(minutes: 0),
                          public: _isPublic,
                          uid: uid,
                          ownerId: GetIt.I<AuthService>().firebaseUser?.uid ?? '',
                          prepTime: prepTime ?? const Duration(minutes: 0),
                          activeTime: activeTime ?? const Duration(minutes: 0),
                          totalTime: totalTime ?? Duration(minutes: (cookTime?.inMinutes ?? 0) + (prepTime?.inMinutes ?? 0) + (activeTime?.inMinutes ?? 0)),
                          type: selectedType ?? '',
                          characteristics: characteristics,
                          description: _descriptionController.text,
                          summary: _summaryController.text,
                          videoLink: _videoLinkController.text,
                          recipeLinks: recipeLinks,
                          pairsWith: pairsWith,
                          imageUrl: _imageUrlController.text,
                          source: _sourceController.text,
                          nutrition: _nutritionController.text,
                          equipment: _equipmentController.text,
                          servings: double.tryParse(_servingsController.text) ?? 1,
                        ),
                      );
                      if (image != null) {
                        await GetIt.I<RecipeDataService>().uploadImageToDatabase(image, uid);
                      }
                    }
                  } else {
                    widget.showSnackBar(AppText.recipeExists);
                  }
                },
                child: const Text(
                  AppText.save,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ))
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.recipeName,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              TextField(
                controller: _titleController,
                maxLength: Recipe.maxTitleLength,
                decoration: const InputDecoration(
                  hintText: AppText.recipeName,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.descriptionKey,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  // Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              TextField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLength: Recipe.desciptionLength,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: AppText.descriptionKey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.summaryKey,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  // Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              TextField(
                controller: _summaryController,
                keyboardType: TextInputType.multiline,
                maxLength: Recipe.summaryLength,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: AppText.summaryKey,
                ),
              ),

              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.videoLink,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  // Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              TextField(
                controller: _videoLinkController,
                maxLength: Recipe.videoLinkLength,
                keyboardType: TextInputType.url,
                maxLines: null,
                decoration: const InputDecoration(hintText: AppText.videoLink),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    AppText.image,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  if (!kIsWeb)
                    IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      },
                    ),
                  if (image != null) Text(image?.name ?? ''),

                  // Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              if (image == null)
                TextField(
                  controller: _imageUrlController,
                  maxLength: Recipe.imageLinkLength,
                  keyboardType: TextInputType.url,
                  maxLines: null,
                  decoration: const InputDecoration(hintText: AppText.imageUrl),
                ),

              const SizedBox(height: 20),
              //todo: source textfield
              Row(
                children: const [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    AppText.sourceKey,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  // Spacer()
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              TextField(
                controller: _sourceController,
                maxLength: Recipe.sourceLinkLength,
                keyboardType: TextInputType.url,
                maxLines: null,
                decoration: const InputDecoration(hintText: AppText.sourceKey),
              ),
              const SizedBox(height: 20),

//textfield end--------------------------------------------------------------------------------------------
              Row(
//sliding switch Row

                children: [
                  const Spacer(),
                  Container(
                    alignment: Alignment.center,
                    child: FlutterToggleTab(
// width in percent
                      width: MediaQuery.of(context).size.width > 800 ? ((0.87 * 800) / (MediaQuery.of(context).size.width)) * 100 : 87,
                      borderRadius: 16,
                      height: 30,

                      selectedIndex: switchIsPrivate,
                      // ignore: prefer_const_literals_to_create_immutables
                      unSelectedBackgroundColors: [const Color.fromARGB(255, 230, 235, 242)],
                      selectedBackgroundColors: const [Color.fromARGB(255, 4, 38, 40)],
                      // ignore: prefer_const_constructors
                      selectedTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      unSelectedTextStyle: const TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontSize: 14, fontWeight: FontWeight.w500),
                      labels: const ["Private", "Public"],
                      selectedLabelIndex: (index) {
                        setState(() {
                          switchIsPrivate = index;
                          _isPublic = switchIsPrivate == 0 ? false : true;
                        });
                      },
                      isScroll: false,
                    ),
                  ),
                  const Spacer()
                ],
              ),
              const SizedBox(
                height: 20,
              ),

// second switch start------------------------------------------------------

              Row(
//sliding switch Row

                children: [
                  const Spacer(),
                  Container(
                    alignment: Alignment.center,
                    child: FlutterToggleTab(
// width in percent
                      width: MediaQuery.of(context).size.width > 800 ? ((0.87 * 800) / (MediaQuery.of(context).size.width)) * 100 : 87,
                      borderRadius: 16,
                      height: 50,

                      selectedIndex: aRtabTextIndexSelected,
                      // ignore: prefer_const_literals_to_create_immutables
                      unSelectedBackgroundColors: [const Color.fromARGB(255, 230, 235, 242)],
                      selectedBackgroundColors: const [Color.fromARGB(255, 4, 38, 40)],
                      // ignore: prefer_const_constructors
                      selectedTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      unSelectedTextStyle: const TextStyle(color: Color.fromARGB(255, 10, 37, 51), fontSize: 14, fontWeight: FontWeight.w500),
                      labels: const [AppText.ingredients, AppText.directionsKey],
                      selectedLabelIndex: (index) {
                        setState(() {
                          aRtabTextIndexSelected = index;
                        });
                      },
                      isScroll: false,
                    ),
                  ),
                  const Spacer()
                ],
              ),
              const Divider(),
              if (aRtabTextIndexSelected == 1) ...[
                ArAddDirection(steps: steps)
              ] else if (aRtabTextIndexSelected == 0) ...[
                ArAddIngredient(
                  ingredients: ingredients,
                )
              ],
//-------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------ ingredient start

//-----------------------------------------------------
              Row(
                children: [
                  const Text(AppText.pairsWellWith, style: TextStyle(fontSize: AppTheme.largeLabelFontSize)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _pairsController = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(AppText.addPairing),
                            content: TextField(
                              maxLength: Recipe.pairsWithLength,
                              controller: _pairsController,
                              decoration: const InputDecoration(labelText: AppText.pairing),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    pairsWith.add(_pairsController.text);
                                  });

                                  Navigator.of(context).pop();
                                },
                                child: const Text(AppText.addToRecipe),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(AppText.cancel),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: pairsWith
                    .map((e) => TextCard(
                          e,
                          pairsWith.indexOf(e),
                          onDelete: () {
                            setState(() {
                              pairsWith.remove(e);
                            });
                          },
                          onEdit: () {
                            _pairsController = TextEditingController();
                            _pairsController.text = e;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(AppText.editPairing),
                                  content: TextField(
                                    maxLength: Recipe.pairsWithLength,
                                    controller: _pairsController,
                                    decoration: const InputDecoration(labelText: AppText.pairing),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          pairsWith.remove(e);
                                          pairsWith.add(_pairsController.text);
                                        });

                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(AppText.confirm),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text(AppText.cancel),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  TimeButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return TimeDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              title: AppText.cookTime,
                              currentTime: cookTime,
                              onConfirm: (hours, minutes) {
                                setState(
                                  () {
                                    cookTime = Duration(hours: hours, minutes: minutes);
                                  },
                                );
                              },
                            );
                          });
                    },
                    duration: cookTime,
                    errorString: AppText.setCookTime,
                    label: '${AppText.cookTime}: ',
                  ),
                  const SizedBox(height: 10),
                  TimeButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return TimeDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              title: AppText.activeTime,
                              currentTime: activeTime,
                              onConfirm: (hours, minutes) {
                                setState(
                                  () {
                                    activeTime = Duration(hours: hours, minutes: minutes);
                                  },
                                );
                              },
                            );
                          });
                    },
                    duration: activeTime,
                    errorString: AppText.setActiveTime,
                    label: '${AppText.activeTime}: ',
                  ),
                  const SizedBox(height: 10),
                  TimeButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // todo: piping variable stuff.
                            return TimeDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              title: AppText.prepTime,
                              currentTime: prepTime,
                              onConfirm: (hours, minutes) {
                                setState(
                                  () {
                                    prepTime = Duration(hours: hours, minutes: minutes);
                                  },
                                );
                              },
                            );
                          });
                    },
                    duration: prepTime,
                    errorString: AppText.setPrepTime,
                    label: '${AppText.prepTime}: ',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TimeButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // todo: piping variable stuff.
                            return TimeDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              title: AppText.totalTime,
                              currentTime: totalTime,
                              onConfirm: (hours, minutes) {
                                setState(
                                  () {
                                    totalTime = Duration(hours: hours, minutes: minutes);
                                  },
                                );
                              },
                            );
                          });
                    },
                    duration: totalTime,
                    errorString: AppText.setTotalTime,
                    label: '${AppText.totalTime}: ',
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TimeButton(
                onPressed: (() {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(AppText.selectCharacteristics),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height / 1.5,
                          width: MediaQuery.of(context).size.width / 2,
                          child: SearchableList<String>(
                            initialList: AppText.characteristics,
                            filter: (value) => AppText.characteristics
                                .where(
                                  (element) => element.toLowerCase().contains(value),
                                )
                                .toList(),
                            builder: (e) => TextCheckbox(
                                text: e,
                                checked: characteristics.contains(e),
                                onChanged: (newVal) {
                                  if (newVal == true) {
                                    characteristics.add(e);
                                  } else if (newVal == false) {
                                    characteristics.remove(e);
                                  }
                                }),
                            inputDecoration: const InputDecoration(
                              labelText: AppText.searchCharacteristics,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(AppText.confirm),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(AppText.cancel),
                          ),
                        ],
                      );
                    },
                  );
                }),
                errorString: AppText.setTags,
              ),
              const SizedBox(
                height: 10,
              ),
              TimeButton(
                onPressed: (() {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(AppText.relatedRecipes),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height / 1.5,
                          width: MediaQuery.of(context).size.width / 2,
                          child: SearchableList<Recipe>(
                            initialList: widget.recipes,
                            filter: (value) => widget.recipes
                                .where(
                                  (element) => element.title.toLowerCase().contains(value),
                                )
                                .toList(),
                            builder: (e) => TextCheckbox(
                                text: e.title,
                                checked: recipeLinks.contains(e.uid),
                                onChanged: (newVal) {
                                  if (newVal == true) {
                                    recipeLinks.add(e.uid);
                                  } else if (newVal == false) {
                                    recipeLinks.remove(e.uid);
                                  }
                                }),
                            inputDecoration: const InputDecoration(
                              labelText: AppText.searchRecipes,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(AppText.confirm),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(AppText.cancel),
                          ),
                        ],
                      );
                    },
                  );
                }),
                errorString: AppText.relatedRecipes,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedType == null || selectedType == '' ? AppText.types[0] : selectedType,
                hint: const Text(AppText.recipeType),
                items: AppText.types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nutritionController,
                keyboardType: TextInputType.multiline,
                maxLength: Recipe.nutritionLength,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: AppText.nutritionKey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _equipmentController,
                keyboardType: TextInputType.multiline,
                maxLength: Recipe.equipmentLength,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: AppText.equipmentKey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                maxLength: Recipe.servingsLength,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: AppText.servingsKey,
                ),
              ),
              const SizedBox(height: 40),
            ]),
          )),
        ));
  }
}

class ArAddDirection extends StatefulWidget {
  final List<RecipeStep> steps;
  const ArAddDirection({super.key, required this.steps});

  @override
  State<ArAddDirection> createState() => _ArAddDirectionState();
}

class _ArAddDirectionState extends State<ArAddDirection> {
  TextEditingController _stepController = TextEditingController();

// take a original index and a destinational index -Zhen
// simply remove the item in the origianl index and insert it in the new index
  void updateMyOrder(int oldIndex, int newIndex) {
    setState(
      () {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        final item = widget.steps.removeAt(oldIndex);
        widget.steps.insert(newIndex, item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(AppText.directionsKey, style: TextStyle(fontSize: AppTheme.largeLabelFontSize)),
            const Spacer(),
            IconButton(
              onPressed: () {
                _stepController = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(AppText.addStep),
                      content: TextField(
                        maxLength: Recipe.maxStepLength,
                        controller: _stepController,
                        decoration: InputDecoration(
                            suffixIcon: kIsWeb
                                ? IconButton(
                                    icon: Image.asset('assets/icons/degree_Icon.png'),
                                    onPressed: () {
                                      _stepController.text += "°";
                                    },
                                  )
                                : null,
                            labelText: AppText.stepDesc),
                        keyboardType: TextInputType.multiline,
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 5,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(
                              () {
                                widget.steps.add(RecipeStep(description: _stepController.text));
                              },
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text(AppText.addToRecipe),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(AppText.cancel),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        //changed from ListView to ReorderableListView
        SizedBox(
          child: ReorderableListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: widget.steps
                .map((e) => TextCard(
                      e.description,
                      widget.steps.indexOf(e),
                      // this key is for reroderable listview
                      key: ValueKey(e),

                      onDelete: () {
                        setState(() {
                          widget.steps.remove(e);
                        });
                      },
                      onEdit: () {
                        _stepController = TextEditingController();
                        _stepController.text = e.description;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(AppText.editStep),
                              content: TextField(
                                maxLength: Recipe.maxStepLength,
                                controller: _stepController,
                                decoration: InputDecoration(
                                    suffixIcon: kIsWeb
                                        ? IconButton(
                                            icon: Image.asset('assets/icons/degree_Icon.png'),
                                            onPressed: () {
                                              _stepController.text += "°";
                                            },
                                          )
                                        : null,
                                    labelText: AppText.stepDesc),
                                keyboardType: TextInputType.multiline,
                                minLines: 1, //Normal textInputField will be displayed
                                maxLines: 5,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.steps.firstWhere((element) => element == e).description = _stepController.text;
                                    });

                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(AppText.confirm),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(AppText.cancel),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ))
                .toList(),
            onReorder: (int oldIndex, int newIndex) {
              updateMyOrder(oldIndex, newIndex);
            },
          ),
        ),
        const Divider(),
        // const SizedBox(height: 20),
      ],
    );
  }
}

class ArAddIngredient extends StatefulWidget {
  final List<RecipeIngredient> ingredients;
  const ArAddIngredient({super.key, required this.ingredients});

  @override
  State<ArAddIngredient> createState() => _ArAddIngredientState();
}

class _ArAddIngredientState extends State<ArAddIngredient> {
  IngredientController _ingredientController = IngredientController();

  void updateMyOrder(int oldIndex, int newIndex) {
    setState(
      () {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        final item = widget.ingredients.removeAt(oldIndex);
        widget.ingredients.insert(newIndex, item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(AppText.ingredientsKey, style: TextStyle(fontSize: AppTheme.largeLabelFontSize)),
            const Spacer(),
            IconButton(
              onPressed: () {
                _ingredientController = IngredientController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(AppText.addIngredient),
                      content: StatefulBuilder(
                        builder: ((context, setInnerState) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _ingredientController.valueController,
                                  keyboardType: TextInputType.url,
                                  inputFormatters: Utils.fractionFormatters,
                                  decoration: const InputDecoration(labelText: AppText.value),
                                ),
                                const SizedBox(height: 10),
                                TypeAheadField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(controller: _ingredientController.unit, maxLength: Recipe.unitLength, decoration: const InputDecoration(labelText: AppText.unit)),
                                  suggestionsCallback: (pattern) async {
                                    return await Utils.getUnits(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    String newS = Utils.capitalize(suggestion);
                                    return ListTile(
                                      title: Text(newS),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    _ingredientController.unit.text = Utils.capitalize(suggestion);
                                  },
                                ),
                                TextField(
                                  maxLength: Recipe.maxIngredientTitleLength,
                                  controller: _ingredientController.nameController,
                                  decoration: InputDecoration(
                                      suffixIcon: kIsWeb
                                          ? IconButton(
                                              icon: Image.asset('assets/icons/degree_Icon.png'),
                                              onPressed: () {
                                                _ingredientController.nameController.text += "°";
                                              },
                                            )
                                          : null,
                                      labelText: AppText.name),
                                ),
                                const SizedBox(height: 10),
                                const Text(AppText.enterOnlySingular),
                              ],
                            ),
                          );
                        }),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            bool addToRecipe = _ingredientController.unit.text.isEmpty ? true : _ingredientController.unit.text.characters.last.toLowerCase() != 's';
                            if (!addToRecipe) {
                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(AppText.unitPluralPrompt),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            addToRecipe = false;
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(AppText.yes),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              widget.ingredients.add(
                                                RecipeIngredient(
                                                  ingredient: _ingredientController.nameController.text,
                                                  amount: Utils.ingreDouble(_ingredientController.valueController.text),
                                                  unit: _ingredientController.unit.text,
                                                  displayAmount: _ingredientController.valueController.text,
                                                ),
                                              );
                                            });

                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();

                                            final prefs = await SharedPreferences.getInstance();
                                            List<String> curList = await Utils.getUnits('');
                                            if (!curList.contains(_ingredientController.unit.text.toLowerCase())) {
                                              curList.add(_ingredientController.unit.text.toLowerCase());
                                              await prefs.setStringList(AppText.unitShared, curList);
                                            }
                                          },
                                          child: const Text(AppText.no),
                                        ),
                                      ],
                                    );
                                  });
                            }
                            if (addToRecipe) {
                              setState(() {
                                widget.ingredients.add(
                                  RecipeIngredient(
                                    ingredient: _ingredientController.nameController.text,
                                    amount: Utils.ingreDouble(_ingredientController.valueController.text),
                                    unit: _ingredientController.unit.text,
                                    displayAmount: _ingredientController.valueController.text,
                                  ),
                                );
                              });

                              Navigator.of(context).pop();

                              final prefs = await SharedPreferences.getInstance();
                              List<String> curList = await Utils.getUnits('');
                              if (!curList.contains(_ingredientController.unit.text.toLowerCase())) {
                                curList.add(_ingredientController.unit.text.toLowerCase());
                                await prefs.setStringList(AppText.unitShared, curList);
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text(AppText.addToRecipe),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(AppText.cancel),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        SizedBox(
          child: ReorderableListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: widget.ingredients
                .map((e) => IngredientCard(
                      e,
                      widget.ingredients.indexOf(e),
                      // this key is for reroderable listview
                      key: ValueKey(e),
                      onDelete: () {
                        setState(() {
                          widget.ingredients.remove(e);
                        });
                      },
                      onEdit: () {
                        _ingredientController = IngredientController();
                        _ingredientController.nameController.text = e.ingredient;
                        _ingredientController.valueController.text = Utils.forceReduce(e.displayAmount.toString());
                        _ingredientController.unit.text = e.unit;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(AppText.editIngredient),

                              /// EDIT INGREDIENT
                              content: StatefulBuilder(
                                builder: ((context, setInnerState) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _ingredientController.valueController,
                                          keyboardType: TextInputType.url,
                                          inputFormatters: Utils.fractionFormatters,
                                          decoration: const InputDecoration(labelText: AppText.value),
                                        ),
                                        const SizedBox(height: 10),
                                        TypeAheadField(
                                          textFieldConfiguration:
                                              TextFieldConfiguration(controller: _ingredientController.unit, maxLength: Recipe.unitLength, decoration: const InputDecoration(labelText: AppText.unit)),
                                          suggestionsCallback: (pattern) async {
                                            return await Utils.getUnits(pattern);
                                          },
                                          itemBuilder: (context, suggestion) {
                                            String newS = Utils.capitalize(suggestion);
                                            return ListTile(
                                              title: Text(newS),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            _ingredientController.unit.text = Utils.capitalize(suggestion);
                                          },
                                        ),
                                        TextField(
                                          maxLength: Recipe.maxIngredientTitleLength,
                                          controller: _ingredientController.nameController,
                                          decoration: InputDecoration(
                                              suffixIcon: kIsWeb
                                                  ? IconButton(
                                                      icon: Image.asset('assets/icons/degree_Icon.png'),
                                                      onPressed: () {
                                                        _ingredientController.nameController.text += "°";
                                                      },
                                                    )
                                                  : null,
                                              labelText: AppText.name),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(AppText.enterOnlySingular),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    bool addToRecipe = _ingredientController.unit.text.isEmpty ? true : _ingredientController.unit.text.characters.last.toLowerCase() != 's';

                                    if (!addToRecipe) {
                                      return showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(AppText.unitPluralPrompt),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    addToRecipe = false;
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(AppText.yes),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      widget.ingredients.firstWhere((element) => element == e).ingredient = _ingredientController.nameController.text;
                                                      widget.ingredients.firstWhere((element) => element == e).amount = Utils.ingreDouble(_ingredientController.valueController.text);
                                                      widget.ingredients.firstWhere((element) => element == e).unit = _ingredientController.unit.text;
                                                      widget.ingredients.firstWhere((element) => element == e).displayAmount = _ingredientController.valueController.text;
                                                    });

                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();

                                                    final prefs = await SharedPreferences.getInstance();
                                                    List<String> curList = await Utils.getUnits('');
                                                    if (!curList.contains(_ingredientController.unit.text.toLowerCase())) {
                                                      curList.add(_ingredientController.unit.text.toLowerCase());
                                                      await prefs.setStringList(AppText.unitShared, curList);
                                                    }
                                                  },
                                                  child: const Text(AppText.no),
                                                ),
                                              ],
                                            );
                                          });
                                    }
                                    if (addToRecipe) {
                                      setState(() {
                                        widget.ingredients.firstWhere((element) => element == e).ingredient = _ingredientController.nameController.text;
                                        widget.ingredients.firstWhere((element) => element == e).amount = Utils.ingreDouble(_ingredientController.valueController.text);
                                        widget.ingredients.firstWhere((element) => element == e).unit = _ingredientController.unit.text;
                                        widget.ingredients.firstWhere((element) => element == e).displayAmount = _ingredientController.valueController.text;
                                      });

                                      Navigator.of(context).pop();

                                      final prefs = await SharedPreferences.getInstance();
                                      List<String> curList = await Utils.getUnits('');
                                      if (!curList.contains(_ingredientController.unit.text.toLowerCase())) {
                                        curList.add(_ingredientController.unit.text.toLowerCase());
                                        await prefs.setStringList(AppText.unitShared, curList);
                                      }
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text(AppText.confirm),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(AppText.cancel),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ))
                .toList(),
            onReorder: (int oldIndex, int newIndex) {
              updateMyOrder(oldIndex, newIndex);
            },
          ),
        ),
        const Divider(),
        // const SizedBox(height: 20),
      ],
    );
  }
}
