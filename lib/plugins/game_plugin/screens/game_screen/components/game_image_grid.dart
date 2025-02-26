import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flush_me_im_famous/plugins/game_plugin/modules/function_helper_module/function_helper_module.dart';
import 'package:flush_me_im_famous/utils/consts/theme_consts.dart';
import '../../../../../tools/logging/logger.dart';
import '../../../modules/game_play_module/game_play_module.dart';
import '../../../../../core/managers/module_manager.dart';

class GameNameRow extends StatefulWidget {
  final List<String> nameOptions; // ✅ Correct name + 2 distractors
  final Function(String) onNameTap;
  final Set<String> fadedNames;
  final String correctName;

  const GameNameRow({
    Key? key,
    required this.nameOptions,
    required this.onNameTap,
    required this.fadedNames,
    required this.correctName,
  }) : super(key: key);

  @override
  _GameNameRowState createState() => _GameNameRowState();
}

class _GameNameRowState extends State<GameNameRow> {
  String? selectedName;

  @override
  void initState() {
    super.initState();
    selectedName = null;
  }

  void _handleNameTap(String name) {
    if (widget.fadedNames.contains(name)) return; // ✅ Ignore faded names

    setState(() {
      selectedName = name; // ✅ Mark the tapped name as selected
      Logger().info("🎭 Name tapped: $name | selectedName now: $selectedName");
    });

    // ✅ Ensure UI updates before calling onNameTap
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {}); // ✅ Refresh UI
        widget.onNameTap(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shuffle the options (correct + 2 distractors) to randomize their order
    List<String> names = [widget.correctName, ...widget.nameOptions];
    names.shuffle(); // Randomize the order

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: names.map((name) => _buildNameBox(name)).toList(),
    );
  }

  Widget _buildNameBox(String name) {
    bool isSelected = selectedName == name;
    bool isFaded = widget.fadedNames.contains(name);

    Logger().info("🎭 Checking if selected: $name -> ${isSelected ? "Selected" : "Not Selected"}");

    return GestureDetector(
      onTap: () => _handleNameTap(name),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: selectedName == null ? 1.0 : (isSelected ? 1.0 : 0.2), // ✅ Fade out unselected names slightly
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 120,
          height: 60,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.greenAccent.withOpacity(0.8) // ✅ Selected name gets a green background
                : (isFaded ? Colors.grey[300] : AppColors.primaryColor),
            border: Border.all(
              color: isSelected
                  ? Colors.greenAccent // ✅ Green border when selected
                  : (isFaded ? Colors.grey : AppColors.accentColor),
              width: isSelected ? 4.0 : (isFaded ? 2.0 : 3.0),
            ),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.8),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isFaded ? Colors.grey[700] : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
