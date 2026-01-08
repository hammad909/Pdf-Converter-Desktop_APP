import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/model/weather_model.dart';

class WeatherServices {

final apiKey = '81fcd3a160aedbe737205ae6c7273620';



Future<WeatherModel>fetchWeather(String cityName) async {


final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey');

final response = await http.get(url);

if(response.statusCode == 200){

final data = jsonDecode(response.body);
return WeatherModel.fromJson(data);

}else{
  throw Exception('Failed to fetch weather');
}

}


}
