import 'package:flutter/material.dart';
import 'package:testline/home.dart';

class Result extends StatelessWidget {
  final int score;
  const Result({super.key, required this.score});
  // Determine the badge based on the score
  String _getBadge() {
    if (score >= 30) {
      return "👑 Legend";
    } else if (score >= 20) {
      return "⚔️ Warrior";
    } else if (score >= 10) {
      return "🐣 Rookie";
    } else {
      return "No Badge Earned";
    }
  }

  @override
  Widget build(BuildContext context) {
    String badge = _getBadge();
    return WillPopScope(
      onWillPop: () async {
        // Navigate to Home when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Quiz Result',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🏆 Quiz Completed!",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your Final Score: $score",
                  style: const TextStyle(fontSize: 20, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                Text(
                  "🏅 Earned Badge: $badge",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text(
                    "Go Back to Home",
                    style: TextStyle(color: Colors.white),
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
