import 'package:flutter/material.dart';

import 'package:testline/api_service.dart';
import 'package:testline/result.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late List<String> questions;
  late List<List<Map<String, dynamic>>> options;
  late List<Map<String, String>> solutions;
  int currentQuestionIndex = 0;
  String? selectedOption;
  bool isLoading = true;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  /// Load questions, options, and solutions
  Future<void> _loadQuizData() async {
    try {
      final fetchedQuestions = await ApiService().fetchQuestion();
      final fetchedOptions = await ApiService().fetchOptions();
      final fetchedSolutions = await ApiService().fetchSolutions();

      setState(() {
        questions = fetchedQuestions;
        options = fetchedOptions;
        solutions = fetchedSolutions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading quiz: $e")),
      );
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null; // Reset selected option for the next question
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quiz Completed!")),
      );
    }
  }

  void _showResultDialog(bool isCorrect) {
    // Get the detailed solution and clean it
    String rawSolution = solutions[currentQuestionIndex]["detailedSolution"] ??
        "No explanation available";
    String cleanedSolution = rawSolution.replaceAll('*', '').trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? "✅ Correct!" : "❌ Wrong Answer"),
          content: SingleChildScrollView(
            child: Text(
              isCorrect
                  ? "Great Job! You selected the correct answer."
                  : "Correct Answer: ${solutions[currentQuestionIndex]["correctAnswer"]}\n\n$cleanedSolution",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Quit"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {
                if (currentQuestionIndex < questions.length - 1) {
                  setState(() {
                    selectedOption = null;
                    currentQuestionIndex++;
                  });
                  Navigator.pop(context);
                } else {
                  // When the last question is answered, submit the quiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Result(score: score),
                    ),
                  );
                }
              },
              child: Text(
                currentQuestionIndex < questions.length - 1
                    ? "Next Question"
                    : "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Check answer when "Check Answer" is clicked
  void _checkAnswer() {
    bool isCorrect = options[currentQuestionIndex].firstWhere(
        (opt) => opt["description"] == selectedOption)["is_correct"];

    setState(() {
      if (isCorrect) {
        score += 4; // ✅ Add +4 points for correct answer
      } else {
        score -= 1; // ❌ Deduct -1 point for wrong answer
      }
    });

    _showResultDialog(isCorrect);
  }

  // Function to show quit confirmation dialog
  Future<bool> _showQuitDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Quit Test"),
            content: Text("Do you really want to quit the test?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Quit
                child: Text("OK", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false; // If dialog is dismissed, return false
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _showQuitDialog,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text('Quiz App', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            // 🔹 Display the score in the top-right corner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Score: $score",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Question ${currentQuestionIndex + 1}:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                SizedBox(height: 10),
                Text(
                  questions[currentQuestionIndex],
                  style: TextStyle(fontSize: 16, color: Colors.indigo),
                ),
                SizedBox(height: 20),
                Column(
                  children: options[currentQuestionIndex].map((option) {
                    return RadioListTile<String>(
                      title: Text(option["description"]),
                      value: option["description"],
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: selectedOption == null ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedOption == null ? Colors.grey : Colors.indigo,
                    ),
                    child: Text(
                      "Check Answer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
