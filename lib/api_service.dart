import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://api.jsonserve.com/Uw5CrX';

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Method to fetch the description value from the questions list
  Future<List<String>> fetchQuestion() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> questions = data['questions'];

        List<String> questionDescriptions = [];
        for (var question in questions) {
          questionDescriptions.add(question['description']);
        }
        return questionDescriptions;
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Fetches options for each question
  Future<List<List<Map<String, dynamic>>>> fetchOptions() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> questions = data["questions"];

      return questions.map((q) {
        final List<dynamic> options = q["options"] ?? []; // Ensure it's a list
        return options.map((opt) {
          return {
            "description": opt["description"].toString(),
            "is_correct": opt["is_correct"] as bool
          };
        }).toList();
      }).toList();
    } else {
      throw Exception('Failed to load options');
    }
  }

// Fetches correct answers and detailed solutions
  Future<List<Map<String, String>>> fetchSolutions() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> questions = data["questions"];

      return questions.map((q) {
        final List<dynamic> options = q["options"];

        // Find the correct option or use a default value
        final Map<String, dynamic> correctOption = options.firstWhere(
          (opt) => opt["is_correct"] == true,
          orElse: () => <String, dynamic>{}, // Ensuring it's never null
        );

        return {
          "correctAnswer": correctOption.containsKey("description")
              ? correctOption["description"].toString()
              : "No correct answer",
          "detailedSolution":
              q["detailed_solution"]?.toString() ?? "No explanation available",
        };
      }).toList();
    } else {
      throw Exception('Failed to load solutions');
    }
  }
}
