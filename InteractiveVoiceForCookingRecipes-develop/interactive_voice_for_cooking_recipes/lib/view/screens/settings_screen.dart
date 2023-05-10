import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:interactive_voice_for_cooking_recipes/services/auth_service.dart';
import 'package:interactive_voice_for_cooking_recipes/services/utils.dart';
import 'package:interactive_voice_for_cooking_recipes/view/flows/flow_wrapper.dart';
import 'package:interactive_voice_for_cooking_recipes/view/screens/unit_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String?) onNameUpdate;

  const SettingsScreen({super.key, required this.onNameUpdate});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    nameController.text = GetIt.I<AuthService>().firebaseUser?.displayName ?? GetIt.I<AuthService>().firebaseUser?.email ?? '';
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            AppText.settings,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              AppText.userSettings,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text(AppText.changeDisplayName),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(AppText.changeDisplayName),
                    content: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: AppText.displayName),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          onNameUpdate(nameController.text);
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
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.percent),
            title: const Text(AppText.manageCustomUnits),
            onTap: () async {
              //List<String> curList = await Utils.getUnits('');
              FlowWrapper.push(context, UnitManagementScreen(units: await Utils.getUnits('')));
            },
          ),
          const Divider(),
        ]));
  }
}
