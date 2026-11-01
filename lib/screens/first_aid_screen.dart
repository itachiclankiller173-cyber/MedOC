import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstAidItems = [
      // ============================================================
      // HEART ATTACK
      // ============================================================
      {
        "title": "Possible Heart Attack",
        "icon": Icons.favorite,
        "color": Colors.red,
        "description":
            "A heart attack happens when blood flow to part of the heart "
            "becomes blocked. It can be life-threatening and needs urgent "
            "medical attention. Warning signs can include chest pressure, "
            "squeezing or discomfort, pain or discomfort in an arm, back, "
            "neck, jaw or stomach, shortness of breath, sweating, nausea, "
            "lightheadedness, or unusual tiredness. Symptoms can be different "
            "from person to person.",
        "steps": [
          "Stop physical activity and help the person sit and rest.",
          "Call your local emergency medical service immediately if a heart attack is suspected.",
          "Tell the emergency operator the person's symptoms and location.",
          "Keep the person calm and stay with them.",
          "Follow the emergency dispatcher's instructions.",
          "Do not let the person drive themselves to hospital.",
          "If the person becomes unresponsive or is not breathing normally, follow emergency dispatcher instructions immediately.",
        ],
        "flow": [
          "❤️ Possible heart attack",
          "➡️ Stop activity",
          "➡️ Sit & rest",
          "➡️ Call emergency services",
          "➡️ Stay with the person",
          "➡️ Follow dispatcher instructions",
        ],
        "danger":
            "Chest pressure or discomfort with breathing difficulty, sweating, nausea, dizziness, or discomfort spreading to the arm, back, neck or jaw can be a heart-attack warning sign. Do not wait for it to disappear.",
      },

      // ============================================================
      // STROKE
      // ============================================================
      {
        "title": "Possible Stroke",
        "icon": Icons.psychology,
        "color": Colors.deepPurple,
        "description":
            "A stroke can happen when blood flow to part of the brain is "
            "blocked or when bleeding occurs in the brain. Treatment is "
            "time-sensitive. Sudden facial weakness, arm weakness, speech "
            "difficulty, vision changes, balance problems or severe sudden "
            "headache can be warning signs.",
        "steps": [
          "Look for sudden facial drooping or weakness.",
          "Ask the person to raise both arms and check whether one arm is weak.",
          "Listen for slurred, confused, or unusual speech.",
          "Call emergency medical services immediately if stroke is suspected.",
          "Note the approximate time the symptoms started or when the person was last known to be normal.",
          "Keep the person safe and follow emergency dispatcher instructions.",
          "Do not delay emergency care while trying home treatments.",
        ],
        "flow": [
          "🧠 Sudden symptoms",
          "➡️ Face: drooping?",
          "➡️ Arm: weakness?",
          "➡️ Speech: unusual?",
          "➡️ TIME: call emergency services",
          "➡️ Note when symptoms started",
        ],
        "danger":
            "Sudden face weakness, arm weakness, speech difficulty, vision problems, balance problems, or severe unexplained headache requires immediate emergency assessment.",
      },

      // ============================================================
      // CARDIAC ARREST
      // ============================================================
      {
        "title": "Cardiac Arrest",
        "icon": Icons.monitor_heart,
        "color": Colors.redAccent,
        "description":
            "Cardiac arrest occurs when the heart suddenly stops pumping blood "
            "effectively. The person usually becomes unresponsive and does "
            "not breathe normally. This is a life-threatening emergency.",
        "steps": [
          "Check whether the person responds when spoken to or gently tapped.",
          "Check whether they are breathing normally.",
          "Call emergency medical services immediately.",
          "Follow the emergency dispatcher's instructions.",
          "If you are trained in CPR, provide CPR as instructed.",
          "If an AED is available and you know how to use it, follow its voice instructions.",
          "Stay with the person until professional help arrives.",
        ],
        "flow": [
          "❤️ Person collapses",
          "➡️ Check responsiveness",
          "➡️ Check normal breathing",
          "➡️ Call emergency services",
          "➡️ Follow dispatcher instructions",
          "➡️ CPR/AED if trained and instructed",
        ],
        "danger":
            "Unresponsiveness with absent or abnormal breathing is an emergency. Call emergency services immediately.",
      },

      // ============================================================
      // HEAVY BLEEDING
      // ============================================================
      {
        "title": "Heavy Bleeding",
        "icon": Icons.bloodtype,
        "color": Colors.red,
        "description":
            "Severe bleeding can become dangerous quickly. The main priorities "
            "are getting emergency help and controlling the bleeding while "
            "protecting yourself from contact with blood.",
        "steps": [
          "Call emergency medical services for severe or uncontrolled bleeding.",
          "Use clean cloth, gauze, or another suitable clean material and apply firm direct pressure.",
          "Keep continuous pressure on the wound.",
          "If blood soaks through, place additional material over the existing dressing rather than repeatedly removing it.",
          "Keep the injured person as still and comfortable as possible.",
          "Do not remove a deeply embedded object from the wound.",
          "Follow emergency dispatcher instructions.",
        ],
        "flow": [
          "🩸 Heavy bleeding",
          "➡️ Call emergency services",
          "➡️ Apply firm pressure",
          "➡️ Keep pressure",
          "➡️ Keep person safe",
          "➡️ Wait for professionals",
        ],
        "danger":
            "Bleeding that is severe, continuous, spurting, or associated with weakness, confusion or collapse requires emergency medical care.",
      },

      // ============================================================
      // CHOKING
      // ============================================================
      {
        "title": "Choking",
        "icon": Icons.warning,
        "color": Colors.redAccent,
        "description":
            "Choking happens when an object blocks the airway. A person with "
            "mild choking may still cough or speak. A person with severe "
            "airway obstruction may be unable to breathe, speak, or cough effectively.",
        "steps": [
          "If the person can cough or speak, encourage them to keep coughing.",
          "If they cannot breathe, speak, or cough effectively, call emergency services immediately.",
          "Give choking first aid only if you are trained to do so.",
          "Do not blindly put your fingers into the person's mouth.",
          "If the person becomes unresponsive, follow the emergency dispatcher's instructions.",
          "Stay with the person until professional help arrives.",
        ],
        "flow": [
          "⚠️ Choking",
          "➡️ Can they cough/speak?",
          "➡️ YES → Encourage coughing",
          "➡️ NO → Emergency call",
          "➡️ Follow dispatcher instructions",
        ],
        "danger":
            "Unable to breathe, speak or cough effectively is a medical emergency.",
      },

      // ============================================================
      // SEIZURE
      // ============================================================
      {
        "title": "Seizure",
        "icon": Icons.accessibility_new,
        "color": Colors.indigo,
        "description":
            "During a seizure, a person may suddenly lose awareness, become "
            "stiff, or have uncontrolled movements. The priority is to prevent "
            "injury and keep the person safe while the seizure passes.",
        "steps": [
          "Stay calm and stay with the person.",
          "Move dangerous objects away from them.",
          "If possible, help protect their head from injury.",
          "Do not restrain the person's movements.",
          "Do not put anything into their mouth.",
          "Do not give food, drink, or oral medicine while they are having the seizure or are not fully alert.",
          "Call emergency services for a first seizure, a seizure lasting more than 5 minutes, repeated seizures without recovery, breathing difficulty, injury, or other serious warning signs.",
          "After the seizure, stay with the person and follow medical advice.",
        ],
        "flow": [
          "⚡ Seizure",
          "➡️ Keep surroundings safe",
          "➡️ Protect from injury",
          "➡️ Do NOT restrain",
          "➡️ Nothing in mouth",
          "➡️ Emergency help if serious",
        ],
        "danger":
            "A first seizure, seizure lasting more than 5 minutes, repeated seizures, injury, breathing difficulty, or failure to recover normally requires emergency medical help.",
      },

      // ============================================================
      // SERIOUS ALLERGIC REACTION
      // ============================================================
      {
        "title": "Severe Allergic Reaction",
        "icon": Icons.warning_amber,
        "color": Colors.deepOrange,
        "description":
            "A severe allergic reaction can develop quickly. Warning signs "
            "can include swelling of the face, lips or tongue, difficulty "
            "breathing, wheezing, widespread hives, vomiting, dizziness or collapse.",
        "steps": [
          "Call emergency medical services immediately if a severe reaction is suspected.",
          "Help the person use their prescribed emergency medicine if they have one and if you are instructed or trained to assist.",
          "Keep the person in a safe position and stay with them.",
          "Watch their breathing and responsiveness.",
          "Follow emergency dispatcher instructions.",
          "Do not leave the person alone.",
        ],
        "flow": [
          "😰 Allergic reaction",
          "➡️ Swelling / breathing problem?",
          "➡️ Call emergency services",
          "➡️ Use prescribed emergency medicine if appropriate",
          "➡️ Monitor & wait for help",
        ],
        "danger":
            "Difficulty breathing, swelling of the tongue or throat, collapse, or rapidly worsening symptoms are emergencies.",
      },

      // ============================================================
      // BREATHING DIFFICULTY
      // ============================================================
      {
        "title": "Breathing Difficulty",
        "icon": Icons.air,
        "color": Colors.blue,
        "description":
            "Breathing difficulty can have many causes, including asthma, "
            "allergic reactions, infections, heart problems, choking, or injury. "
            "Severe breathing difficulty needs urgent medical attention.",
        "steps": [
          "Help the person stop activity and stay calm.",
          "Allow them to sit in a comfortable position.",
          "Move away from smoke or other obvious irritants if safe.",
          "If they have prescribed emergency breathing medicine, help them use it according to their existing medical instructions.",
          "Call emergency medical services if breathing is severe, worsening, or associated with blue/grey lips, confusion, collapse, or inability to speak normally.",
          "Stay with the person until help arrives.",
        ],
        "flow": [
          "😮‍💨 Trouble breathing",
          "➡️ Stop activity",
          "➡️ Sit comfortably",
          "➡️ Use prescribed medicine if appropriate",
          "➡️ Emergency help if severe",
          "➡️ Monitor",
        ],
        "danger":
            "Severe difficulty breathing, inability to speak normally, blue/grey lips, confusion or collapse requires immediate emergency help.",
      },

      // ============================================================
      // BURNS
      // ============================================================
      {
        "title": "Burns",
        "icon": Icons.local_fire_department,
        "color": Colors.orange,
        "description":
            "Burns can result from heat, hot liquids, steam, chemicals, "
            "electricity, or other sources. The first priority is to stop "
            "the burning process and cool the affected area safely.",
        "steps": [
          "Move away from the heat or burning source.",
          "Cool the affected area under cool running water for about 20 minutes.",
          "Remove jewellery or tight clothing near the burn if it is not stuck to the skin.",
          "Cover the burn loosely with a clean, non-fluffy dressing.",
          "Do not put ice, butter, toothpaste, or other household substances on a fresh burn.",
          "Do not peel away clothing stuck to the burn.",
          "Seek medical help for large, deep, chemical, electrical, facial, or otherwise serious burns.",
        ],
        "flow": [
          "🔥 Burn",
          "➡️ Stop contact with heat",
          "➡️ Cool with running water",
          "➡️ Cover loosely",
          "➡️ Medical help if serious",
        ],
        "danger":
            "Large, deep, electrical, chemical, facial or extensive burns need professional medical assessment.",
      },

      // ============================================================
      // CUTS
      // ============================================================
      {
        "title": "Cuts & Scrapes",
        "icon": Icons.healing,
        "color": Colors.pink,
        "description":
            "Small cuts and scrapes can often be managed with basic wound "
            "care. The main priorities are controlling bleeding, cleaning "
            "the wound, and protecting it from contamination.",
        "steps": [
          "Wash your hands before helping.",
          "Apply gentle pressure with clean cloth or gauze if there is bleeding.",
          "After bleeding is controlled, gently clean the wound with clean water.",
          "Cover the wound with a clean dressing or bandage.",
          "Keep the dressing clean and replace it when dirty or wet.",
          "Watch for increasing redness, swelling, pain, or discharge.",
          "Seek medical care for deep wounds, uncontrolled bleeding, or serious accident injuries.",
        ],
        "flow": [
          "🩹 Cut",
          "➡️ Control bleeding",
          "➡️ Clean with water",
          "➡️ Cover",
          "➡️ Monitor",
          "➡️ Get help if serious",
        ],
        "danger":
            "Deep wounds, uncontrolled bleeding, heavily contaminated wounds, or serious accident injuries need medical attention.",
      },

      // ============================================================
      // FRACTURE
      // ============================================================
      {
        "title": "Possible Fracture",
        "icon": Icons.accessibility,
        "color": Colors.deepPurple,
        "description":
            "A fracture means a bone may be broken. Severe pain, swelling, "
            "deformity, inability to use the limb, or an unusual position "
            "can occur. Avoid unnecessary movement.",
        "steps": [
          "Keep the injured area as still as possible.",
          "Do not try to straighten the limb.",
          "Support the injured area in the position in which you found it.",
          "Use a wrapped cold pack if appropriate to help with swelling.",
          "Do not allow weight on a possibly broken leg or foot.",
          "Get medical assessment, particularly after a major accident.",
          "Call emergency services if there is severe injury, heavy bleeding, or loss of feeling or movement.",
        ],
        "flow": [
          "🦴 Possible fracture",
          "➡️ Keep still",
          "➡️ Support the area",
          "➡️ Do not straighten",
          "➡️ Medical assessment",
        ],
        "danger":
            "Severe pain, deformity, numbness, major trauma, or loss of movement requires urgent medical assessment.",
      },

      // ============================================================
      // HEAD INJURY
      // ============================================================
      {
        "title": "Head Injury",
        "icon": Icons.psychology_alt,
        "color": Colors.indigo,
        "description":
            "Head injuries can range from minor bumps to serious brain "
            "injuries. Symptoms can sometimes appear or worsen later, so "
            "observation is important after a significant impact.",
        "steps": [
          "Stop the activity and keep the person calm.",
          "Check whether they are alert and responding normally.",
          "Do not allow them to continue sports after a significant head impact.",
          "A wrapped cold pack may help with a minor bump.",
          "Watch for worsening headache, repeated vomiting, confusion, unusual sleepiness, weakness, seizure, or loss of consciousness.",
          "Seek urgent medical help if serious symptoms occur.",
          "Do not leave a seriously injured person alone.",
        ],
        "flow": [
          "🧠 Head impact",
          "➡️ Stop activity",
          "➡️ Check alertness",
          "➡️ Watch for warning signs",
          "➡️ Emergency help if serious",
        ],
        "danger":
            "Loss of consciousness, repeated vomiting, seizure, confusion, weakness, worsening headache, or a major accident requires urgent assessment.",
      },

      // ============================================================
      // EYE INJURY
      // ============================================================
      {
        "title": "Eye Injury",
        "icon": Icons.visibility,
        "color": Colors.cyan,
        "description":
            "Eye injuries need careful handling because rubbing, pressing, "
            "or trying to remove a stuck object can make the injury worse.",
        "steps": [
          "Do not rub or press the injured eye.",
          "If a small loose particle is present, gently rinse the eye with clean water.",
          "Do not try to remove an object that is stuck in the eye.",
          "Do not put medicines or other substances into the eye unless advised by a healthcare professional.",
          "Get urgent medical attention after serious impact, chemical exposure, vision change, or penetrating injury.",
        ],
        "flow": [
          "👁️ Eye injury",
          "➡️ Do not rub",
          "➡️ Rinse loose particles",
          "➡️ Do not remove stuck objects",
          "➡️ Get medical help if serious",
        ],
        "danger":
            "Vision changes, severe pain, chemical exposure, or an object stuck in the eye requires urgent medical attention.",
      },

      // ============================================================
      // NOSEBLEED
      // ============================================================
      {
        "title": "Nosebleed",
        "icon": Icons.air,
        "color": Colors.lightBlue,
        "description":
            "Most nosebleeds are minor. Correct positioning and continuous "
            "pressure can help control the bleeding.",
        "steps": [
          "Sit upright.",
          "Lean slightly forward.",
          "Pinch the soft part of the nose continuously for about 10–15 minutes.",
          "Breathe through the mouth.",
          "Do not tilt the head backward.",
          "Avoid blowing or picking the nose immediately afterward.",
          "Seek medical help if bleeding is heavy or does not stop.",
        ],
        "flow": [
          "👃 Nosebleed",
          "➡️ Sit upright",
          "➡️ Lean forward",
          "➡️ Pinch soft nose",
          "➡️ Wait 10–15 minutes",
          "➡️ Seek help if persistent",
        ],
        "danger":
            "Heavy bleeding or bleeding that does not stop requires medical assessment.",
      },

      // ============================================================
      // SPRAIN
      // ============================================================
      {
        "title": "Sprain",
        "icon": Icons.directions_run,
        "color": Colors.green,
        "description":
            "A sprain can occur when a joint is twisted or stretched suddenly. "
            "Pain and swelling are common.",
        "steps": [
          "Stop the activity.",
          "Rest and protect the injured area.",
          "Use a wrapped cold pack for short periods.",
          "Keep the injured area elevated when practical.",
          "Avoid activities that increase pain.",
          "Seek medical care if you cannot use the limb normally or there is major swelling or deformity.",
        ],
        "flow": [
          "🦶 Sprain",
          "➡️ Stop activity",
          "➡️ Rest & protect",
          "➡️ Cold pack",
          "➡️ Elevate",
          "➡️ Get checked if severe",
        ],
        "danger":
            "Severe pain, deformity, major swelling, or inability to use the limb normally needs medical assessment.",
      },

      // ============================================================
      // ROAD ACCIDENT
      // ============================================================
      {
        "title": "Road Accident",
        "icon": Icons.directions_car,
        "color": Colors.blueGrey,
        "description":
            "Road accidents can cause multiple injuries, including internal "
            "injuries that may not be obvious immediately. Scene safety is "
            "the first priority.",
        "steps": [
          "Move to a safe location only if doing so does not create additional danger.",
          "Call emergency services and give the exact location.",
          "Do not unnecessarily move an injured person after a major accident.",
          "Check whether the person is responsive and breathing normally.",
          "Control visible bleeding with clean cloth or gauze when appropriate.",
          "Keep the person calm and as still as possible.",
          "Do not give food or drink to a seriously injured person.",
          "Wait for trained emergency responders.",
        ],
        "flow": [
          "🚗 Road accident",
          "➡️ Make scene safe",
          "➡️ Call emergency services",
          "➡️ Check responsiveness",
          "➡️ Control bleeding",
          "➡️ Keep still",
          "➡️ Wait for responders",
        ],
        "danger":
            "Major road accidents should be treated as potentially serious even when injuries initially appear minor.",
      },

      // ============================================================
      // FALL
      // ============================================================
      {
        "title": "Fall Injury",
        "icon": Icons.personal_injury,
        "color": Colors.brown,
        "description":
            "A fall can cause bruises, sprains, fractures, spinal injuries, "
            "or head injuries. Avoid making the person stand immediately "
            "after a significant fall.",
        "steps": [
          "Do not immediately ask the person to stand after a significant fall.",
          "Check for pain, bleeding, difficulty moving, or unusual symptoms.",
          "Keep the injured area still if a fracture is suspected.",
          "Use a wrapped cold pack for minor swelling if appropriate.",
          "After a head impact, watch for concerning symptoms.",
          "Seek medical attention after a serious fall or worsening symptoms.",
        ],
        "flow": [
          "⬇️ Fall",
          "➡️ Keep person still",
          "➡️ Check injuries",
          "➡️ Support injured area",
          "➡️ Watch for warning signs",
          "➡️ Seek help if serious",
        ],
        "danger":
            "A serious fall, head impact, severe pain, neck/back pain, or inability to move normally needs medical assessment.",
      },

      // ============================================================
      // ELECTRIC SHOCK
      // ============================================================
      {
        "title": "Electric Shock",
        "icon": Icons.bolt,
        "color": Colors.amber,
        "description":
            "Electrical injuries can cause burns and internal injuries. "
            "The rescuer must avoid becoming part of the electrical circuit.",
        "steps": [
          "Do not touch the person while they may still be connected to electricity.",
          "Switch off or disconnect the power source only if it can be done safely.",
          "Call emergency medical services for a significant electric shock.",
          "Once the area is safe, check whether the person is responsive and breathing normally.",
          "Follow emergency dispatcher instructions.",
          "Medical assessment may be needed even when the person appears okay.",
        ],
        "flow": [
          "⚡ Electric shock",
          "➡️ Do NOT touch",
          "➡️ Make power source safe",
          "➡️ Call emergency services",
          "➡️ Check person when safe",
          "➡️ Follow instructions",
        ],
        "danger":
            "Never touch someone who may still be in contact with an electrical source.",
      },

      // ============================================================
      // ANIMAL BITE
      // ============================================================
      {
        "title": "Animal Bite",
        "icon": Icons.pets,
        "color": Colors.teal,
        "description":
            "Animal bites can break the skin and may cause infection. "
            "Some bites also require assessment for vaccination or other "
            "preventive treatment.",
        "steps": [
          "Move away from the animal and make the area safe.",
          "Wash the affected area thoroughly with soap and running water.",
          "Do not attempt to catch or handle an unfamiliar animal.",
          "Cover the wound with a clean dressing.",
          "Seek medical attention promptly.",
          "Tell the healthcare professional what type of animal was involved if known.",
        ],
        "flow": [
          "🐕 Animal bite",
          "➡️ Move away safely",
          "➡️ Wash with soap & water",
          "➡️ Cover wound",
          "➡️ Seek medical advice",
        ],
        "danger":
            "Animal bites should be medically assessed because infection and vaccination needs may need to be considered.",
      },

      // ============================================================
      // HEAT EXHAUSTION
      // ============================================================
      {
        "title": "Heat Exhaustion",
        "icon": Icons.wb_sunny,
        "color": Colors.orangeAccent,
        "description":
            "Heat exhaustion can happen when the body becomes overheated, "
            "especially during hot weather or physical activity. Symptoms "
            "may include heavy sweating, weakness, dizziness, headache and nausea.",
        "steps": [
          "Move the person to a cool or shaded place.",
          "Allow them to rest and cool down.",
          "Loosen unnecessary clothing.",
          "Give small amounts of cool water if they are fully awake and able to drink.",
          "Use cool wet cloths or other safe cooling methods.",
          "Monitor the person's condition.",
          "Seek urgent medical help if the person becomes confused, collapses, has a seizure, or does not improve.",
        ],
        "flow": [
          "☀️ Too much heat",
          "➡️ Move to cool place",
          "➡️ Rest & cool",
          "➡️ Drink water if safe",
          "➡️ Monitor",
          "➡️ Emergency help if worsening",
        ],
        "danger":
            "Confusion, collapse, seizure, or failure to improve can indicate a serious heat emergency.",
      },

      // ============================================================
      // FEVER
      // ============================================================
      {
        "title": "Fever",
        "icon": Icons.thermostat,
        "color": Colors.deepOrange,
        "description":
            "Fever is a rise in body temperature that can occur with infections "
            "and other illnesses. The most important thing is to monitor the "
            "person and watch for serious symptoms.",
        "steps": [
          "Allow the person to rest.",
          "Encourage fluids when they are awake and able to drink.",
          "Avoid overheating with excessive clothing or blankets.",
          "Monitor temperature and other symptoms.",
          "Follow medicine instructions provided by a parent, guardian, doctor, or pharmacist.",
          "Seek medical care if symptoms are severe, persistent, or concerning.",
        ],
        "flow": [
          "🌡️ Fever",
          "➡️ Rest",
          "➡️ Fluids",
          "➡️ Monitor temperature",
          "➡️ Watch symptoms",
          "➡️ Seek help if concerning",
        ],
        "danger":
            "Difficulty breathing, confusion, severe weakness, dehydration, seizure, or other serious symptoms require medical attention.",
      },

      // ============================================================
      // LOW BLOOD SUGAR
      // ============================================================
      {
        "title": "Possible Low Blood Sugar",
        "icon": Icons.bloodtype_outlined,
        "color": Colors.purple,
        "description":
            "Low blood sugar can cause shakiness, sweating, weakness, dizziness, "
            "confusion, unusual behavior, or difficulty speaking. It can become "
            "serious if the person becomes unable to respond or swallow safely.",
        "steps": [
          "If the person is awake, alert, and able to swallow safely, follow their existing diabetes care plan.",
          "If they have prescribed glucose treatment, help them use it according to their plan.",
          "Stay with the person and monitor their condition.",
          "If they are confused, unconscious, having a seizure, or unable to swallow safely, call emergency services.",
          "Do not give food, drink, or medicine by mouth to someone who cannot swallow safely.",
        ],
        "flow": [
          "🩸 Possible low sugar",
          "➡️ Awake & able to swallow?",
          "➡️ YES → Follow care plan",
          "➡️ NO → Emergency help",
          "➡️ Monitor",
        ],
        "danger":
            "Unconsciousness, seizure, severe confusion, or inability to swallow safely is an emergency.",
      },

      // ============================================================
      // POISONING
      // ============================================================
      {
        "title": "Possible Poisoning",
        "icon": Icons.warning,
        "color": Colors.brown,
        "description":
            "Poisoning can happen after swallowing, breathing in, or coming "
            "into contact with a harmful substance. The correct response "
            "depends on the substance and route of exposure.",
        "steps": [
          "Move away from the source if it is safe to do so.",
          "Call your local emergency service or poison information service for guidance.",
          "Tell them what substance may be involved, if known.",
          "Keep the container or product information available if it can be done safely.",
          "Do not make the person vomit unless specifically instructed by a healthcare professional.",
          "If the person becomes unresponsive or has serious breathing problems, follow emergency dispatcher instructions.",
        ],
        "flow": [
          "☠️ Possible poisoning",
          "➡️ Move away safely",
          "➡️ Call emergency help",
          "➡️ Identify substance if possible",
          "➡️ Follow professional instructions",
          "➡️ Monitor",
        ],
        "danger":
            "Unresponsiveness, breathing difficulty, seizures, severe symptoms, or suspected serious poisoning requires emergency help.",
      },

      // ============================================================
      // DROWNING
      // ============================================================
      {
        "title": "Drowning / Water Emergency",
        "icon": Icons.pool,
        "color": Colors.blue,
        "description":
            "A person rescued from water may have serious breathing problems "
            "even if they initially appear better. Rescuer safety is essential.",
        "steps": [
          "Do not enter dangerous water unless you are trained and it is safe.",
          "Call emergency services.",
          "Once the person is safely out of the water, check responsiveness and breathing.",
          "Follow emergency dispatcher instructions.",
          "If the person is breathing normally, keep them warm and monitor them.",
          "If they are not breathing normally, follow dispatcher instructions for emergency care.",
        ],
        "flow": [
          "🌊 Water emergency",
          "➡️ Keep rescuer safe",
          "➡️ Call emergency services",
          "➡️ Get person to safety",
          "➡️ Check responsiveness & breathing",
          "➡️ Follow dispatcher instructions",
        ],
        "danger":
            "Any significant drowning event or breathing problem after water exposure needs urgent medical assessment.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("First-Aid Guide"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================================
          // INTRO
          // ============================================================
          Card(
            color: Colors.teal.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.medical_services, color: Colors.teal, size: 38),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "MedOC First-Aid Guide provides simple information "
                      "for common injuries, accidents and medical emergencies. "
                      "It is designed to help you understand what to do while "
                      "professional medical help is being arranged. "
                      "It does not replace a doctor, trained first-aider, "
                      "ambulance service, or emergency department.",
                      style: TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // GENERAL FLOW
          // ============================================================
          const Text(
            "First-Aid: What Should I Do?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _SimpleFlow(
            steps: const [
              "👀 Identify the problem",
              "🛡️ Make the area safe",
              "📞 Call emergency help if serious",
              "🩹 Give safe basic first aid",
              "👨‍⚕️ Follow professional instructions",
            ],
          ),

          const SizedBox(height: 25),

          // ============================================================
          // EMERGENCY WARNING
          // ============================================================
          Card(
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.emergency, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "When to Treat It as an Emergency",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Call your local emergency medical service for "
                    "unresponsiveness, abnormal or absent breathing, "
                    "severe bleeding, serious chest pain, signs of stroke, "
                    "severe breathing difficulty, major accidents, serious "
                    "head injuries, severe allergic reactions, or other "
                    "life-threatening situations.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.45),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Common Emergencies & Injuries",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // ============================================================
          // ALL FIRST AID ITEMS
          // ============================================================
          ...firstAidItems.map(
            (item) => _FirstAidCard(
              title: item["title"] as String,
              icon: item["icon"] as IconData,
              color: item["color"] as Color,
              description: item["description"] as String,
              steps: List<String>.from(item["steps"] as List),
              flow: List<String>.from(item["flow"] as List),
              danger: item["danger"] as String,
            ),
          ),

          const SizedBox(height: 20),

          // ============================================================
          // FINAL SAFETY MESSAGE
          // ============================================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Icon(
                    Icons.health_and_safety,
                    color: Colors.teal,
                    size: 38,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Remember",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your safety comes first. Do not put yourself in danger "
                    "while trying to help someone. If you are unsure what "
                    "to do, contact emergency medical services and follow "
                    "the instructions given by the emergency dispatcher.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ====================================================================
// FIRST AID CARD
// ====================================================================

class _FirstAidCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> steps;
  final List<String> flow;
  final String danger;

  const _FirstAidCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.steps,
    required this.flow,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),

        subtitle: const Text(
          "Tap to view details and first-aid flow",
          style: TextStyle(fontSize: 12),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // DESCRIPTION
                // ------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 15, height: 1.45),
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------------
                // FLOW
                // ------------------------------------------------------
                const Text(
                  "Simple Flow",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                _SimpleFlow(steps: flow),

                const SizedBox(height: 20),

                // ------------------------------------------------------
                // STEPS
                // ------------------------------------------------------
                const Text(
                  "What to Do",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...List.generate(
                  steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: color,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            steps[index],
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ------------------------------------------------------
                // WARNING
                // ------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "When to get medical help:\n$danger",
                          style: const TextStyle(fontSize: 14, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// FLOW DIAGRAM
// ====================================================================

class _SimpleFlow extends StatelessWidget {
  final List<String> steps;

  const _SimpleFlow({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final isLast = index == steps.length - 1;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    Icons.arrow_downward,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
