import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ThreeDModelScreen extends StatefulWidget {
  const ThreeDModelScreen({super.key});

  @override
  State<ThreeDModelScreen> createState() => _ThreeDModelScreenState();
}

class _ThreeDModelScreenState extends State<ThreeDModelScreen> {
  // ------------------------------------------------------------
  // 3D MODELS
  // ------------------------------------------------------------

  String selectedModel = 'assets/models/angiology.glb';
  String selectedName = 'Angiology';

  final List<Map<String, String>> models = [
    {
      'name': 'Angiology',
      'file': 'assets/models/angiology.glb',
    },
    {
      'name': 'Neurology',
      'file': 'assets/models/neurology.glb',
    },
    {
      'name': 'Myology',
      'file': 'assets/models/myology.glb',
    },
    {
      'name': 'Arthrology',
      'file': 'assets/models/arthrology.glb',
    },
    {
      'name': 'Muscular Insertions',
      'file': 'assets/models/muscular_insertions.glb',
    },
  ];

  // ------------------------------------------------------------
  // BODY REGIONS
  // ------------------------------------------------------------

  final List<String> bodyRegions = [
    'Head',
    'Eyes',
    'Ears',
    'Nose',
    'Mouth',
    'Neck',
    'Chest',
    'Heart',
    'Lungs',
    'Abdomen',
    'Back',
    'Left Shoulder',
    'Right Shoulder',
    'Left Arm',
    'Right Arm',
    'Left Hand',
    'Right Hand',
    'Left Thigh',
    'Right Thigh',
    'Left Knee',
    'Right Knee',
    'Left Leg',
    'Right Leg',
    'Left Foot',
    'Right Foot',
  ];

  String? selectedRegion;
  String selectedSide = 'Center';

  // ------------------------------------------------------------
  // SYMPTOM DATA
  // ------------------------------------------------------------

  final List<Map<String, dynamic>> symptoms = [];

  final TextEditingController symptomController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  int painSeverity = 1;

  // ------------------------------------------------------------
  // MODEL SELECTION
  // ------------------------------------------------------------

  void selectModel(String name, String file) {
    setState(() {
      selectedName = name;
      selectedModel = file;
    });
  }

  // ------------------------------------------------------------
  // REGION SELECTION
  // ------------------------------------------------------------

  void selectRegion(String region) {
    setState(() {
      selectedRegion = region;

      if (region.startsWith('Left')) {
        selectedSide = 'Left';
      } else if (region.startsWith('Right')) {
        selectedSide = 'Right';
      } else {
        selectedSide = 'Center';
      }
    });
  }

  void clearRegion() {
    setState(() {
      selectedRegion = null;
      selectedSide = 'Center';
    });
  }

  // ------------------------------------------------------------
  // SYMPTOM DIALOG
  // ------------------------------------------------------------

  void showSymptomDialog() {
    if (selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a body region first.'),
        ),
      );
      return;
    }

    symptomController.clear();
    durationController.clear();
    notesController.clear();

    painSeverity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B2A34),
              title: Text(
                'Record Symptom',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // REGION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF263640),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$selectedRegion • $selectedSide',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SYMPTOM
                    TextField(
                      controller: symptomController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Symptom',
                        hintText:
                            'Example: pain, swelling, discomfort',
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PAIN
                    Text(
                      'Pain severity: $painSeverity / 10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Slider(
                      min: 1,
                      max: 10,
                      divisions: 9,
                      value: painSeverity.toDouble(),
                      onChanged: (value) {
                        setDialogState(() {
                          painSeverity = value.round();
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    // DURATION
                    TextField(
                      controller: durationController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        hintText: 'Example: 2 days',
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // NOTES
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Additional information',
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    saveSymptom();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SAVE SYMPTOM
  // ------------------------------------------------------------

  void saveSymptom() {
    if (selectedRegion == null) return;

    final symptom = {
      'region': selectedRegion!,
      'side': selectedSide,
      'symptom': symptomController.text.trim().isEmpty
          ? 'Not specified'
          : symptomController.text.trim(),
      'pain': painSeverity,
      'duration': durationController.text.trim().isEmpty
          ? 'Not specified'
          : durationController.text.trim(),
      'notes': notesController.text.trim(),
      'time': DateTime.now(),
    };

    setState(() {
      symptoms.add(symptom);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedRegion!} symptom saved',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // BODY REGION BUTTONS
  // ------------------------------------------------------------

  Widget buildBodyRegionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Symptom Region',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Choose the area where you have a symptom.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bodyRegions.map((region) {
            final isSelected =
                selectedRegion == region;

            return ChoiceChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (_) {
                selectRegion(region);
              },
              selectedColor:
                  Colors.blueAccent,
              backgroundColor:
                  const Color(0xFF263640),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white70,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SELECTED REGION CARD
  // ------------------------------------------------------------

  Widget buildSelectedRegionCard() {
    if (selectedRegion == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF182630),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white12,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.touch_app,
              color: Colors.white54,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select a body region to record a symptom.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blueAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor:
                    Colors.blueAccent,
                child: Icon(
                  Icons.accessibility_new,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Region',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      selectedRegion!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Side: $selectedSide',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: clearRegion,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: showSymptomDialog,
              icon: const Icon(Icons.add),
              label: const Text(
                'Record Symptom',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SAVED SYMPTOMS
  // ------------------------------------------------------------

  Widget buildSavedSymptoms() {
    if (symptoms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text(
          'Recorded Symptoms',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...symptoms.asMap().entries.map((entry) {
          final index = entry.key;
          final symptom = entry.value;

          return Card(
            color: const Color(0xFF182630),
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor:
                    Colors.blueAccent,
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              ),

              title: Text(
                symptom['region'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                '${symptom['symptom']} • Pain ${symptom['pain']}/10',
                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),

              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    symptoms.removeAt(index);
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ------------------------------------------------------------
  // MODEL BUTTONS
  // ------------------------------------------------------------

  Widget buildModelButtons() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];

          final isSelected =
              model['file'] == selectedModel;

          return Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: SizedBox(
              width: 145,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF263640),
                  foregroundColor: Colors.white,
                  elevation: isSelected ? 5 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.white24,
                    ),
                  ),
                ),
                onPressed: () {
                  selectModel(
                    model['name']!,
                    model['file']!,
                  );
                },
                child: Text(
                  model['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF101820),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '3D Human Anatomy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // MODEL NAME
              Center(
                child: Text(
                  selectedName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3D MODEL
              Container(
                height: 420,
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF182630),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ModelViewer(
                  key: ValueKey(selectedModel),
                  src: selectedModel,
                  alt: selectedName,
                  autoRotate: true,
                  cameraControls: true,
                  ar: false,
                  backgroundColor:
                      const Color(0xFF182630),
                ),
              ),

              const SizedBox(height: 14),

              // INSTRUCTION
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blueAccent,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rotate and zoom the 3D model, then select the body region below to record a symptom.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BODY REGIONS
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                    buildBodyRegionSelector(),
              ),

              const SizedBox(height: 18),

              // SELECTED REGION
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                    buildSelectedRegionCard(),
              ),

              // SAVED SYMPTOMS
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                    buildSavedSymptoms(),
              ),

              const SizedBox(height: 20),

              // MODEL SELECTION
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(
                  'Anatomy Models',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              buildModelButtons(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    symptomController.dispose();
    durationController.dispose();
    notesController.dispose();
    super.dispose();
  }
}