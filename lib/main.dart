import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FoodRecipeApp());
}

class FoodRecipeApp extends StatelessWidget {
  const FoodRecipeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const RecipeHomeScreen(),
    );
  }
}

class RecipeHomeScreen extends StatefulWidget {
  const RecipeHomeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeHomeScreen> createState() => _RecipeHomeScreenState();
}

class _RecipeHomeScreenState extends State<RecipeHomeScreen> {
  // Hardcoded data matching the assignment's UI requirements.
  // You can replace this with the fetchRecipesFromApi() method when you have your Spoonacular API key.
  final List<Map<String, String>> recipes = [
    {
      "title": "Creamy Garlic Pasta",
      "image": "https://spoonacular.com/recipeImages/716429-312x231.jpg",
      "videoId": "2yEibA_6-hQ" // Example YouTube Video ID
    },
    {
      "title": "Homemade Margherita Pizza",
      "image": "https://spoonacular.com/recipeImages/715497-312x231.jpg",
      "videoId": "sv3TXMSv6Lw"
    },
    {
      "title": "Classic Cheeseburger",
      "image": "https://spoonacular.com/recipeImages/639411-312x231.jpg",
      "videoId": "iM_KMYulI_s"
    },
    {
      "title": "Healthy Chicken Salad",
      "image": "https://spoonacular.com/recipeImages/716426-312x231.jpg",
      "videoId": "A_A-4-Y0E8A"
    }
  ];

  // --- API METHOD (Ready to use if needed) ---
  // Future<void> fetchRecipesFromApi() async {
  //   const String apiKey = 'YOUR_API_KEY_HERE';
  //   final response = await http.get(
  //     Uri.parse('https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&number=10'),
  //   );
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     // Update your state with data['results']
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    recipe["image"]!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image, size: 50))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Recipe Title
                      Expanded(
                        child: Text(
                          recipe["title"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Watch Video Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeVideoScreen(
                                videoId: recipe["videoId"]!,
                                recipeTitle: recipe["title"]!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('Watch', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RecipeVideoScreen extends StatefulWidget {
  final String videoId;
  final String recipeTitle;

  const RecipeVideoScreen({
    Key? key,
    required this.videoId,
    required this.recipeTitle,
  }) : super(key: key);

  @override
  State<RecipeVideoScreen> createState() => _RecipeVideoScreenState();
}

class _RecipeVideoScreenState extends State<RecipeVideoScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Construct the YouTube embed URL
    final String youtubeEmbedUrl = 'https://www.youtube.com/embed/${widget.videoId}?playsinline=1';

    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(youtubeEmbedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeTitle),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // The WebView for YouTube
                SizedBox(
                  height: 250, // Standard height for video player on mobile
                  width: double.infinity,
                  child: WebViewWidget(controller: _controller),
                ),
                // Show a loading indicator while the video frame is loading
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Enjoy the recipe tutorial!",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }
}
