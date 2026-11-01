import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionAnalysisScreen extends StatefulWidget {
  const NutritionAnalysisScreen({super.key});

  @override
  State<NutritionAnalysisScreen> createState() =>
      _NutritionAnalysisScreenState();
}

class _NutritionAnalysisScreenState extends State<NutritionAnalysisScreen> {
  static const String historyKey = "nutrition_history";

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = "All";
  String selectedMeal = "Breakfast";

  final List<Map<String, dynamic>> foods = [
    // ============================================================
    // KERALA / SOUTH INDIAN
    // ============================================================
    {
      "name": "Matta Rice",
      "category": "Rice & Grains",
      "unit": "100 g cooked",
      "calories": 130.0,
      "protein": 2.7,
      "carbs": 28.0,
      "fat": 0.3,
      "fiber": 1.5,
    },
    {
      "name": "White Rice",
      "category": "Rice & Grains",
      "unit": "100 g cooked",
      "calories": 130.0,
      "protein": 2.4,
      "carbs": 28.2,
      "fat": 0.3,
      "fiber": 0.4,
    },
    {
      "name": "Brown Rice",
      "category": "Rice & Grains",
      "unit": "100 g cooked",
      "calories": 123.0,
      "protein": 2.7,
      "carbs": 25.6,
      "fat": 1.0,
      "fiber": 1.6,
    },
    {
      "name": "Idli",
      "category": "Kerala & South Indian",
      "unit": "1 piece",
      "calories": 58.0,
      "protein": 2.0,
      "carbs": 12.0,
      "fat": 0.2,
      "fiber": 0.5,
    },
    {
      "name": "Dosa",
      "category": "Kerala & South Indian",
      "unit": "1 medium",
      "calories": 120.0,
      "protein": 3.0,
      "carbs": 18.0,
      "fat": 4.0,
      "fiber": 1.0,
    },
    {
      "name": "Masala Dosa",
      "category": "Kerala & South Indian",
      "unit": "1 medium",
      "calories": 300.0,
      "protein": 6.0,
      "carbs": 45.0,
      "fat": 10.0,
      "fiber": 3.0,
    },
    {
      "name": "Appam",
      "category": "Kerala & South Indian",
      "unit": "1 piece",
      "calories": 120.0,
      "protein": 2.0,
      "carbs": 20.0,
      "fat": 3.0,
      "fiber": 1.0,
    },
    {
      "name": "Puttu",
      "category": "Kerala & South Indian",
      "unit": "100 g",
      "calories": 170.0,
      "protein": 3.5,
      "carbs": 30.0,
      "fat": 4.0,
      "fiber": 2.0,
    },
    {
      "name": "Upma",
      "category": "Kerala & South Indian",
      "unit": "100 g",
      "calories": 150.0,
      "protein": 3.5,
      "carbs": 25.0,
      "fat": 4.0,
      "fiber": 2.0,
    },
    {
      "name": "Idiyappam",
      "category": "Kerala & South Indian",
      "unit": "1 piece",
      "calories": 80.0,
      "protein": 1.5,
      "carbs": 17.0,
      "fat": 0.5,
      "fiber": 0.5,
    },

    // ============================================================
    // CURRIES
    // ============================================================
    {
      "name": "Kadala Curry",
      "category": "Curries",
      "unit": "100 g",
      "calories": 150.0,
      "protein": 7.0,
      "carbs": 20.0,
      "fat": 5.0,
      "fiber": 5.0,
    },
    {
      "name": "Sambar",
      "category": "Curries",
      "unit": "100 g",
      "calories": 70.0,
      "protein": 3.0,
      "carbs": 10.0,
      "fat": 2.0,
      "fiber": 3.0,
    },
    {
      "name": "Avial",
      "category": "Curries",
      "unit": "100 g",
      "calories": 100.0,
      "protein": 2.0,
      "carbs": 8.0,
      "fat": 6.0,
      "fiber": 3.0,
    },
    {
      "name": "Vegetable Thoran",
      "category": "Curries",
      "unit": "100 g",
      "calories": 100.0,
      "protein": 2.0,
      "carbs": 8.0,
      "fat": 6.0,
      "fiber": 3.0,
    },
    {
      "name": "Olan",
      "category": "Curries",
      "unit": "100 g",
      "calories": 90.0,
      "protein": 2.0,
      "carbs": 8.0,
      "fat": 5.0,
      "fiber": 2.0,
    },
    {
      "name": "Erissery",
      "category": "Curries",
      "unit": "100 g",
      "calories": 120.0,
      "protein": 3.0,
      "carbs": 18.0,
      "fat": 4.0,
      "fiber": 4.0,
    },
    {
      "name": "Dal Curry",
      "category": "Curries",
      "unit": "100 g",
      "calories": 110.0,
      "protein": 6.0,
      "carbs": 16.0,
      "fat": 2.5,
      "fiber": 4.0,
    },
    {
      "name": "Moru Curry",
      "category": "Curries",
      "unit": "100 ml",
      "calories": 60.0,
      "protein": 3.0,
      "carbs": 5.0,
      "fat": 3.0,
      "fiber": 0.5,
    },

    // ============================================================
    // PROTEIN
    // ============================================================
    {
      "name": "Boiled Egg",
      "category": "Protein",
      "unit": "1 egg",
      "calories": 78.0,
      "protein": 6.3,
      "carbs": 0.6,
      "fat": 5.3,
      "fiber": 0.0,
    },
    {
      "name": "Chicken",
      "category": "Protein",
      "unit": "100 g cooked",
      "calories": 165.0,
      "protein": 31.0,
      "carbs": 0.0,
      "fat": 3.6,
      "fiber": 0.0,
    },
    {
      "name": "Fish",
      "category": "Protein",
      "unit": "100 g cooked",
      "calories": 140.0,
      "protein": 24.0,
      "carbs": 0.0,
      "fat": 5.0,
      "fiber": 0.0,
    },
    {
      "name": "Sardine",
      "category": "Protein",
      "unit": "100 g",
      "calories": 208.0,
      "protein": 25.0,
      "carbs": 0.0,
      "fat": 11.0,
      "fiber": 0.0,
    },
    {
      "name": "Tuna",
      "category": "Protein",
      "unit": "100 g",
      "calories": 130.0,
      "protein": 29.0,
      "carbs": 0.0,
      "fat": 1.0,
      "fiber": 0.0,
    },
    {
      "name": "Paneer",
      "category": "Protein",
      "unit": "100 g",
      "calories": 265.0,
      "protein": 18.0,
      "carbs": 6.0,
      "fat": 20.0,
      "fiber": 0.0,
    },
    {
      "name": "Chickpeas",
      "category": "Protein",
      "unit": "100 g cooked",
      "calories": 164.0,
      "protein": 8.9,
      "carbs": 27.0,
      "fat": 2.6,
      "fiber": 7.6,
    },
    {
      "name": "Green Gram",
      "category": "Protein",
      "unit": "100 g cooked",
      "calories": 105.0,
      "protein": 7.0,
      "carbs": 19.0,
      "fat": 0.4,
      "fiber": 7.6,
    },

    // ============================================================
    // FRUITS
    // ============================================================
    {
      "name": "Banana",
      "category": "Fruits",
      "unit": "1 medium",
      "calories": 105.0,
      "protein": 1.3,
      "carbs": 27.0,
      "fat": 0.4,
      "fiber": 3.1,
    },
    {
      "name": "Apple",
      "category": "Fruits",
      "unit": "1 medium",
      "calories": 95.0,
      "protein": 0.5,
      "carbs": 25.0,
      "fat": 0.3,
      "fiber": 4.4,
    },
    {
      "name": "Orange",
      "category": "Fruits",
      "unit": "1 medium",
      "calories": 62.0,
      "protein": 1.2,
      "carbs": 15.0,
      "fat": 0.2,
      "fiber": 3.1,
    },
    {
      "name": "Papaya",
      "category": "Fruits",
      "unit": "100 g",
      "calories": 43.0,
      "protein": 0.5,
      "carbs": 11.0,
      "fat": 0.3,
      "fiber": 1.7,
    },
    {
      "name": "Watermelon",
      "category": "Fruits",
      "unit": "100 g",
      "calories": 30.0,
      "protein": 0.6,
      "carbs": 7.6,
      "fat": 0.2,
      "fiber": 0.4,
    },
    {
      "name": "Mango",
      "category": "Fruits",
      "unit": "100 g",
      "calories": 60.0,
      "protein": 0.8,
      "carbs": 15.0,
      "fat": 0.4,
      "fiber": 1.6,
    },
    {
      "name": "Pineapple",
      "category": "Fruits",
      "unit": "100 g",
      "calories": 50.0,
      "protein": 0.5,
      "carbs": 13.0,
      "fat": 0.1,
      "fiber": 1.4,
    },
    {
      "name": "Guava",
      "category": "Fruits",
      "unit": "100 g",
      "calories": 68.0,
      "protein": 2.6,
      "carbs": 14.0,
      "fat": 1.0,
      "fiber": 5.4,
    },

    // ============================================================
    // VEGETABLES
    // ============================================================
    {
      "name": "Carrot",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 41.0,
      "protein": 0.9,
      "carbs": 10.0,
      "fat": 0.2,
      "fiber": 2.8,
    },
    {
      "name": "Cucumber",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 15.0,
      "protein": 0.7,
      "carbs": 3.6,
      "fat": 0.1,
      "fiber": 0.5,
    },
    {
      "name": "Tomato",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 18.0,
      "protein": 0.9,
      "carbs": 3.9,
      "fat": 0.2,
      "fiber": 1.2,
    },
    {
      "name": "Spinach",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 23.0,
      "protein": 2.9,
      "carbs": 3.6,
      "fat": 0.4,
      "fiber": 2.2,
    },
    {
      "name": "Beetroot",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 43.0,
      "protein": 1.6,
      "carbs": 10.0,
      "fat": 0.2,
      "fiber": 2.8,
    },
    {
      "name": "Cabbage",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 25.0,
      "protein": 1.3,
      "carbs": 6.0,
      "fat": 0.1,
      "fiber": 2.5,
    },
    {
      "name": "Beans",
      "category": "Vegetables",
      "unit": "100 g",
      "calories": 31.0,
      "protein": 1.8,
      "carbs": 7.0,
      "fat": 0.2,
      "fiber": 2.7,
    },
    {
      "name": "Potato",
      "category": "Vegetables",
      "unit": "100 g boiled",
      "calories": 87.0,
      "protein": 1.9,
      "carbs": 20.0,
      "fat": 0.1,
      "fiber": 1.8,
    },

    // ============================================================
    // DAIRY
    // ============================================================
    {
      "name": "Milk",
      "category": "Dairy",
      "unit": "200 ml",
      "calories": 122.0,
      "protein": 6.4,
      "carbs": 9.6,
      "fat": 6.6,
      "fiber": 0.0,
    },
    {
      "name": "Curd",
      "category": "Dairy",
      "unit": "100 g",
      "calories": 61.0,
      "protein": 3.5,
      "carbs": 4.7,
      "fat": 3.3,
      "fiber": 0.0,
    },
    {
      "name": "Buttermilk",
      "category": "Dairy",
      "unit": "200 ml",
      "calories": 80.0,
      "protein": 4.0,
      "carbs": 6.0,
      "fat": 3.0,
      "fiber": 0.0,
    },

    // ============================================================
    // NUTS & SEEDS
    // ============================================================
    {
      "name": "Almonds",
      "category": "Nuts & Seeds",
      "unit": "30 g",
      "calories": 174.0,
      "protein": 6.4,
      "carbs": 6.5,
      "fat": 15.0,
      "fiber": 3.8,
    },
    {
      "name": "Cashews",
      "category": "Nuts & Seeds",
      "unit": "30 g",
      "calories": 166.0,
      "protein": 5.5,
      "carbs": 9.0,
      "fat": 13.0,
      "fiber": 1.0,
    },
    {
      "name": "Peanuts",
      "category": "Nuts & Seeds",
      "unit": "30 g",
      "calories": 170.0,
      "protein": 7.0,
      "carbs": 5.0,
      "fat": 14.5,
      "fiber": 2.5,
    },

    // ============================================================
    // SNACKS
    // ============================================================
    {
      "name": "Bread",
      "category": "Snacks",
      "unit": "1 slice",
      "calories": 70.0,
      "protein": 2.5,
      "carbs": 13.0,
      "fat": 1.0,
      "fiber": 1.0,
    },
    {
      "name": "Biscuit",
      "category": "Snacks",
      "unit": "2 biscuits",
      "calories": 100.0,
      "protein": 1.5,
      "carbs": 15.0,
      "fat": 4.0,
      "fiber": 0.5,
    },
    {
      "name": "Samosa",
      "category": "Snacks",
      "unit": "1 piece",
      "calories": 150.0,
      "protein": 3.0,
      "carbs": 18.0,
      "fat": 7.0,
      "fiber": 2.0,
    },
    {
      "name": "Banana Chips",
      "category": "Snacks",
      "unit": "30 g",
      "calories": 160.0,
      "protein": 1.0,
      "carbs": 18.0,
      "fat": 10.0,
      "fiber": 1.5,
    },

    // ============================================================
    // DRINKS
    // ============================================================
    {
      "name": "Coconut Water",
      "category": "Drinks",
      "unit": "200 ml",
      "calories": 38.0,
      "protein": 0.7,
      "carbs": 9.0,
      "fat": 0.2,
      "fiber": 1.0,
    },
    {
      "name": "Tea with Milk",
      "category": "Drinks",
      "unit": "1 cup",
      "calories": 70.0,
      "protein": 2.0,
      "carbs": 10.0,
      "fat": 2.0,
      "fiber": 0.0,
    },
    {
      "name": "Coffee with Milk",
      "category": "Drinks",
      "unit": "1 cup",
      "calories": 80.0,
      "protein": 2.5,
      "carbs": 10.0,
      "fat": 2.5,
      "fiber": 0.0,
    },

    // ============================================================
    // COMMON DISHES
    // ============================================================
    {
      "name": "Chicken Biryani",
      "category": "Meals",
      "unit": "1 serving",
      "calories": 450.0,
      "protein": 22.0,
      "carbs": 55.0,
      "fat": 17.0,
      "fiber": 3.0,
    },
    {
      "name": "Vegetable Biryani",
      "category": "Meals",
      "unit": "1 serving",
      "calories": 350.0,
      "protein": 8.0,
      "carbs": 55.0,
      "fat": 11.0,
      "fiber": 4.0,
    },
    {
      "name": "Chapati",
      "category": "Rice & Grains",
      "unit": "1 medium",
      "calories": 100.0,
      "protein": 3.0,
      "carbs": 18.0,
      "fat": 2.0,
      "fiber": 2.5,
    },
  ];

