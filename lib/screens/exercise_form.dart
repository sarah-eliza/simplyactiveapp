import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard

/// Data model for one exercise row.
class ExerciseRowData {
  final TextEditingController sectionController;
  final TextEditingController exerciseNameController;
  final TextEditingController modificationController;
  final TextEditingController durationController;
  Color selectedColor;

  ExerciseRowData({
    String initialSection = '',
    String initialExerciseName = '',
    String initialModification = '',
    String initialDuration = '',
    Color? initialColor,
  })  : sectionController = TextEditingController(text: initialSection),
        exerciseNameController = TextEditingController(text: initialExerciseName),
        modificationController = TextEditingController(text: initialModification),
        durationController = TextEditingController(text: initialDuration),
        selectedColor = initialColor ?? Colors.grey;

  void dispose() {
    sectionController.dispose();
    exerciseNameController.dispose();
    modificationController.dispose();
    durationController.dispose();
  }

  String get colorString =>
      "(${selectedColor.red.toInt()},${selectedColor.green.toInt()},${selectedColor.blue.toInt()})";

  // Create a duplicate of this row.
  ExerciseRowData duplicate() {
    return ExerciseRowData(
      initialSection: sectionController.text,
      initialExerciseName: exerciseNameController.text,
      initialModification: modificationController.text,
      initialDuration: durationController.text,
      initialColor: selectedColor,
    );
  }
}

class ExerciseBuilderTable extends StatefulWidget {
  const ExerciseBuilderTable({super.key});

  @override
  State<ExerciseBuilderTable> createState() => _ExerciseBuilderTableState();
}

