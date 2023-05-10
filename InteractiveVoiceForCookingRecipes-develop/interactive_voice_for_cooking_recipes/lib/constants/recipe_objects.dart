class Recipe {
  static int maxTitleLength = 100;
  static int maxIngredientTitleLength = 100;
  static int maxStepLength = 500;
  static int characteristicMaxLength = 100;
  static int summaryLength = 100;
  static int desciptionLength = 1000;
  static int videoLinkLength = 1000;
  static int imageLinkLength = 1000;
  static int sourceLinkLength = 1000;
  static int pairsWithLength = 100;
  static int unitLength = 100;
  static int nutritionLength = 1000;
  static int equipmentLength = 1000;
  static int servingsLength = 4;

  final String uid;
  final String title;
  final List<RecipeStep> steps;
  final List<RecipeIngredient> ingredients;
  final Duration cookTime;
  final Duration activeTime;
  final Duration prepTime;
  final Duration totalTime;
  final bool public;
  final String ownerId;
  final String type;
  final List<String> characteristics;
  final String description;
  final String summary;
  final String videoLink;
  final List<String> recipeLinks;
  final List<String> pairsWith;
  final String imageUrl;
  final String source;
  final String nutrition;
  final String equipment;
  final double servings;

  Recipe({
    required this.title,
    required this.steps,
    required this.ingredients,
    required this.cookTime,
    required this.public,
    required this.uid,
    required this.ownerId,
    required this.activeTime,
    required this.prepTime,
    required this.totalTime,
    required this.type,
    required this.characteristics,
    required this.description,
    required this.summary,
    required this.videoLink,
    required this.recipeLinks,
    required this.pairsWith,
    required this.imageUrl,
    required this.source,
    required this.nutrition,
    required this.equipment,
    required this.servings,
  });

  Recipe copyWith({
    String? uidN,
    String? titleN,
    List<RecipeStep>? stepsN,
    List<RecipeIngredient>? ingredientsN,
    Duration? cookTimeN,
    Duration? activeTimeN,
    Duration? prepTimeN,
    Duration? totalTimeN,
    bool? publicN,
    String? ownerIdN,
    String? typeN,
    List<String>? characteristicsN,
    String? descriptionN,
    String? summaryN,
    String? videoLinkN,
    List<String>? recipeLinksN,
    List<String>? pairsWithN,
    String? imageUrlN,
    String? sourceN,
    String? nutritionN,
    String? equipmentN,
    double? servingsN,
  }) {
    return Recipe(
      title: titleN ?? title,
      steps: stepsN ?? steps,
      ingredients: ingredientsN ?? ingredients,
      cookTime: cookTimeN ?? cookTime,
      public: publicN ?? public,
      uid: uidN ?? uid,
      ownerId: ownerIdN ?? ownerId,
      activeTime: activeTimeN ?? activeTime,
      prepTime: prepTimeN ?? prepTime,
      totalTime: totalTimeN ?? totalTime,
      type: typeN ?? type,
      characteristics: characteristicsN ?? characteristics,
      description: descriptionN ?? description,
      summary: summaryN ?? summary,
      videoLink: videoLinkN ?? videoLink,
      recipeLinks: recipeLinksN ?? recipeLinks,
      pairsWith: pairsWithN ?? pairsWith,
      imageUrl: imageUrlN ?? imageUrl,
      source: sourceN ?? source,
      nutrition: nutritionN ?? nutrition,
      equipment: equipmentN ?? equipment,
      servings: servingsN ?? servings,
    );
  }
}

class RecipeStep {
  String description;

  RecipeStep({required this.description});
}

class RecipeIngredient {
  String ingredient;
  double? amount;
  String displayAmount;
  String unit;

  RecipeIngredient({
    required this.ingredient,
    required this.amount,
    required this.unit,
    required this.displayAmount,
  });
}
