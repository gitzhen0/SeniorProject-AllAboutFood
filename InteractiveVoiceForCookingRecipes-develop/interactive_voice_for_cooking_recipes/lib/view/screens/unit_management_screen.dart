import 'package:flutter/material.dart';
import 'package:interactive_voice_for_cooking_recipes/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitManagementScreen extends StatefulWidget {
  final List<String> units;

  const UnitManagementScreen({super.key, required this.units});

  @override
  State<StatefulWidget> createState() => UnitManagementScreenState();
}

class UnitManagementScreenState extends State<UnitManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppText.manageCustomUnits,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
            children: widget.units
                .map((e) => UnitTile(
                    unit: e,
                    removeUnit: () async {
                      widget.units.remove(e);
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setStringList(AppText.unitShared, widget.units);
                      setState(() {});
                    }))
                .toList()),
      ),
    );
  }
}

class UnitTile extends StatelessWidget {
  final String unit;
  final VoidCallback removeUnit;

  const UnitTile({super.key, required this.unit, required this.removeUnit});

  @override
  Widget build(BuildContext context) {
    if (unit.isNotEmpty && !AppText.units.contains(unit)) {
      return Column(children: [
        ListTile(
          title: Text(unit),
          trailing: const Icon(Icons.delete),
          onTap: removeUnit,
        ),
        const Divider()
      ]);
    } else {
      return const SizedBox(height: 0);
    }
  }
}
