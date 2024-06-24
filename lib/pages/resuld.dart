import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Result extends StatefulWidget {
  final String place;

  const Result({Key? key, required this.place}) : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> weatherData;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    weatherData = getDataFromApi();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getDataFromApi() async {
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.place}&appid=0669e771943a280d7c17024e4cbdad30&units=metric"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data;
    } else {
      throw Exception("Error fetching weather data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hasil Tracking",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          
          },
          child: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 253, 253, 255),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                weatherData = getDataFromApi();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade300, Color.fromARGB(255, 76, 43, 238)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData) {
              final data = snapshot.data as Map<String, dynamic>;
              final weatherIcon = data["weather"][0]["icon"];
              final weatherDescription = data["weather"][0]["description"];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://flagsapi.com/${data["sys"]["country"]}/shiny/64.png',
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return CircularProgressIndicator();
                              },
                            ),
                            const SizedBox(height: 20),
                            Image.network(
                              'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                              scale: 0.5,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return CircularProgressIndicator();
                              },
                            ),
                            Text(
                              weatherDescription,
                              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 20),
                            Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: Icon(Icons.thermostat_outlined, color: Colors.red),
                                title: Text("Suhu: ${data["main"]["feels_like"]} °C"),
                              ),
                            ),
                            Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: Icon(Icons.air, color: Colors.blue),
                                title: Text('Kecepatan Angin: ${data["wind"]["speed"]} m/s'),
                              ),
                            ),
                            Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: Icon(Icons.cloud, color: Colors.grey),
                                title: Text('Cuaca: ${data["clouds"]["all"]}%'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );},
              );
            } else {
              return Center(
                child: Text(
                  "Tempat tidak diketahui",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }},
        ),),
    );
  }
}