  List<Map<String, dynamic>> todayMeals = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOCAL HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString(historyKey);

    if (saved == null) return;

    try {
      final decoded = jsonDecode(saved);

      if (decoded is List) {
        setState(() {
          todayMeals = List<Map<String, dynamic>>.from(
            decoded.map((item) => Map<String, dynamic>.from(item)),
          );
        });
      }
    } catch (e) {
      debugPrint("Nutrition history error: $e");
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(historyKey, jsonEncode(todayMeals));
  }

  Future<void> clearHistory() async {
    setState(() {
      todayMeals.clear();
    });

    await saveHistory();
  }

  Future<void> deleteMeal(int index) async {
    setState(() {
      todayMeals.removeAt(index);
    });

    await saveHistory();
  }

  // ============================================================
  // ADD FOOD
  // ============================================================

  Future<void> addFood(Map<String, dynamic> food) async {
    final quantityController = TextEditingController(text: "1");

    final quantity = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(food["name"]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reference serving: ${food["unit"]}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  hintText: "Example: 1 or 2",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(quantityController.text.trim());

                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text("ADD"),
            ),
          ],
        );
      },
    );

    quantityController.dispose();

    if (quantity == null) return;

    final meal = {
      "name": food["name"],
      "category": food["category"],
      "meal": selectedMeal,
      "quantity": quantity,
      "unit": food["unit"],
      "calories": food["calories"] * quantity,
      "protein": food["protein"] * quantity,
      "carbs": food["carbs"] * quantity,
      "fat": food["fat"] * quantity,
      "fiber": food["fiber"] * quantity,
      "date": DateTime.now().toIso8601String(),
    };

    setState(() {
      todayMeals.add(meal);
    });

    await saveHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${food["name"]} added to $selectedMeal")),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get filteredFoods {
    final query = searchController.text.trim().toLowerCase();

    return foods.where((food) {
      final matchesCategory =
          selectedCategory == "All" || food["category"] == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          food["name"].toString().toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get categories {
    return ["All", ...foods.map((food) => food["category"].toString()).toSet()];
  }

  // ============================================================
  // TOTALS
  // ============================================================

  double total(String key) {
    return todayMeals.fold(
      0.0,
      (sum, meal) => sum + ((meal[key] ?? 0) as num).toDouble(),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Analysis"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // -------------------------------------------------------
          // MEAL SELECTOR
          // -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: selectedMeal,
              decoration: const InputDecoration(
                labelText: "Meal",
                prefixIcon: Icon(Icons.restaurant),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                DropdownMenuItem(value: "Snack", child: Text("Snack")),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedMeal = value;
                });
              },
            ),
          ),

          // -------------------------------------------------------
          // SEARCH
          // -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: "Search food...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // -------------------------------------------------------
          // CATEGORY FILTER
          // -------------------------------------------------------
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                final selected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    selectedColor: Colors.teal.shade100,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // -------------------------------------------------------
          // FOOD LIST
          // -------------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final food = filteredFoods[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.teal,
                      ),
                    ),
                    title: Text(
                      food["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${food["unit"]}\n"
                      "${food["calories"].toStringAsFixed(0)} kcal • "
                      "Protein ${food["protein"]} g",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.teal,
                        size: 32,
                      ),
                      onPressed: () => addFood(food),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // -----------------------------------------------------------
      // TODAY'S NUTRITION
      // -----------------------------------------------------------
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: showTodayNutrition,
            icon: const Icon(Icons.analytics),
            label: const Text("VIEW TODAY'S NUTRITION"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TODAY'S NUTRITION DIALOG
  // ============================================================

  void showTodayNutrition() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Today's Nutrition",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          Navigator.pop(context);

                          final confirm = await showDialog<bool>(
                            context: this.context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Clear history?"),
                                content: const Text(
                                  "Remove all meals saved locally?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("CANCEL"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("CLEAR"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await clearHistory();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Nutrition summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _NutritionTile(
                        title: "Calories",
                        value: "${total("calories").toStringAsFixed(0)} kcal",
                        icon: Icons.local_fire_department,
                      ),
                      _NutritionTile(
                        title: "Protein",
                        value: "${total("protein").toStringAsFixed(1)} g",
                        icon: Icons.fitness_center,
                      ),
                      _NutritionTile(
                        title: "Carbs",
                        value: "${total("carbs").toStringAsFixed(1)} g",
                        icon: Icons.grain,
                      ),
                      _NutritionTile(
                        title: "Fat",
                        value: "${total("fat").toStringAsFixed(1)} g",
                        icon: Icons.opacity,
                      ),
                      _NutritionTile(
                        title: "Fiber",
                        value: "${total("fiber").toStringAsFixed(1)} g",
                        icon: Icons.eco,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Meals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: todayMeals.isEmpty
                      ? const Center(
                          child: Text(
                            "No meals added today.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: todayMeals.length,
                          itemBuilder: (context, index) {
                            final meal = todayMeals[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade50,
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.teal,
                                  ),
                                ),
                                title: Text(
                                  meal["name"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${meal["meal"]} • "
                                  "Quantity: ${meal["quantity"]}\n"
                                  "${(meal["calories"] as num).toStringAsFixed(0)} kcal • "
                                  "Protein ${(meal["protein"] as num).toStringAsFixed(1)} g",
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await deleteMeal(index);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      showTodayNutrition();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// NUTRITION TILE
// ================================================================

class _NutritionTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _NutritionTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