class _ExerciseBuilderTableState extends State<ExerciseBuilderTable>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Lists for Warmup and Cooldown exercises.
  final List<ExerciseRowData> warmupRows = [];
  final List<ExerciseRowData> cooldownRows = [];
  // Map for Round exercises (multiple rounds).
  final Map<int, List<ExerciseRowData>> roundRows = {
    1: [],
    2: [],
    3: [],
  };

  // For Round tab: track which round is selected.
  int selectedRound = 1;

  late TabController _tabController;
  final double _rowHeight = 80.0; // Estimated row height

  @override
  void initState() {
    super.initState();
    // Start with one row in each category.
    warmupRows.add(ExerciseRowData());
    cooldownRows.add(ExerciseRowData());
    roundRows[1]!.add(ExerciseRowData());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    for (var row in warmupRows) {
      row.dispose();
    }
    for (var row in cooldownRows) {
      row.dispose();
    }
    for (var list in roundRows.values) {
      for (var row in list) {
        row.dispose();
      }
    }
    _tabController.dispose();
    super.dispose();
  }

  // Opens the color picker dialog for a specific row.
  void _pickColorForRow(ExerciseRowData row) {
    Color tempColor = row.selectedColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a Color"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (color) {
                        setStateDialog(() {
                          tempColor = color;
                        });
                      },
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsv,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "RGB: (${tempColor.red.toInt()}, ${tempColor.green.toInt()}, ${tempColor.blue.toInt()})",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  row.selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  // Build the table header.
  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Expanded(child: Text("Section", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Exercise", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Modification", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Duration", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Color", style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 50, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // Build a single row for an exercise.
  Widget _buildRow(ExerciseRowData row, int index, VoidCallback onDelete, VoidCallback onDuplicate) {
    return Container(
      key: ValueKey(index), // Use index as the key to force rebuild on state change.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: row.sectionController,
              decoration: const InputDecoration(hintText: "Section"),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: row.exerciseNameController,
              decoration: const InputDecoration(hintText: "Exercise"),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: row.modificationController,
              decoration: const InputDecoration(hintText: "Modification"),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: row.durationController,
              decoration: const InputDecoration(hintText: "Duration"),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pickColorForRow(row),
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: row.selectedColor,
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  "RGB: ${row.colorString}",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: "Duplicate Row",
                  onPressed: onDuplicate,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: "Delete Row",
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the table for a list of rows using ReorderableListView.
  Widget _buildReorderableTable(
      List<ExerciseRowData> rows,
      VoidCallback onAddRow,
      Function(int) onRemoveRow,
      Function(int) onDuplicateRow) {
    double containerHeight = (rows.length * _rowHeight) + 20;
    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 8),
        SizedBox(
          height: containerHeight,
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex--;
                }
                final row = rows.removeAt(oldIndex);
                rows.insert(newIndex, row);
              });
            },
            children: List.generate(rows.length, (index) {
              final row = rows[index];
              return Container(
                key: ValueKey(index),
                child: _buildRow(row, index, () {
                  onRemoveRow(index);
                }, () {
                  onDuplicateRow(index);
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onAddRow,
          child: const Text("Add Row"),
        ),
      ],
    );
  }

  // Generate output in Python tuple format.
  String _generateOutput() {
    final buffer = StringBuffer();
    buffer.writeln("# -------------------- Exercises Data --------------------");
    buffer.writeln("# Each tuple: (Section, Exercise Name, Modification, Background Color, Duration in seconds)");
    buffer.writeln("exercises = [");
    // Warmup rows.
    for (var row in warmupRows) {
      if (row.sectionController.text.isNotEmpty ||
          row.exerciseNameController.text.isNotEmpty ||
          row.durationController.text.isNotEmpty) {
        buffer.writeln(
            '    ("${row.sectionController.text}", "${row.exerciseNameController.text}", "${row.modificationController.text}", ${row.colorString}, ${row.durationController.text}),');
      }
    }
    // Round rows: iterate through rounds 1-3.
    for (int r = 1; r <= 3; r++) {
      var list = roundRows[r] ?? [];
      for (var row in list) {
        if (row.sectionController.text.isNotEmpty ||
            row.exerciseNameController.text.isNotEmpty ||
            row.durationController.text.isNotEmpty) {
          buffer.writeln(
              '    ("${row.sectionController.text}", "${row.exerciseNameController.text}", "${row.modificationController.text}", ${row.colorString}, ${row.durationController.text}),');
        }
      }
    }
    // Cooldown rows.
    for (var row in cooldownRows) {
      if (row.sectionController.text.isNotEmpty ||
          row.exerciseNameController.text.isNotEmpty ||
          row.durationController.text.isNotEmpty) {
        buffer.writeln(
            '    ("${row.sectionController.text}", "${row.exerciseNameController.text}", "${row.modificationController.text}", ${row.colorString}, ${row.durationController.text}),');
      }
    }
    buffer.writeln("]");
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Builder Table"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Warmup"),
            Tab(text: "Round"),
            Tab(text: "Cooldown"),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Warmup Tab.
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildReorderableTable(
                          warmupRows,
                          () => setState(() {
                            warmupRows.add(ExerciseRowData());
                          }),
                          (index) => setState(() {
                            warmupRows[index].dispose();
                            warmupRows.removeAt(index);
                          }),
                          (index) => setState(() {
                            warmupRows.insert(index + 1, warmupRows[index].duplicate());
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Round Tab.
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("Select Round: "),
                            DropdownButton<int>(
                              value: selectedRound,
                              items: const [
                                DropdownMenuItem(value: 1, child: Text("Round 1")),
                                DropdownMenuItem(value: 2, child: Text("Round 2")),
                                DropdownMenuItem(value: 3, child: Text("Round 3")),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedRound = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 20),
                            if (selectedRound < 3)
                              ElevatedButton(
                                onPressed: () {
                                  if (roundRows[selectedRound] != null) {
                                    setState(() {
                                      roundRows[selectedRound + 1] =
                                          List.from(roundRows[selectedRound]!);
                                    });
                                  }
                                },
                                child: const Text("Duplicate to Next Round"),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildReorderableTable(
                          roundRows[selectedRound] ?? [],
                          () => setState(() {
                            roundRows[selectedRound] ??= [];
                            roundRows[selectedRound]!.add(ExerciseRowData());
                          }),
                          (index) => setState(() {
                            roundRows[selectedRound]![index].dispose();
                            roundRows[selectedRound]!.removeAt(index);
                          }),
                          (index) => setState(() {
                            roundRows[selectedRound]!.insert(
                                index + 1, roundRows[selectedRound]![index].duplicate());
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Cooldown Tab.
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildReorderableTable(
                          cooldownRows,
                          () => setState(() {
                            cooldownRows.add(ExerciseRowData());
                          }),
                          (index) => setState(() {
                            cooldownRows[index].dispose();
                            cooldownRows.removeAt(index);
                          }),
                          (index) => setState(() {
                            cooldownRows.insert(index + 1, cooldownRows[index].duplicate());
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final output = _generateOutput();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Generated Exercises Data"),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 300, // Fixed height for the dialog's content.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(output),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: output));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Copied to clipboard")),
                              );
                            },
                            child: const Text("Copy to Clipboard"),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );

              },
              child: const Text("Submit Exercises"),
            ),
          ],
        ),
      ),
    );
  }
}
