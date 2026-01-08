
class WeatherModel {
  //using final cause we will use objects. Removing the one which is garbage and UPdate UI
   final String cityName;
   final double temp;
   final String description;
   final int humidity;
   final double windSpeed;
   final int sunrise;
   final int sunset; 


   WeatherModel({
    required this.cityName,
   required this.description,
   required  this.temp,
   required  this.humidity,
   required  this.windSpeed,
   required  this.sunrise,
   required  this.sunset});



//take our API response and give it to the class variables
   factory WeatherModel.fromJson(Map <String, dynamic>json) {
    return WeatherModel(
      cityName: json['name'],
      temp: json['main']['temp'] - 273.15,
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
    );
   }
}
