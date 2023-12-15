import 'dart:convert';
import 'package:boot_temperature/src/screen/Chatscreen.dart';
import 'package:column_scroll_view/column_scroll_view.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../data/data.dart';

class WeatherData {
  final String cityName;
  final double temperature;
  final String icon;
  final String humidity;
  WeatherData(
      {required this.cityName,
      required this.temperature,
      required this.icon,
      required this.humidity});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
        cityName: json['name'],
        temperature: json['main']['temp'],
        icon: json['weather'][0]['icon'],
        humidity: json['main']['humidity'].toString());
  }
}

class Home extends StatefulWidget {
  const Home();

  static const Color myBlueColor = Color.fromRGBO(51, 51, 51, 1);
  static const Color scaffoldBackgroundColor = Color.fromRGBO(51, 51, 51, 1);
  static const String fontFamily = 'Preahvihear-Regular';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String apiKey = '898e1b80e9d55b10df0f759545602df9';
  TextEditingController _cityController = TextEditingController();
  DateTime? _dateTime;

  WeatherData? _weatherData;
  aladhan? _aladhan;
  dynamic Data;
  dynamic Data2;

  @override
  void initState() {
    super.initState();
    // Initialiser la ville avec "Mateur" lors de l'ouverture de l'application
    _cityController.text = 'Mateur';
    // Charger les données météorologiques pour la ville initiale
    fetchWeather(_cityController.text);
  }

  Future<void> fetchWeather(String cityName) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=898e1b80e9d55b10df0f759545602df9&units=metric',
      ),
    );
    final response2 = await http.get(
      Uri.parse(
        'https://api.aladhan.com/v1/timingsByAddress/08-12-2023?address=$cityName',
      ),
    );
    // final response3 = await http.get(
    //   Uri.parse(
    //     'http://192.168.43.81:4000/temperature/now/$cityName',
    //   ),
    // );

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);

      setState(() {
        _weatherData = WeatherData.fromJson(json.decode(response.body));
        _aladhan = aladhan.fromJson(json.decode(response2.body));
        // Data = json.decode(response3.body);
        Data = json.decode(response.body);
        Data2 = json.decode(response2.body);
        final int? timestamp = jsonResult['dt'];
        final int? timeZoneOffset = jsonResult['timezone'];

        if (timestamp != null && timeZoneOffset != null) {
          _dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000,
                  isUtc: false)
              .add(Duration(seconds: timeZoneOffset));
        } else {
          // Si les champs ne sont pas disponibles, initialisez _dateTime à la date actuelle.
          _dateTime = DateTime.now();
        }
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: null,
          centerTitle: true,
          backgroundColor:
              Color.fromRGBO(51, 51, 51, 1), // Adjust the color as needed
          elevation: 0.0,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _cityController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                  hintText: 'Enter city name',
                  hintStyle: TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      fetchWeather(_cityController.text);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        body: ProgressHUD(
          child: Center(
            child: Container(
              decoration: BoxDecoration(color: Home.scaffoldBackgroundColor),
              child: ColumnScrollView(
                child: Column(
                  children: [
                    if (_weatherData != null)
                      Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(82, 201, 230, 193),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  "images/${_weatherData!.icon}.png",
                                ),
                                Text(
                                  "${_weatherData!.temperature} °C",
                                  style: TextStyle(fontSize: 35),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 35,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(_weatherData!.cityName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w300)),
                                Text(
                                  _dateTime != null
                                      ? "${_dateTime!.toLocal()}"
                                          .split(' ')[1]
                                          .split('.')[0]
                                      : "", // Formatage de la date
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Humidity: ${_weatherData!.humidity}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    if (_aladhan != null)
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(82, 201, 230, 193),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Column(
                          children: [
                            Text(
                              "Heure Sunrise et Sunset",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 25,
                                  fontFamily: "cursive",
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Image(
                                      image: AssetImage("images/Sunrise.png"),
                                      width: 90,
                                    ),
                                    Text("${_aladhan!.Sunrise}",
                                        style: TextStyle(
                                            color: Colors.white30,
                                            fontSize: 15)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image(
                                      image: AssetImage("images/Sunset.png"),
                                      width: 90,
                                    ),
                                    Text("${_aladhan!.Sunset}",
                                        style: TextStyle(
                                            color: Colors.white30,
                                            fontSize: 15)),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (_aladhan != null)
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(82, 201, 230, 193),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Column(
                            children: [
                              Text(
                                "Heure De Priere",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 25,
                                    fontFamily: "cursive",
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image(
                                      image: AssetImage("images/prieres.png"),
                                      width: 100),
                                  Column(
                                    children: [
                                      Card("Fajar", _aladhan!.Fajr),
                                      Card("Dhuhr", _aladhan!.Dhuhr),
                                      Card("Asr", _aladhan!.Asr),
                                      Card("Maghrib", _aladhan!.Maghrib),
                                      Card("Isha", _aladhan!.Isha),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )),
                    Container(
                      height: 50,
                      width: 320,
                      margin: EdgeInsets.fromLTRB(15, 15, 17, 0),
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  9), // Set to 0 for non-rounded corners
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(125, 124, 255, 2),
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white, // Set text color to white
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatGPTWidget(
                                    Donner: Data, Donner2: Data2)),
                          );
                        },
                        icon: Icon(Icons.star),
                        label: Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget Card(String txt, String heur) => Container(
        width: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              txt,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  color: Colors.white70),
            ),
            Text(
              heur,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  color: Colors.white70),
            ),
          ],
        ),
      );
}
