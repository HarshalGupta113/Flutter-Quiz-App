import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testline/api_service.dart';
import 'package:testline/quiz.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ApiService apiService;
  late Future<Map<String, dynamic>> dataFuture;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    dataFuture = apiService.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the app when back button is pressed
        SystemNavigator.pop();
        return false; // Prevents navigating back
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.indigo,
          title: Text(
            'Quiz App',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              // Now we can safely access ['title']
              String title = snapshot.data!['title'];
              String topic = snapshot.data!['topic'];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Title: $title',
                      style:
                          const TextStyle(fontSize: 23, color: Colors.indigo),
                    ),
                    Text(
                      'Topic: $topic',
                      style:
                          const TextStyle(fontSize: 20, color: Colors.indigo),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(
                          "Instructions: ",
                          style: const TextStyle(
                              fontSize: 20, color: Colors.indigo),
                        ),
                        children: [
                          Text(
                            "Correct Answer: +4",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.indigo),
                          ),
                          Text(
                            "Wrong Answer: -1",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.indigo),
                          ),
                          Text(
                            "All the best!",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Quiz()),
                        );
                      },
                      child: const Text(
                        'Start Test',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
