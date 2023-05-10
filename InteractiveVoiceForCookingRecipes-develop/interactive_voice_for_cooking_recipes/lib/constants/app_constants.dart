import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(this);
  }
}

class AppText {
  static const String appTitle = 'All About Food';
  static const String addRecipe = 'New Recipe';
  static const String editRecipe = 'Edit Recipe';
  static const String addThisRecipe = 'Add this Recipe!';
  static const String title = 'Title';
  static const String recipeName = "Recipe Name";
  static const String cookTime = 'Cook Time';
  static const String activeTime = 'Active Time';
  static const String prepTime = 'Prep Time';
  static const String totalTime = 'Total Time';
  static const String setCookTime = 'Set Cook Time';
  static const String setPrepTime = 'Set Prep Time';
  static const String setActiveTime = 'Set Active Time';
  static const String setTotalTime = 'Set Total Time';
  static const String addStep = 'Add Step';
  static const String editStep = 'Edit Step';
  static const String addToRecipe = 'Add to Recipe';
  static const String cancel = 'Cancel';
  static const String stepDesc = 'Step Description';
  static const String addIngredient = 'Add Ingredient';
  static const String editIngredient = 'Edit Ingredient';
  static const String name = 'Name';
  static const String value = 'Value';
  static const String unit = 'Unit';
  static const String viewRecipes = 'View Recipes';
  static const String gram = 'gram';
  static const String teaspoon = 'teaspoon';
  static const String tablespoon = 'tablespoon';
  static const String cup = 'cup';
  static const String quart = 'quart';
  static const String gallon = 'gallon';
  static const String confirm = 'Confirm';
  static const String ingredients = 'Ingredients';

  static const String publicKey = 'Public';
  static const String uuidKey = 'UID';
  static const String accountIdKey = 'AccountID';
  static const String recipeNameKey = 'Recipe Name';
  static const String directionsKey = 'Directions';
  static const String timesKey = "Times";
  static const String ingredientsKey = 'Ingredient List';
  static const String totalTimeKeyOld = 'Time';
  static const String totalTimeKey = 'TotalTime';
  static const String activeTimeKey = 'ActiveTime';
  static const String prepTimeKey = 'PrepTime';
  static const String cookTimeKey = 'CookTime';
  static const String typeKey = 'Type';
  static const String characteristicsKey = 'Characteristics';
  static const String descriptionKey = 'Description';
  static const String summaryKey = 'Summary';
  static const String videoLinkKey = 'VideoLink';
  static const String linksKey = 'Links';
  static const String pairsWithKey = 'PairsWith';
  static const String imageUrlKey = 'ImageUrl';
  static const String sourceKey = 'Source';
  static const String nutritionKey = 'Nutrition';
  static const String equipmentKey = 'Equipment';
  static const String servingsKey = 'Servings';

  static const String loadingRecipes = 'Loading Recipes';
  static const String unitShared = 'UNITS';
  static List<String> units = [gram, teaspoon, tablespoon, cup, quart, gallon];

  static const String login = 'Login';
  static const String username = 'Email';
  static const String password = 'Password';
  static const String emailAddress = 'Email Address';
  static const String emailAddressHint = 'Enter Email Address';
  static const String passwordHint = 'Enter Password';

  static const String createAccount = 'Create Account';
  static const String continueText = 'By continuing, you agree to the';
  static const String continueText2 = 'or continue with';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String loginWithGoogle = 'Login with Google';
  static const String loginWithFacebook = 'Login with Facebook';

  static const String forgotPassword = 'Forgot Password';
  static const String confirmPassword = 'Confirm Password';
  static const String sendPasswordEmail = 'Send Password Reset Email';
  static const String email = 'Email';
  static const String toAddARecipe = 'Welcome to AllAboutFood!';
  static const String creatingAccount = 'Creating Account';
  static const String loggingIn = 'Logging In';
  static const String loggingOut = 'Logging Out';
  static const String anEmailHasBeenSent = 'A Password Reset Email has been Sent to ';

