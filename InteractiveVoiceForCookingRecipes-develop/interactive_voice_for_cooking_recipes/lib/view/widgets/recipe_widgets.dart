import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/recipe_objects.dart';
import 'package:interactive_voice_for_cooking_recipes/services/recipe_data_service.dart';
import 'package:interactive_voice_for_cooking_recipes/view/flows/flow_wrapper.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/loading_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io' as io;
import 'package:permission_handler/permission_handler.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/recipe_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/edit_recipe_screen.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';

class IngredientController {
  late TextEditingController nameController;
  late TextEditingController valueController;
  late TextEditingController unit;
  IngredientController() {
    nameController = TextEditingController();
    valueController = TextEditingController();
    unit = TextEditingController();
  }
}

class TextCard extends StatefulWidget {
  final String step;

  // for reorder purpose -Zhen
  final int order;

  final VoidCallback onDelete;

  final VoidCallback onEdit;

  //changed from const constructor to this one below -Zhen
  const TextCard(this.step, this.order, {super.key, required this.onDelete, required this.onEdit});

  @override
  State<TextCard> createState() => _TextCardState();
}

class _TextCardState extends State<TextCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            //added a little text(sequence number) before the direction string. for display the order like "1. blabla", "2. blalba" -Zhen
            Flexible(
              flex: 70,
              child: Text("${widget.order + 1}.  ${widget.step}"),
            ),
            Flexible(
              flex: 10,
              child: IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit),
              ),
            ),
            Flexible(
              flex: 10,
              child: IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientCard extends StatefulWidget {
  final RecipeIngredient i;

  // for reorder purpose -Zhen
  final int order;

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const IngredientCard(this.i, this.order, {super.key, required this.onDelete, required this.onEdit});

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Flexible(
              flex: 70,
              child: Text('(${widget.order + 1}) ${Utils.forceReduce(widget.i.displayAmount)} ${widget.i.unit}${widget.i.amount != 1 && widget.i.unit.isNotEmpty ? 's' : ''} ${widget.i.ingredient}'),
            ),
            const Spacer(),
            Flexible(
              flex: 10,
              child: IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit),
              ),
            ),
            Flexible(
              flex: 10,
              child: IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextCheckbox extends StatefulWidget {
  final String text;
  final bool checked;
  final Function(bool?) onChanged;

  const TextCheckbox({
    super.key,
    required this.text,
    required this.checked,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => TextCheckboxState();
}

class TextCheckboxState extends State<TextCheckbox> {
  bool? checked;
  @override
  void initState() {
    super.initState();

    checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 90,
          child: Text(
            widget.text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        const SizedBox(
          width: 30,
        ),
        Checkbox(
          value: checked,
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {
              checked = value ?? false;
            });
          },
        )
      ],
    );
  }
}

class RelatedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<Recipe> recipes;

  final Function() setState;

  const RelatedRecipeCard(
    this.recipe, {
    super.key,
    required this.setState,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    if (recipe.uid == '-1') {
      return const SizedBox(height: 0, width: 0);
    }
    return InkWell(
      onTap: () {
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
                        await GetIt.I<RecipeDataService>().updateRecipeInDatabase(r).whenComplete(() => Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            ));

                        setState();
                      },
                      r: recipe,
                      showSnackBar: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppText.recipeExists))),
                      recipes: recipes,
                    ));
              },
              onDelete: () async {
                FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                await GetIt.I<RecipeDataService>().deleteRecipeFromDatabase(recipe).whenComplete(() => Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    ));

                setState();
              },
              onFork: (uid, name) async {
                FlowWrapper.push(context, const LoadingScreen(message: AppText.loadingRecipes));
                await GetIt.I<RecipeDataService>()
                    .addRecipeToDatabase(recipe.copyWith(
                      uidN: GetIt.I<RecipeDataService>().uuid?.v1() ?? '0',
                      titleN: "$name's ${recipe.title}",
                      ownerIdN: uid,
                      publicN: false,
                    ))
                    .whenComplete(() => Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        ));

                setState();
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  //const Icon(Icons.arrow_forward)
                ],
              ),
              if (recipe.summary.isNotEmpty) const SizedBox(height: 5),
              if (recipe.summary.isNotEmpty) Text(recipe.summary),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDialog extends StatelessWidget {
  final Function(int hours, int minutes) onConfirm;
  final Function() onCancel;
  final String title;
  final Duration? currentTime;

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  TimeDialog({super.key, required this.onConfirm, required this.onCancel, required this.title, this.currentTime}) {
    _hourController.text = currentTime?.inHours.toString() ?? '0';
    _minuteController.text = ((currentTime?.inMinutes ?? 0) - ((currentTime?.inHours ?? 0) * 60)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 10, 37, 51)),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _hourController,
                decoration: const InputDecoration(
                  labelText: AppText.hour,

                  // icon: Icon(Icons.timer_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _minuteController,
                decoration: const InputDecoration(
                  labelText: AppText.minute,
                  // icon: Icon(Icons.timer_off_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      actions: [
        TextButton(
          onPressed: () {
            int h = 0;
            int m = 0;
            try {
              h = int.parse(_hourController.text);
              m = int.parse(_minuteController.text);
            } catch (e) {
              h = 0;
              m = 0;
            }
            onConfirm(h, m);
            onCancel();
          },
          child: const Text(AppText.confirm),
        ),
        TextButton(
          onPressed: onCancel,
          child: const Text(AppText.cancel),
        ),
      ],
    );
  }
}

class TimeButton extends StatelessWidget {
  final Duration? duration;
  final String errorString;
  final String? label;
  final VoidCallback onPressed;
  const TimeButton({super.key, required this.onPressed, this.duration, required this.errorString, this.label});

  String buttonText(Duration? d) {
    if (d == null) {
      return errorString;
    } else {
      return '${label ?? ''}${Utils.convertToReadableCookTime(d)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        style: ButtonStyle(
          textStyle: const MaterialStatePropertyAll<TextStyle>(
            TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const MaterialStatePropertyAll<Color>(
            Color.fromARGB(255, 10, 37, 51),
          ),
          foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
          shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(buttonText(duration)),
      ),
    );
  }
}
