class aladhan {
  final String Fajr;
  final String Sunrise;
  final String Dhuhr;
  final String Sunset;
  final String Asr;
  final String Maghrib;
  final String Isha;
  final String Imsak;
  aladhan(
      {required this.Fajr,
      required this.Sunrise,
      required this.Dhuhr,
      required this.Sunset,
      required this.Maghrib,
      required this.Isha,
      required this.Imsak,
      required this.Asr});

  factory aladhan.fromJson(Map<String, dynamic> json) {
    return aladhan(
        Fajr: json['data']['timings']['Fajr'],
        Sunrise: json['data']['timings']['Sunrise'],
        Dhuhr: json['data']['timings']['Dhuhr'],
        Sunset: json['data']['timings']['Sunset'],
        Maghrib: json['data']['timings']['Maghrib'],
        Isha: json['data']['timings']['Isha'],
        Imsak: json['data']['timings']['Imsak'],
        Asr: json['data']['timings']['Asr']);
  }
}