  static const String logout = 'Log out';
  static const String loginFailed = 'Login Failed!';
  static const String accountFailed = 'Account Creation Failed!';

  static const String checkSpam = 'Check your spam folder.';
  static const String invalidEmail = 'Invalid Email';
  static const String settings = 'Settings';
  static const String userSettings = 'User Settings';
  static const String changeDisplayName = 'Change Display Name';
  static const String displayName = 'Display Name';
  static const String recipeExists = 'Recipe Already Exists with the Same Name';
  static const String recipe = 'Recipe';

  static const String setTags = 'Set Recipe Tags';
  static const String recipeType = 'Recipe Type';
  static const String selectCharacteristics = 'Select Characteristics';
  static const String searchCharacteristics = 'Search Characteristics';
  static const String downloaded = 'Your recipe has been successfully downloaded. Check your downloads folder on your phone.';
  static const String myRecipes = 'My Recipes';
  static const String noRecipes = 'No Recipes';
  static const String publicRecipes = 'Public Recipes';
  static const String videoLink = 'Video Link';
  static const String watchVideo = 'Watch Video';

  static const String pairsWellWith = 'Pairs Well With';
  static const String addPairing = 'Add Pairing';
  static const String editPairing = 'Edit Pairing';
  static const String pairing = 'Pairing';
  static const String relatedRecipes = 'Related Recipes';
  static const String searchRecipes = 'Search Recipes';
  static const String imageUrl = 'Image URL';
  static const String image = 'Image';

  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';

  static const String enterOnlySingular = 'Enter Only Singular Words in the Units Field';
  static const String unitPluralPrompt = 'Is this unit plural?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String hour = 'Hour';
  static const String minute = 'Minute';
  static const String save = 'Save';

  static const String deleteConfirmation = 'Delete Confirmation';
  static const String deleteConfirmationBody = 'Would you like to delete this recipe permanently?';

  static const String verifyEmailBeforeAdding = 'You must verify email before adding a recipe. We have sent you a verification email.';

  static const String manageCustomUnits = 'Manage Custom Units';
  static const String servings = 'Servings';

  static const List<String> types = [
    'Appetizer',
    'Breakfast',
    'Main Dish',
    'Side Dish',
    'Soup/Stew',
    'Dessert',
    'Salad',
    'Noodles/Rice',
    'Drinks',
    'Sauces',
    'Sandwiches, etc',
    'Spice Blend/Condiment',
  ];

  static const List<String> characteristics = [
    "Gluten-Free",
    "Dairy-Free",
    "Peanut-Free",
    "Low-Calorie",
    "Low-Fat",
    "Low-Sodium",
    "Vegan",
    "Vegetarian",
  ];
}

class AppTheme {
  static const double borderWidth = 0.5;
  static const double largeLabelFontSize = 20;
  static const double maxInputDecorationHeight = 45;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const double expandedBarHeight = 150;
  static const double standardScreenWidth = 600;
  static final fontFamily = GoogleFonts.openSans().fontFamily;
}

class NetworkingConstants {
  // static const String addApiUrl =
  //     'https://lflkdsgljsmxqdnmqnqvxmii3m0lzjxn.lambda-url.us-east-1.on.aws/';
  static const String addApiUrl = 'https://ifw2lmeqjsupk7jkgrowkqaxgi0thayh.lambda-url.us-east-1.on.aws/';
  // static const String getApiUrl =
  //     'https://i6wlhuqcy4llrgsaw4mga4gyo40igwwn.lambda-url.us-east-1.on.aws/';
  static const String getApiUrl = 'https://j4l67grmk5ptgcdgkvzrzl53nu0yvgxh.lambda-url.us-east-1.on.aws/';
  // static const String deleteApiUrl =
  //     'https://q6557awedkmaflvuym76x2xqcy0gdohy.lambda-url.us-east-1.on.aws/';
  static const String deleteApiUrl = 'https://uofhq4w72amatdizjvcotrkevq0hxsho.lambda-url.us-east-1.on.aws/';
}
